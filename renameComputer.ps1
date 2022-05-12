<#
.Description
This script will rename a computer to the desired name.

.PARAMETER name
The name parameter is the new name you want for the computer

.EXAMPLE
renameComputer.ps1 -name nebuchadnezzar
#> 

[CmdletBinding()]
Param(
  [string]$name
)


# Validate script is being run as an administrator
function checkAdmin(){
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator")){
        Write-Host "[!] ERROR: You are not running this script as an administrator" -ForegroundColor Red
        Break
    }
}


# Rename the computer
function renameComputer(){
    Write-Host "[*] Renaming computer to $name"
    Rename-computer -NewName $name
}


# Display Help
function help(){
    $scriptName = split-path $MyInvocation.PSCommandPath -Leaf
    Write-Host "[*] Usage: ./$scriptName -name <new computer name>"
    Write-Host "[*] Example: ./$scriptName -name nebuchadnezzar"
    exit
}


# Run script
if ($help){
    help
}
elseif ([string]::IsNullOrEmpty($name)){
    # TODO: Better error handling for when -name is passed but there is no value
    Write-Host "[!] ERROR: Required parameter '-name' missing" -ForegroundColor Red
    help
}
else{
    checkAdmin
    renameComputer
}
