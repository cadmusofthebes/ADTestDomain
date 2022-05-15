<#
.Description
This script will automatically join a Windows 10 machine to a previously configured domain

.PARAMETER domain
The domain parameter will be the name of the domain you are attempting to join
.PARAMETER user
The user parameter is the name of a user who has domain admin rights
.PARAMETER dc
The dc parameter is the ip address of the domain controller

.EXAMPLE
joinToDomain.ps1 -domain matrix -user neo -dc 192.168.10.1
#> 

[CmdletBinding()]
Param(
    [switch]$help,
    [string]$domain,
    [string]$user,
    [string]$dc
)


# Validate script is being run as an administrator
function checkAdmin(){
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator")){
        Write-Host "[!] ERROR: You are not running this script as an administrator" -ForegroundColor Red
        Break
    }
}


# Display list of interfaces and set the DNS Server to that of the Domain Controller
function setDNS(){
    $dns = [string]$dns

    # Build interface menu
    $adapters = Get-NetAdapter | Select ifIndex, Name
    Write-Host "[*] Displaying list of interfaces available to modify DNS on`n"
    Write-Host "================"
    $menu = @{}
    for ($i=1; $i -le ($adapters | Measure-Object).Count; $i++){
        Write-Host "$i. $($adapters[$i-1].name)"
        $menu.Add($i,($adapters[$i-1].ifIndex))
    }
    # Prompt user to select interface
    Write-Host "================`n"
    [int]$selection = Read-Host "[+] Choose which adapter to update"
    while ($selection -lt ($adapters | Measure-Object).Count -or $selection -gt ($adapters | Measure-Object).Count){
        Write-Host "[!] ERROR: Selection is invalid"
        [int]$selection = Read-Host "[+] Choose which adapter to update"
    }
    # Assign requested interface
    $adapter = $menu.Item($selection)

    # Validate format of given DNS server
    $ipRegEx="\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
    if ($dc -notmatch $ipRegEx){
        Write-Host "[!] ERROR: Domain Controller IP address is in an invalid format" -ForegroundColor Red
        exit
    }
    # Assign given DNS address to selected interface
    else{
        Write-Host "[*] Setting the DNS server to $dc"
        Set-DNSClientServerAddress –InterfaceIndex $adapter –ServerAddresses $dc | Out-Null
    }
}


# Join the computer to the domain
function joinDomain(){
    Write-Host "[*] DO NOT CONTINUE UNLESS TAKEN A SNAPSHOT!"  -ForegroundColor Red
    Write-Host "[*] The computer will automatically reboot when this is completed"
    Read-Host "Press ENTER to continue..."
    
    $password = Read-Host -Prompt "Enter password for $user" -AsSecureString
    $credential = New-Object System.Management.Automation.PSCredential($user,$password)
    try{
        Write-Host "[*] Attempting to join domain $domain on domain controller $dc"
        Add-Computer -domainname $domain -Credential $credential -ErrorAction Stop | Out-null
    }
    catch{
        Write-Host "[!] ERROR: Failed to add computer to domain. Validate that you can connect to the domain controller and the password is correct" -ForegroundColor Red
    }
}


# Display Help
function help(){
    $scriptName = split-path $MyInvocation.PSCommandPath -Leaf
    Write-Host "[*] This script will automatically join a Windows 10 machine to a previously configured domain"
    Write-Host "[*] Usage: ./$scriptName -domain <existing domain> -user <domain admin> -dc <IP of domain controller>"
    Write-Host "[*] Example: ./$scriptName -domain matrix -user neo -dc 192.168.10.1"
}


# Run script
if ($help){
    help
}
elseif ([string]::IsNullOrEmpty($domain) -or [string]::IsNullOrEmpty($user) -or [string]::IsNullOrEmpty($dc)){
    Write-Host "[!] ERROR: Required parameter is missing" -ForegroundColor Red
    help
}
else{
    checkAdmin
    setDNS
    joinDomain
}