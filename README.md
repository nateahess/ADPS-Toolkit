![header-image](https://github.com/nateahess/ADPS-Toolkit/blob/main/Resources/Header-image2.PNG)

# Active Directory PowerShell Toolkit

> A simple set of PowerShell scripts to assist with Active Directory auditing, automations, Identity and Access Management, and more. 


`All of the scripts in this toolkit are written so they can be ran individually`


### Scripts in this toolkit (Will be updated as new scripts are added)

* ### Forensics

   - **AD-PasswordChange-Initiated-Audit** - Checks the last password change attempts for a user and displays the admin that initiated the change. 

* ### Stale Accounts

    - **AD-StaleAccountsAudit** - Locates stale accounts in AD by looking for PasswordLastChanged and LastLogonTimestamp


* ### Group Memberships

    - **AD-GroupMembers-All** - Provides a list of members for a specific group (includes all members)

    - **AD-GroupMembers-Users** - Provides a list of members for a specific group (users only)

    - **AD-GroupMembers-Nested** - Provides a list of members for a specifi group (nested groups only)

    - **AD-RemoveUserGroupMemberships** - Takes a list of users and removes their group memberships. Great for quick permissions cleanup on disabled users. 

* ### OU Memberships

    - **AD-GetOUMembersALL** - Provies a list of members for a specific OU 


* ### Other

    - **AD-AddMobilePhone** - Fill out mobile phone information for a list of users (must have a CSV with the required information) 


