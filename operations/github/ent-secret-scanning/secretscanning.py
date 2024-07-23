import requests
import sys

# Utility function to run a GET against the API
def api_get(access_token, url):
    try:
        headers = {"Authorization": f"Bearer {access_token}"}
        return requests.get(url, headers=headers)
    except Exception as e:
        print (f"Error while running API GET. {e}.")
        exit

def get_secret_scanning_and_push_protection_settings(access_token):
    url = f"https://api.github.com/enterprises/openssf/code_security_and_analysis"
    
    response = api_get(access_token=access_token, url=url)

    if response.status_code == 200:
        settings = response.json()
        secret_scanning_enabled = settings.get("secret_scanning_enabled_for_new_repositories", {})
        push_protection_enabled = settings.get("secret_scanning_push_protection_enabled_for_new_repositories", {})
        return secret_scanning_enabled, push_protection_enabled
    else:
        print(f"Error: Unable to retrieve settings. Status code: {response.status_code}")
        return None, None

        
def check_policies(access_token):
    print(f"Checking current settings.")
    secret_scanning, push_protection = get_secret_scanning_and_push_protection_settings(access_token)
    if secret_scanning is not None and push_protection is not None:
        print(f"Secret Scanning enabled: {secret_scanning}")
        print(f"Push Protection enabled: {push_protection}")
    else:
        print("Error occurred while fetching settings.")


# Utility function for calling the PATCH method on the Github API
def api_patch(access_token, url, data):
    try:
        headers = {"Authorization": f"Bearer {access_token}"}
        return requests.patch(url, json=data, headers=headers)
    except Exception as e:
        print(f"Error: {e}")
        exit
        
# Set the policies
def set_secret_scanning_and_push_protection_settings(access_token):
    url = "https://api.github.com/enterprises/openssf/code_security_and_analysis"
    data = {"secret_scanning_enabled_for_new_repositories":True,"secret_scanning_push_protection_enabled_for_new_repositories":True}
    response = api_patch(access_token, url, json=data)
    if response.status_code == 204:
        return True
    else:
        print(f"Error: Response code is invalid for updating security policies")
        return False

# Unset the policies               
def disable_secret_scanning_and_push_protection_settings(access_token):
    url = "https://api.github.com/enterprises/openssf/code_security_and_analysis"
    data = {"secret_scanning_enabled_for_new_repositories":False,"secret_scanning_push_protection_enabled_for_new_repositories":False}
    response = api_patch(access_token, url, json=data)

    if response.status_code == 204:
            return True
    else:
        print(f"Error: Response code is invalid for updating security policies")
    return False


# Tests to make sure that the calls to PATCH and GET for handling of object properties works
# This tests an entirely different endpoint, but uses the same methods and formats
def run_api_tests(api_token, repository, desc):
    url = f"https://api.github.com/repos/" + repository
    data = {"description":desc,"private":True}

    # PATCH call to update object properties
    response = api_patch(access_token, url, data)


    if response.status_code == 200:
        print ("successful test for PATCH of repo info")
    else:
        print ("test failed for PATCH of repo")
        print (response.status_code)
        print (response.content)
        exit

    # get data to validate update to properties
    try:
        response = api_get(access_token, url)
        if response.status_code == 200:
            settings = response.json()
            if settings.get("description") == desc:
                print("success")
            else:
                print("fail")
        else:
            print ("Failed pulling properties.")
            exit

    except Exception as e:
        print (f"Failed calling API GET: {e}")

def usage():
    print("python secretscanning.py -t token_filename -c <set|rollback|check|test")
    print("token_filename = supply a filename which contains a valid github API token.")
    print("choose \"set\" to set the polcies, \"rollback\" to rollback the policies, or leave blank to report the current settings.")

def parse_arguments():
    args = {}
    for i in range(1, len(sys.argv), 2):
        flag = sys.argv[i]
        value = sys.argv[i + 1] if i + 1 < len(sys.argv) else None
        if flag.startswith("-"):
            args[flag] = value
    return args

access_token = "placeholder"

arguments = parse_arguments()
tokenfile= arguments.get("-t")
command = arguments.get("-c")
testrepo = arguments.get("-r")
desc = arguments.get("-d")

try:
    with open(tokenfile, 'r') as file:
        access_token = file.read().rstrip()
except Exception as e:
    print(f"Error accessing token file: {e}")

if (command == "run_tests"):
    run_api_tests(access_token, testrepo, desc)

if command == "check":
    check_policies(access_token)

if (command == "set"):
    if (set_secret_scanning_and_push_protection_settings(access_token)):
        print(f"Setting policy successful, validating...")
        check_policies(access_token)
    else:
        print(f"Setting policies failed, please check logs and try again.")

if (command == "rollback"):
    if (disable_secret_scanning_and_push_protection_settings(access_token)):
        print(f"Setting policy successful, validating...")
        check_policies(access_token)
    else:
        print(f"Rollback failed, please check logs and try again.")

        


