# Secret Scanning policy implementation #


This includes a python utility to check and implement the secret scanning and push protection enterprise policies.  This utility requires a GH PAT with the permissions to read and write at the Enterprise level ("read:enterprise" and "admin:enterprise").  It is best to create tokens for temporary use.  This assumes the token is stored in a local file.  Unfortunately, there is no means of testing the API calls for updating enterprise level policies without actually changing the enterprise-level policies.  However, there are tests included to call other endpoints with similar functions to try and ensure that the functions should work

## Use of the 

Usage is as follows:

python secretscanning.py -t <tokenfile> -c <command>

tokenfile is the path of the file containing only the github PAT
<command> is one of the following: 
	check -- this checks and reports on the secret scanning policy and the push protection policy
		example: 'python secretscanning.py -t token -c check'
	set -- this checks the policies, updates them to the target state with both enabled, and then verifies and reports on the active settings
		example: 'python secretscanning.py -t token -c set'
	rollback -- this command removes the settings, then checks and reports on the settings to ensure they are disabled
		example: 'python secretscanning.py -t token -c rollback'
		
	run_tests -- This command is used with 2 other options to test the PATCH and GET functions against other endpoints of the Github API, specifically the repository API endpoint.  Here we are testing that the functions to update and check the properties of an object (PATCH for update, GET for reading).  The options are:
		-r = repository to test against
		-d = description of the repository to change
		example: 
		'''python secretscanning.py -t repo_token -c run_tests -r bbp-test/bbp-test -d newdescription'''
	The "check" function can also be used to test.


## API Call reference

Based upon the documentation: https://docs.github.com/en/enterprise-cloud@latest/rest/enterprise-admin/code-security-and-analysis?apiVersion=2022-11-28#update-code-security-and-analysis-features-for-an-enterprise

The token used should be scoped to have the "admin:enterprise" permission for implementation and "read:enterprise" for verification.

### API Call to implement ###
'''
curl -L \
  -X PATCH \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <YOUR-TOKEN>" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/enterprises/openssf/code_security_and_analysis \
  -d '{"secret_scanning_enabled_for_new_repositories":true,"secret_scanning_push_protection_enabled_for_new_repositories":true}'
'''
Should return "Status 204"


### API Call to Check Exisiting Policies for Verification ##
'''
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <YOUR-TOKEN>" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/enterprises/openssf/code_security_and_analysis
'''

Should return with status 200 and a JSON document with at least these features as true:
'''
  {
  "secret_scanning_enabled_for_new_repositories": true,
  "secret_scanning_push_protection_enabled_for_new_repositories": true
  }
'''

### Example

To do a "dry run" you can run the verification step to verify the setup is working.  There is no way to do a test / dry run of the implementation step, as it will actually implement the change.


with a temporary API TOKEN scoped to only "read:enterprise" in the file named "token":
'''
curl -L -H "Accept: application/vnd.github+json" -H "Authorization: Bearer `cat token`" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/enterprises/openssf/code_security_and_analysis
{
  "advanced_security_enabled_for_new_repositories": false,
  "dependabot_alerts_enabled_for_new_repositories": true,
  "secret_scanning_enabled_for_new_repositories": true,
  "secret_scanning_push_protection_enabled_for_new_repositories": false,
  "secret_scanning_push_protection_custom_link": null
}
'''


