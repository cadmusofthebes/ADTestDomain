<#
.Description
This script will automatically join a Windows 10 machine to a previously configured domain

.PARAMETER domain
The domain parameter will be the name of the domain you are attempting to join

.PARAMETER user
The user parameter is the name of a user who has domain admin rights

.PARAMETER dns
The dns parameter is the ip address of the domain controller

.EXAMPLE
joinToDomain.ps1 -domain matrix -user neo -dns 192.168.10.1
#> 

[CmdletBinding()]
Param(
    [switch]$help,
    [string]$domain,
    [string]$user,
    [string]$dns
)


# Set the DNS Server to that of the Domain Controller
function setDNS(){
    $dns = [string]$dns
    $adapter = (Get-NetAdapter).InterfaceIndex
    $ipRegEx="\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
    if ($dns -notmatch $ipRegEx){
        Write-Host "[!] ERROR: Domain Controller IP address is in an invalid format" -ForegroundColor Red
        exit
    }
    else{
        Write-Host "[*] Setting the DNS server to the IP address of the domain controller"
        Set-DNSClientServerAddress –InterfaceIndex $adapter –ServerAddresses $dns | Out-Null
    }
}


# Join the computer to the domain
function joinDomain(){
    Write-Host "[*] DO NOT CONTINUE UNLESS YOU HAVE RENAMED YOUR MACHINE AND TAKEN A SNAPSHOT!"  -ForegroundColor Red
    Read-Host "Press ENTER to continue..."
    
    $password = Read-Host -Prompt "Enter password for $user" -AsSecureString
    $credential = New-Object System.Management.Automation.PSCredential($user,$password) 
    Add-Computer -domainname $domain -Credential $credential
}


# Display Help
function help(){
    $scriptName = split-path $MyInvocation.PSCommandPath -Leaf
    Write-Host "[*] This script will automatically join a Windows 10 machine to a previously configured domain"
    Write-Host "[*] Usage: ./$scriptName -domain <existing domain> -user <domain admin> -dns <IP of domain controller>"
    Write-Host "[*] Example: ./$scriptName -domain matrix -user neo -dns 192.168.10.1"
}


# Run script
if ($help){
    help
}
elseif ([string]::IsNullOrEmpty($domain) -or [string]::IsNullOrEmpty($user) -or [string]::IsNullOrEmpty($dns)){
    Write-Host "[!] ERROR: Required parameter is missing" -ForegroundColor Red
    help
}
else{
    setDNS
    joinDomain
}
