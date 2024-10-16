
# Active Directory PowerShell Toolkit

> A simple set of PowerShell scripts to assist with Active Directory auditing, automations, Identity and Access Management, and more. 


`All of the scripts in this toolkit are written so they can be ran individually`


### Scripts in this toolkit (Will be updated as new scripts are added)


* ## $${\color{lightblue}Audit}$$

    - **AD-StaleAccountsAudit** - Finds user accounts that do not require a password to sign in 

    - **AD-StaleAccountsAudit** - Locates stale accounts in AD by looking for PasswordLastChanged and LastLogonTimestamp

    - **AD-StaleAccountsAudit2** - Locates stale accounts in AD by using the Search-ADUser -AccountInactive command 

    - **AD-ExpiredPasswordsAudit** - Provides a list of users with expired passwords 

    #### $${\color{darkblue}Group Memberships}$$ 

    - **AD-GroupMembers-All** - Provides a list of members for a specific group (includes all members)

    - **AD-GroupMembers-Users** - Provides a list of members for a specific group (users only)

    - **AD-GroupMembers-Nested** - Provides a list of members for a specifi group (nested groups only)

    - **AD-RemoveUserGroupMemberships** - Takes a list of users and removes their group memberships. Great for quick permissions cleanup on disabled users. 


    #### $${\color{darkblue} OU Memberships}$$

    - **AD-GetOUMembersALL** - Provies a list of members for a specific OU 


* ## $${\color{lightblue}Forensics}$$

   - **AD-PasswordChange-Initiated-Audit** - Checks the last password change attempts for a user and displays the admin that initiated the change. 


* ## $${\color{lightblue}Incident Response}$$

    - **AD-BulkDisable.ps1** - Takes a list of users from a CSV and disables them 

    - **AD-BulkPasswordReset.ps1** - Takes a list of users from a CSV and changes their passwords (randomly generates a 10 character password for each)
   

* ## $${\color{lightblue}Entra}$$

    - **ENTRA-GetUserLicenses** - Provides a list of users and their assigned licenses from Entra 

    - **Entra-GetUserProxyAddresses** - Shows all proxy addresses for a specific user 


* ## $${\color{lightblue}Other}$$

    - **AD-AddMobilePhone** - Fill out mobile phone information for a list of users (must have a CSV with the required information) 


