# Active Directory Lab Creator
This is a series of tools that can be used to automatically setup a lab domain for testing purposes. 

This is NOT a secure domain and should not be used for production environments, only for testing scenarios.
<br>

-----
# promoteToDC.ps1
This script will autmoatically promote a Windows Server 2016/2019 to a domain controller and setup a new Forest and Domain with the provided information. The final domain will be in the format of [domain].local. 

It will also hardcode a DSRM password of ``P@$$w0rd123``, but you can change this in the code before you run it if desired.

The basic usage of the tool is:
```powershell
promoteToDC.ps1 -domain [desired domain name]
``` 

Additionally, it has a few optional parameters that can be passed which allow you to automate a few other common tasks:

\- You can provide a static IP and gateway with the following. This will also set the DNS server as 127.0.0.1:
```powershell
promoteToDC.ps1 -domain [desired domain name] -static [ip] -gateway [ip]
```

\- You can disable the auto-start of the Server Manager at login with the following:
```powershell
promoteToDC.ps1 -domain [desired domain name] -disable
```

\- You can access the help menu with:
```powershell
Get-Help promoteToDC.ps1
Get-Help promoteToDC.ps1 -Examples
```
<br>

-----
# renameComputer.ps1
This script will rename a computer to a desired name. Note that you will need to launch an elevated powershell session (admin) in order to perform this function.

The basic usage of the tool is:
```powershell
renameComputer.ps1 -name [new computer name]
```

On most Windows 10 machines, the execution policy is enabled which prevents the running of scripts. Attempting to run this will result in the following error:
```
.\renameComputer.ps1 : File C:\Users\Admin\Documents\renameComputer.ps1 cannot be loaded because running scripts is
disabled on this system. For more information, see about_Execution_Policies at
https:/go.microsoft.com/fwlink/?LinkID=135170.
At line:1 char:1
+ .\renameComputer.ps1
+ ~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

You can bypass this by running the script as follows:
```powershell
PowerShell.exe -ExecutionPolicy Bypass -File .\renameComputer.ps1 -name [new computer name]
```
