# Active Directory Lab Creator
This is a series of tools that can be used to automatically setup a lab domain for testing purposes. 

This is NOT a secure domain and should not be used for production environments, only for testing scenarios.

All these scripts require administrative access to run correctly due to the modification of adapter settings and installing features.

The recommended order of the scripts are:
1. renameComputer.ps1 (All VMs)
2. promoteToDC.ps1 (Windows Server)
3. joinToDomain.ps1 (Windows 10)
4. downloadTools.ps1 (Attacking Windows machine)

You can access the help menu for any tool with with:
```powershell
Get-Help <script>.ps1
<script>.ps1 -help
```

You can display examples on any script with:
```powershell
Get-Help promoteToDC.ps1 -Examples
```
<br>

-----
# Windows 10 and Execution Policy
On most Windows 10 machines, the execution policy is enabled which prevents the running of scripts (or Get-Help on those scripts). Attempting to run this will result in the following error:
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

You can do one of two things in an elevated console:
1. Bypass this on one script:
```powershell
PowerShell.exe -ExecutionPolicy Bypass -File .\renameComputer.ps1 -name [new computer name]
```

2. Modify the execution policy:
```powershell
Set-ExecutionPolicy Unrestricted
```
<br>

-----
# renameComputer.ps1
This script will rename a computer to a desired name. 

It is recommended to run this script first on each machine so that everything in the domain has the name you want prior to setting up the domain. This change requires a reboot to take effect and none of the other below scripts can be run until the reboot is completed.

The basic usage of the tool is:
```powershell
renameComputer.ps1 -name [new computer name]
```
<br>

-----
# promoteToDC.ps1
This script will automatically promote a Windows Server 2016/2019 to a domain controller and setup a new Forest and Domain with the provided information. The final domain will be in the format of [domain].local. 

It also has a hardcoded DSRM (Directory Services Restore Mode) password of ``P@$$w0rd123``, but you can change this in the code before you run it if desired.

The basic usage of the tool is:
```powershell
promoteToDC.ps1 -domain [desired domain name]
``` 

Additionally, it has a few optional parameters that can be passed which allow you to automate a few other common tasks.

\- You can provide a static IP and gateway with the ``-static`` and ``-gateway`` parameters. When given, the script will take the following actions:
- Display a list of interfaces connected to your VM and allow you to choose which one you wish to apply it to
- Remove the old IP address and gateway
- Set the given IP address and gateway
- Set the DNS server as 127.0.0.1
```powershell
promoteToDC.ps1 -domain [desired domain name] -static [ip] -gateway [ip]
```

\- You can disable the auto-start of the Server Manager at login with the following:
```powershell
promoteToDC.ps1 -domain [desired domain name] -disable
```
<br>

-----
# joinToDomain.ps1
This script will take a Windows 10 machine and perform the following actions:
- Set the DNS server to that of the domain controller
- Join it to the domain

The basic usage of the tool is:
```powershell
joinToDomain.ps1 -domain [domain name] -user [domain admin] -dc [IP address of the domain controller]
```
<br>

-----
# downloadTools.ps1
This script will download a number of commonly used tools for Active Directory enumeration and exploitation.

The current list of tools are:
- Bloodhound Tools
    - Bloodhound
    - Sharphound Ingestor
    - Bloodhound Python Ingestor
    - Neo4j
- CrackMapExec (CME)
- Powershell Remote System Administration Tools (RSAT)
- PowerSploit
- SharpView
- Notepad++
- Python3

The basic usage of this tool is:
```powershell
downloadTools.ps1
```

A few of these tools will trigger Windows Defender and be deleted at download. To prevent this, you can use the optional ``-exclude`` parameter which will add an exclusion path for the current directory. Doing so will require an elevated powershell session:
```powershell
downloadTools.ps1 -exclude
```