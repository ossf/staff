## Context
A new special interest group Security Baseline SIG was created on July 9th, 2024, to support the adoption of security baseline, logging friction points, removing friction points with automation and tooling development/adoption, evolving the security baseline to be a Linux Foundation wide security baseline. 

The SIG is a venue for cross-Linux foundation collaboration, centering OSS security improvements in OpenSSF. It’s under the BEST Working Group. 

This change request is to [continue the effort](https://github.com/ossf/wg-best-practices-os-developers/issues/562) to establish the infrastructure for community members to collaborate on security baseline.  

## Summary of Changes
The plan is to: 
* Create a new GitHub repo in “ossf” org
* Create GitHub Teams for the new repo access
* Establish members in the teams 
* Validate the above artifacts are created successfully

## Prerequisites
* [Prerequist](https://github.com/ossf/staff/blob/main/operations/github/onboarding/readme.md#prerequisites) in the onboarding readme.md
* PR approved and code merged to main branch for [security_baseline.json](https://github.com/ossf/staff/blob/main/operations/github/onboarding/repo_init_metadata/security_baseline.json)

## Implementer
Dana Wang

## Impacts
This is an isolated change. There is no impact to “ossf” org or the repos under the org.  
Implementation Time
As soon as this plan is approved and merged to main.

## Implementation
[security_baseline.json](https://github.com/ossf/staff/blob/main/operations/github/onboarding/repo_init_metadata/security_baseline.json) contains all the data for the repo setup. 
1. Get the latest code
2. Run below command to
* Create teams, 1 main team  and 2 sub teams with different repo roles
* Add members to different teams, assign them team roles
* Create repo
* Assign teams' access to the repo
* Create a test issue
* Look up all the artifacts created from above and write the search results to security_baseline_results.json
```
./onboarding.sh -prod -i ./repo_init_metadata/security_baseline.json -o ./repo_init_metadata/security_baseline_results.json

```
3. Verify from UI to double check all the artifacts are consistently created as the search results
4. Raise a PR to upload security_baseline_results.json and security_baseline_results_echo.json ( See readme.md) to [initialization metadata folder](https://github.com/ossf/staff/tree/main/operations/github/onboarding/repo_init_metadata).
5. Finsish the change once the above PR is reviewed and merged. 


