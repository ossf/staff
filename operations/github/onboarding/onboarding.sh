#!/bin/bash

set -e

# Function to handle errors
function handle_error() {
    echo "Error: $1."
    exit 1
}

# Parse arguments
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 -test|-prod -i <input_json_file> -o <output_json_file>"
    exit 1
fi

MODE=$1
INPUT_FILE=$3
OUTPUT_FILE=$5

if [ "$MODE" != "-test" ] && [ "$MODE" != "-prod" ]; then
    echo "Invalid mode. Use -test or -prod."
    exit 1
fi

# Read the JSON file
if [ ! -f "$INPUT_FILE" ]; then
    echo "File not found: $INPUT_FILE"
    exit 1
fi

# GitHub API token from environment variable
if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN environment variable not set."
    exit 1
fi

HTTP_RESPONSE_CODE_OK=200
HTTP_RESPONSE_CODE_CREATED=201
HTTP_RESPONSE_CODE_NO_CONTENT=204


#Helper function to make GitHub API requests
function github_api() {
    # Perform the API call and capture the response and HTTP code separately
    local response
    response=$(curl -s -o response.json -w "%{http_code}" \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "$@")
    
    # Output the HTTP status code
    echo "$response"
}


function create_team() {
    echo "Start creating team"

    local org=$1
    local name=$2
    local parent_team_id=$3
    local privacy=$4
    local notification_setting=$5

   
    # Build JSON data for the request
    local data
    if [ -z "$parent_team_id" ]; then
        data=$(jq -n --arg name "$name" --arg privacy "$privacy" --arg notification_setting "$notification_setting" \
            '{name: $name, privacy: $privacy, notification_setting: $notification_setting}')
    else
        data=$(jq -n --arg name "$name" --argjson parent_team_id "$parent_team_id" --arg privacy "$privacy" --arg notification_setting "$notification_setting" \
            '{name: $name, parent_team_id: $parent_team_id, privacy: $privacy, notification_setting: $notification_setting}')
    fi

    # Debugging: print the JSON data being sent
    echo "Creating team $name with data: $data"

     # Perform the API request
    http_code=$(github_api -X POST -d "$data" "https://api.github.com/orgs/$org/teams")

    echo "HTTP response Code: $http_code"
    
    if [ "$http_code" -ne $HTTP_RESPONSE_CODE_CREATED ]; then
        handle_error "Failed to create team $name. HTTP code: $http_code"
    fi
    
    echo "Successfully created team $name"
}

# Helper function to add members to a team
function add_members_to_team() {
    echo "Start adding members to team"

    local org=$1
    local team_slug=$2
    local members=$3

    for member in $(echo "$members" | jq -r '.[] | .github_id'); do
        local role=$(echo "$members" | jq -r ".[] | select(.github_id == \"$member\") | .role")
        http_code=$(github_api -X PUT "https://api.github.com/orgs/$org/teams/$team_slug/memberships/$member" -d "{\"role\":\"$role\"}")

        # Debugging: print the HTTP response code and response body
        echo "HTTP response code: $http_code"

        if [ "$http_code" -ne $HTTP_RESPONSE_CODE_OK ]; then
            handle_error "Failed to add member $member to team $team_slug. HTTP code: $http_code"
        fi
        echo "Successfully added $member to $team_slug"
    done
}


# Helper function to create a repo
function create_repo() {
    echo "Start creating repository"

    local org=$1
    local repo_name=$2
    local template_repo=$3
    local visibility=$4


    local private
    if [ "$visibility" == "true" ]; then
        private=true
    else
        private=false
    fi

    local data=$(jq -n --arg owner "$org" --arg name "$repo_name" --argjson private "$private" \
        '{name: $name, owner: $owner, private: $private}')

    echo "Creating repo at endpoint https://api.github.com/repos/$template_repo/generate with data: $data"

    http_code=$(github_api -X POST -d "$data" "https://api.github.com/repos/$template_repo/generate" -H "Accept: application/vnd.github.baptiste-preview+json")
    
    # Debugging: print the HTTP response code and response body
    echo "HTTP response code: $http_code"

    if [ "$http_code" -ne $HTTP_RESPONSE_CODE_CREATED ]; then
        handle_error "Failed to create repo $repo_name. HTTP code: $http_code"
    fi
    echo "Successfully created repository $repo_name"
}

# Function to assign a repository to a team
function assign_team_permission() {
    echo "Start assinging team permission to access repo"

    local org=$1
    local team_slug=$2
    local repo_name=$3
    local permission=$4

    echo "Assigning team $team_slug with $permission access to repository $repo_name"

    http_code=$(github_api -X PUT "https://api.github.com/orgs/$org/teams/$team_slug/repos/$org/$repo_name" -d "{\"permission\":\"$permission\"}")

    # Debugging: print the HTTP response code and response body
    echo "HTTP response code: $http_code"

    if [ "$http_code" -ne $HTTP_RESPONSE_CODE_NO_CONTENT ]; then
        handle_error "Failed to assign repository $repo_name to team $team_slug. HTTP code: $http_code"
    fi

    echo "Successfully assigned team $team_slug with $permission access to repository $repo_name"
}

# Helper function to create a test issue
function create_test_issue() {
    echo "Start creating a test issue"

    local org=$1
    local repo_name=$2
    local issue_title=$3
    local issue_body=$4

    local data=$(jq -n --arg title "$issue_title" --arg body "$issue_body" \
        '{title: $title, body: $body}')

    echo "Creating test issue with data: $data"
    http_code=$(github_api -X POST -d "$data" "https://api.github.com/repos/$org/$repo_name/issues")

    # Debugging: print the HTTP response code and response body
    echo "HTTP response code: $http_code"

    if [ "$http_code" -ne $HTTP_RESPONSE_CODE_CREATED ]; then
        handle_error "Failed to create test issue. HTTP code: $http_code"
    fi

    echo "Successfully created issue with title $issue_title"
}

# Function to lookup team members and their roles
function lookup_team_members() {
    local org=$1
    local team_name=$2

    echo "Looking up members for team $team_name..."

    http_code=$(github_api -X GET "https://api.github.com/orgs/$org/teams/$team_name/members")
    members=$(jq '.' response.json)

    if [ -z "$members" ]; then
        handle_error "No members found for team $team_name."
    fi

    echo "Newly created members found."

    echo "Team $team_name members and roles:" >> "$OUTPUT_FILE"
    for member in $(echo "$members" | jq -r '.[].login'); do
        http_code=$(github_api -X GET "https://api.github.com/orgs/$org/teams/$team_name/memberships/$member")
        role=$(jq -r '.role' response.json)
        echo "Member: $member, Role: $role"
        echo "Member: $member, Role: $role" >> "$OUTPUT_FILE"
    done
}

# Load repo metadata from a file
DATA=$(jq '.' "$INPUT_FILE")

# Get organization name
ORG=$(echo "$DATA" | jq -r '.organization')

# Create main team
MAIN_TEAM=$(echo "$DATA" | jq '.main_team')
MAIN_TEAM_NAME=$(echo "$MAIN_TEAM" | jq -r '.name')
MAIN_TEAM_PARENT=$(echo "$MAIN_TEAM" | jq -r '.parent_team')
MAIN_TEAM_PRIVACY=$(echo "$MAIN_TEAM" | jq -r '.privacy')
MAIN_TEAM_NOTIFICATION=$(echo "$MAIN_TEAM" | jq -r '.notification_setting')

#Get parent team ID
if [ -n "$MAIN_TEAM_PARENT" ]; then
    echo "parent team ID lookup by name at API endpoint: https://api.github.com/orgs/$ORG/teams/$MAIN_TEAM_PARENT"

    http_code=$(github_api -X GET "https://api.github.com/orgs/$ORG/teams/$MAIN_TEAM_PARENT")
    PARENT_TEAM_ID=$(jq -r '.id' response.json)

    if [ -z "$PARENT_TEAM_ID" ]; then
        handle_error "Failed to get parent team ID for $MAIN_TEAM_PARENT"
    fi
else
    handle_error "Missing data: parent team name for $MAIN_TEAM"
fi

# Create  main team 
create_team "$ORG" "$MAIN_TEAM_NAME" "$PARENT_TEAM_ID" "$MAIN_TEAM_PRIVACY" "$MAIN_TEAM_NOTIFICATION"

# Create sub-teams
SUB_TEAMS=$(echo "$DATA" | jq '.sub_teams[]')

for sub_team in $(echo "$SUB_TEAMS" | jq -r '.name'); do
    SUB_TEAM=$(echo "$SUB_TEAMS" | jq "select(.name == \"$sub_team\")")
    SUB_TEAM_NAME=$(echo "$SUB_TEAM" | jq -r '.name')
    SUB_TEAM_PARENT=$(echo "$SUB_TEAM" | jq -r '.parent_team')
    SUB_TEAM_PRIVACY=$(echo "$SUB_TEAM" | jq -r '.privacy')
    SUB_TEAM_NOTIFICATION=$(echo "$SUB_TEAM" | jq -r '.notification_setting')

    # Get parent team ID
    if [ -n "$SUB_TEAM_PARENT" ]; then
        http_code=$(github_api -X GET "https://api.github.com/orgs/$ORG/teams/$SUB_TEAM_PARENT")
        PARENT_TEAM_ID=$(jq -r '.id' response.json)

        if [ -z "$PARENT_TEAM_ID" ]; then
            handle_error "Failed to get parent team ID for $SUB_TEAM_PARENT"
        fi
    else
        handle_error "Failed to get parent team ID for $SUB_TEAM_PARENT"
    fi

    create_team "$ORG" "$SUB_TEAM_NAME" "$PARENT_TEAM_ID" "$SUB_TEAM_PRIVACY" "$SUB_TEAM_NOTIFICATION"
done

# Add members to teams
MAIN_TEAM_MEMBERS=$(echo "$MAIN_TEAM" | jq '.members')
add_members_to_team "$ORG" "$MAIN_TEAM_NAME" "$MAIN_TEAM_MEMBERS"

for sub_team in $(echo "$SUB_TEAMS" | jq -r '.name'); do
    SUB_TEAM=$(echo "$SUB_TEAMS" | jq "select(.name == \"$sub_team\")")
    SUB_TEAM_MEMBERS=$(echo "$SUB_TEAM" | jq '.members')

    add_members_to_team "$ORG" "$sub_team" "$SUB_TEAM_MEMBERS"
done

# # Create the repo

# Get repo details
REPO_NAME=$(echo "$DATA" | jq -r '.repo.name')
TEMPLATE_REPO=$(echo "$DATA" | jq -r '.repo.template')
REPO_VISIBILITY=$(echo "$DATA" | jq -r '.repo.private')

create_repo "$ORG" "$REPO_NAME" "$TEMPLATE_REPO" "$REPO_VISIBILITY"

# Assign main team permission
MAIN_TEAM_PERMISSION=$(echo "$MAIN_TEAM" | jq -r '.permission')
assign_team_permission "$ORG" "$MAIN_TEAM_NAME" "$REPO_NAME" "$MAIN_TEAM_PERMISSION"

# Assign sub-team permission 
for sub_team in $(echo "$SUB_TEAMS" | jq -r '.name'); do
    SUB_TEAM=$(echo "$SUB_TEAMS" | jq "select(.name == \"$sub_team\")")
    SUB_TEAM_PERMISSION=$(echo "$SUB_TEAM" | jq -r '.permission')
    assign_team_permission "$ORG" "$sub_team" "$REPO_NAME" "$SUB_TEAM_PERMISSION"
done

# Get test issue data
ISSUE_TITLE=$(echo "$DATA" | jq -r '.test_issue.title')
ISSUE_BODY=$(echo "$DATA" | jq -r '.test_issue.body')

# Create a test issue in the new repo
create_test_issue "$ORG" "$REPO_NAME" "$ISSUE_TITLE" "$ISSUE_BODY"

# start providing evidence that all the artifacts are created as expected by lookup
# look up repo settings and append details to the output file
REPO_SETTINGS=$(github_api "https://api.github.com/repos/$ORG/$REPO_NAME")
echo "Repository created" > "$OUTPUT_FILE"
echo "$REPO_SETTINGS" | jq '.' response.json >> "$OUTPUT_FILE"

# look up main team settings and append details to the output file
MAIN_TEAM_SETTINGS=$(github_api "https://api.github.com/orgs/$ORG/teams/$MAIN_TEAM_NAME")
echo "Main team created and permission assigned to the repo" >> "$OUTPUT_FILE"
echo "$MAIN_TEAM_SETTINGS" | jq '.' response.json >> "$OUTPUT_FILE"

# look up members settings in the main team and append details to the output file
MAIN_TEAM_MEMBER_SETTINGS=$(github_api -X GET "https://api.github.com/orgs/$ORG/teams/$MAIN_TEAM_NAME/members")
echo "Main team members added and role assigned" >> "$OUTPUT_FILE"
echo "$MAIN_TEAM_MEMBER_SETTINGS" | jq '.' response.json >> "$OUTPUT_FILE"

#look up sub-team settings and append details to the output file
SUB_TEAMS=$(echo "$DATA" | jq '.sub_teams[]')
for sub_team in $(echo "$SUB_TEAMS" | jq -r '.name'); do
    SUB_TEAM_SETTINGS=$(github_api "https://api.github.com/orgs/$ORG/teams/$sub_team")
    echo "Sub team created and permission assigned to the repo" >> "$OUTPUT_FILE"
    echo "$SUB_TEAM_SETTINGS" | jq '.' response.json >> "$OUTPUT_FILE"

    SUB_TEAM_MEMBER_SETTINGS=$(github_api -X GET "https://api.github.com/orgs/$ORG/teams/$sub_team/members")
    echo "Sub team members members added and role assigned" >> "$OUTPUT_FILE"
    echo "$SUB_TEAM_MEMBER_SETTINGS" | jq '.' response.json >> "$OUTPUT_FILE"

done

# Lookup members for main team
MAIN_TEAM_NAME=$(echo "$DATA" | jq -r '.main_team.name')
lookup_team_members "$ORG" "$MAIN_TEAM_NAME"

# Lookup members for each sub-team
SUB_TEAMS=$(echo "$DATA" | jq '.sub_teams[]')
for sub_team in $(echo "$SUB_TEAMS" | jq -r '.name'); do
    lookup_team_members "$ORG" "$sub_team"
done

# Lookup the test issue and append details to the output file
ISSUE_SETTINGS=$(github_api -X GET "https://api.github.com/repos/$ORG/$REPO_NAME/issues")
echo "Test issue created" >> "$OUTPUT_FILE"
echo "$ISSUE_SETTINGS" | jq '.' response.json >> "$OUTPUT_FILE"


echo "Script completed successfully."
