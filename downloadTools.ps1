<#
.Description
This script will automatically download tools commonly used in Active Directory enumeration and exploitation

.PARAMETER exclude
The folder parameter will add an exclusion path for Microsoft Defender in the current directory

.EXAMPLE
downloadTools.ps1

.EXAMPLE
downloadTools.ps1 -exclude

#> 

[CmdletBinding()]
Param(
    [switch]$help,
    [switch]$exclude
)


# Check admin and disable defender 
function addExclusion(){
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator")){
        Write-Host "[!] ERROR: You are not running this script as an administrator" -ForegroundColor Red
        Break
    }
    else{
        Write-Host "[*] Adding Windows Defender exclusion path in $pwd"
        Add-MpPreference -ExclusionPath $pwd
    }
}


# Download the tools 
function downloadTools(){
    # TODO: Figure out a way to clean this up given the limitations of Invoke-WebRequest
    Write-Host "[*] Now downloading files to $pwd"
    Invoke-WebRequest -Uri "https://github.com/BloodHoundAD/BloodHound/archive/refs/heads/master.zip" -OutFile $pwd"\BloodHound-master.zip" -UseBasicParsing | Out-Null
    Invoke-WebRequest -Uri "https://go.neo4j.com/download-thanks.html?edition=community&release=4.4.6&flavour=winzip" -OutFile $pwd"\neo4j.4.4.6.zip" -UseBasicParsing | Out-Null
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.10.4/python-3.10.4-amd64.exe" -OutFile $pwd"\python-3.10.4.exe" -UseBasicParsing | Out-Null
    Invoke-WebRequest -Uri "https://github.com/PowerShellMafia/PowerSploit/archive/refs/heads/master.zip" -OutFile $pwd"\powersploit-master.zip" -UseBasicParsing | Out-Null
    Invoke-WebRequest -Uri "https://www.microsoft.com/en-us/download/confirmation.aspx?id=45520&6B49FDFB-8E5B-4B07-BC31-15695C5A2143=1" -OutFile $pwd"\microsoft_rsat.msu" -UseBasicParsing | Out-Null
    Invoke-WebRequest -Uri "https://github.com/fox-it/BloodHound.py/archive/refs/heads/master.zip" -OutFile $pwd"\bloodhound-python.zip" -UseBasicParsing | Out-Null
    Invoke-WebRequest -Uri "https://github.com/dmchell/SharpView/archive/refs/heads/master.zip" -OutFile $pwd"\sharpview-master.zip" -UseBasicParsing | Out-Null
    Invoke-WebRequest -Uri "https://github.com/byt3bl33d3r/CrackMapExec/archive/refs/heads/master.zip" -OutFile $pwd"\crackmapexec-master.zip" -UseBasicParsing | Out-Null
    Invoke-WebRequest -Uri "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.4.1/npp.8.4.1.Installer.x64.exe" -OutFile $pwd"\npp.8.4.1.exe" -UseBasicParsing | Out-Null
    Invoke-WebRequest -Uri "https://github.com/BloodHoundAD/SharpHound/releases/download/v1.0.3/SharpHound-v1.0.3.zip" -OutFile $pwd"\sharphound-v1.0.3.zip" -UseBasicParsing | Out-Null
}


# Display Help
function help(){
    $scriptName = split-path $MyInvocation.PSCommandPath -Leaf
    Write-Host "[*] This script will automatically download tools commonly used in Active Directory enumeration and exploitation"
    Write-Host "[*] Basic Usage: ./$scriptName"
    Write-Host "[*] Add Defender Exclusion: ./$scriptName -exclude"
}


# Run script
if ($help){
    help
}
else{
    if ($exclude){
        addExclusion
    }
    downloadTools
}