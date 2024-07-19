## Summary
The scripts in this folder are for onboarding a new project to "ossf" org. 

onboarding.sh does all the work. To run the script from your local machine, clone the repo first. 
```
./onboarding.sh -test -i ./repo_init_metadata/security_baseline_test.json -o ./repo_init_metadata/security_baseline_test_results.json

-i expects a JSON file that contains the metadata for the new repo, teams structure, members in each team, teams' permission and members' role in each team
-o creats a file that contains the details of all the artifcats created.
-test is for testing using your own organization setup outside of OpenSSF enterprise account.
-prod is for onboarding a project to "ossf" org
```
"repo_init_metadata" directory contains the metadata to describe all the attributes/properties of the new repo you are creating using "ossf/projet-template".

Naming convention
* <repo_name>.json  decribe all things about this new repo in "ossf" org
* <repo_name>_test.json decribe all things about your test repo that SHOULD be outside of OpenSSF enterprise. There are situations your personal account is not sufficient for testing.  
* <repo_name>_test_results.json contains the lookup results after artifacts are created based on <repo_name>.json
* <repo_name>_test_echo.txt contains the shell script echo

## Prerequisites
To run the scripts, these conditions need to be met:
#### Access Requirements
* Organization Owner role in OpenSSF GitHub “ossf” org.
* PAT with repo admin access and it needs to be an organization scope
#### Repository Template
* "ossf/project-template" 
#### Teams policy
* [TAC policy on naming of teams, repos](https://github.com/ossf/tac/blob/main/policies/access.md)

#### Constraints
This script was develpped to avoid manual errors. It works but it needs enhacnements through issues and PR's. 



