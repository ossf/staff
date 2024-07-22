# Secret Scanning policy implementation #


Process and code (API calls) for implementing secret scanning and push protection for secrets at the enterprise level in the OpenSSF ententerprise.

Based upon the documentation: https://docs.github.com/en/enterprise-cloud@latest/rest/enterprise-admin/code-security-and-analysis?apiVersion=2022-11-28#update-code-security-and-analysis-features-for-an-enterprise

These are intended to be run as individual CLI calls (with proper handling of the API token -- replacing the "<YOUR-TOKEN>" string), run after review for correctness and as a means to avoid human error in the GUI.  
The token used should be scoped to have the "admin:enterprise" permission for implementation and "read:enterprise" for verification.


## Implementation ##
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


## Verification ##
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

### Dry Run

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


