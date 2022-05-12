# Active Directory Lab Creator
This is a series of tools that can be used to automatically setup a lab domain for testing purposes. 

This is NOT a secure domain and should not be used for production environments, only for testing scenarios.
<br>

-----
# promoteToDC
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
