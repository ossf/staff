## Context
OpenSSF [security baseline](https://github.com/ossf/tac/blob/main/process/security_baseline.md#security-baseline---once-sandbox) requires all technical initiative adopt 2FA in GitHub as part of the [TAC project lifecycle governance](https://github.com/ossf/tac/blob/main/process/project-lifecycle.md#sandbox). 
This requires GitHub two-factor authentication(2FA) to be enabled in the enterprise account to enable 2FA by default for all the organizations and repositories. 

Currently, 2FA is not enabled by default for a few organizations, event though mainytainers may have been selected to enable 2FA by GitHub. 

## Summary of Changes
The plan is to: 
* Enable authentication security setting: "Require two-factor authentication for all organizations in the Open Source Security Foundation enterprise" 

As of now, GitHub does not provide an API to enable 2FA. This feature needs to be enabled manually through the GitHub user interface.

## Prerequisites
* The implementer needs to have GitHub Enterprise Owner role

## Implementer
Dana Wang

## Impacts
The change will have these impacts:
* Members and outside collaborators who do not use 2FA will be removed from the organization and lose access to its repositories.
They will also lose access to their forks of the organization's private repositories.
* Any organization owner, member, billing manager, or outside collaborator in any of the organizations owned by your enterprise who disables 2FA for their account after you've enabled required two-factor authentication
will automatically be removed from the organization.

An organization owner can reinstate their access privileges and settings if they enable two-factor authentication for their account within three months of their removal from your organization.
For more information, see "Reinstating a former member of your organization."Members and outside collaborators who will be removed from the organizations owned by your enterprise. The access can be reinstated by setting them  

## Implementation
Follow [GitHub instructions](https://docs.github.com/en/enterprise-cloud@latest/admin/enforcing-policies/enforcing-policies-for-your-enterprise/enforcing-policies-for-security-settings-in-your-enterprise#requiring-two-factor-authentication-for-organizations-in-your-enterprise-account) for this change:
1. Log into GitHub.
2. In the top-right corner of GitHub, click your profile photo, then click "Your enterprises".
3. Click "Settings" next to "Open Source Security Foundation" enterprise.
4. Under "Settings", click "Authentication security".
5. Check the box next to  "Require two-factor authentication for all organizations in the Open Source Security Foundation enterprise".
6. Click "Save".
7. If prompted, read the information about members and outside collaborators who will be removed from the organizations owned by your enterprise.
To confirm the change, type your enterprise's name, then click "Remove members & require two-factor authentication".
Optionally, if any members or outside collaborators are removed from the organizations owned by your enterprise,
we recommend sending them an invitation to reinstate their former privileges and access to your organization. Each person must enable two-factor authentication before they can accept your invitation.
