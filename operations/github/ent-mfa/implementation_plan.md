## Context
OpenSSF [security baseline](https://github.com/ossf/tac/blob/main/process/security_baseline.md#security-baseline---once-sandbox) requires all technical initiative adopt 2FA in GitHub as part of the [TAC project lifecycle governance](https://github.com/ossf/tac/blob/main/process/project-lifecycle.md#sandbox). 
This requires GitHub two-factor authentication(2FA) to be enabled in the enterprise account to enable 2FA by default for all the organizations and repositories. 

Currently, 2FA is not enabled by default for a few organizations, event though maintainers have enabled 2FA in their accounts. 

## Summary of Changes
The plan is to: 
* Enable authentication security setting: "Require two-factor authentication for all organizations in the Open Source Security Foundation enterprise" 

As of now, GitHub does not provide an API to enable 2FA. This feature needs to be enabled manually through the GitHub user interface.

## Prerequisites
* The implementer needs to have GitHub Enterprise Owner role

## Implementer
Dana Wang

## Implementation Time
August 1, 2024 5PM EST

## Impacts 

The change will have ni impact to 224 of thw 225 members in various OpenSSF GitHub organization. 
![no impact orgs](https://github.com/ossf/staff/blob/f5bb529a91cb013ba6c802cf9b64bc01e5fb2cc9/organizations_not_impacted.png)

It will impact 1 of the 225 members in OpenSSF enterprise unless the member enables 2FA before the change implementation time. The implementer has reached out the member via Slack and email. 

![one member has 2FA disabled](https://github.com/ossf/staff/blob/f5bb529a91cb013ba6c802cf9b64bc01e5fb2cc9/2FA_not_enabled_query_result.png)

![email](https://github.com/ossf/staff/blob/f5bb529a91cb013ba6c802cf9b64bc01e5fb2cc9/Iimpacted_individual_outreach_email.png)

![slack](https://github.com/ossf/staff/blob/f5bb529a91cb013ba6c802cf9b64bc01e5fb2cc9/Iimpacted_individual_outreach_slack.png)

Worst case scenario, if the member is not enabling 2FA by the implementation time, the implementer will coordinate with the member and the member's organization to restore their access and permissions. 
An organization owner can reinstate their access privileges and settings if they enable two-factor authentication for their account within three months of their removal from your organization.
For more information, see "Reinstating a former member of your organization."Members and outside collaborators who will be removed from the organizations owned by your enterprise. The access can be reinstated by setting them  

## Implementation
Publish Announcement first:
1. Log into GitHub.
2. In the top-right corner of GitHub, click your profile photo, then click "Your enterprises".
3. Click "Settings" next to "Open Source Security Foundation" enterprise.
4. Under "Settings", click "Announcement".
5. Fill in all the information as shown in screenshot, then click "Publish Announcement"
   ![announcement](https://github.com/ossf/staff/blob/f5bb529a91cb013ba6c802cf9b64bc01e5fb2cc9/enterprise_annoucnemen_preview.png)
7. Verify announcement published by navigating to personal forked staff repo.

Follow [GitHub instructions](https://docs.github.com/en/enterprise-cloud@latest/admin/enforcing-policies/enforcing-policies-for-your-enterprise/enforcing-policies-for-security-settings-in-your-enterprise#requiring-two-factor-authentication-for-organizations-in-your-enterprise-account) for this change:
   
1. Under "Settings", click "Authentication security".
2. Check the box next to  "Require two-factor authentication for all organizations in the Open Source Security Foundation enterprise".
3. Click "Save".
4. If prompted, read the information about members and outside collaborators who will be removed from the organizations owned by your enterprise.
To confirm the change, type your enterprise's name, then click "Remove members & require two-factor authentication".
Optionally, if any members or outside collaborators are removed from the organizations owned by your enterprise,
we recommend sending them an invitation to reinstate their former privileges and access to your organization. Each person must enable two-factor authentication before they can accept your invitation.
5. Confirm audit log has captured the event 
