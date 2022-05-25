<#
.Description
This script will automatically promote a Windows Server machine to a domain controller and create a domain

.PARAMETER domain
The domain parameter will be the name of your domain (Required)
.PARAMETER disable
This will disable the automatic start of the server tools when signing in as an admin (Optional)
.PARAMETER static
This will set a static IP address for the server (Optional)
.PARAMETER dns
This will set a DNS forwarder for the DNS server (Optional)

.EXAMPLE
./promoteToDC.ps1 -domain matrix

.EXAMPLE
./promoteToDC.ps1 -domain matrix -disable

.EXAMPLE
./promoteToDC.ps1 -domain matrix -static 192.168.1.2 -gateway 192.168.1.1

.EXAMPLE
./promoteToDC.ps1 -domain matrix -dns 1.1.1.1
#> 

[CmdletBinding()]
Param(
    [switch]$help,
    [switch]$disable,
    [string]$static,
    [string]$gateway,
    [string]$domain,
    [string]$dns
)


# Validate script is being run as an administrator
function checkAdmin(){
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator")){
        Write-Host "[!] ERROR: You are not running this script as an administrator" -ForegroundColor Red
        exit
    }
}


# Validate machine is a Windows Server machine
function checkServerType(){
    $os = (Get-WMIObject win32_operatingsystem).name
    if (-not ($os -like "*Server*")){
        Write-Host "[!] ERROR: This is not a Windows Server operating system" -ForegroundColor Red
        exit
    }
}


# Validate that provided IPs are in the correct format
function validateIPFormat($ip){
    $ipRegEx="\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
    if ($ip -notmatch $ipRegEx){
        Write-Host "[!] ERROR: A provided IP address is in an invalid format" -ForegroundColor Red
        exit
    }
}


# Display list of interfaces and assign static IP to selected interface
function setStaticIP(){
    # Build interface menu
    $adapters = Get-NetAdapter | Select ifIndex, Name
    Write-Host "[*] Displaying list of interfaces available for static IP assignment`n"
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

    # Assign rest of values
    $static = [string]$static
    $gateway = [string]$gateway
    $cidr = "24"
    $dns = "127.0.0.1"
    $ipType = "IPv4"
    
    # Remove all information and assign given IP address and gateway
    Write-Host "[*] Setting the IP address to $static and gateway to $gateway"
    Remove-NetIPAddress -InterfaceIndex $adapter -Confirm:$false
    Remove-NetRoute -InterfaceIndex $adapter -Confirm:$false
    New-NetIPAddress -IPAddress $static -PrefixLength $cidr -InterfaceIndex $adapter -DefaultGateway $gateway -AddressFamily $ipType -ErrorAction Stop | Out-Null
    Set-DNSClientServerAddress –InterfaceIndex $adapter –ServerAddresses $dns -ErrorAction Stop | Out-Null
}


# Disable the automatic starting of the Server Manager at login
function disableServerTools(){
    Write-Host "[*] Disabling automatic startup of Server Manager"
    Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask | Out-Null
}


# Promote the server to a DC and setup domain
function promoteDC(){
    # Disable all the normal warnings when creating a test domain
    $WarningPreference = 'SilentlyContinue'

    <# Sets the DSRM password according to default group policy requirements.
    This is hardcoded to avoid special character escaping issues when passed 
    as a command line parameter as well as to make it entirely automated.
    #>
    $password = 'P@$$w0rd123' | ConvertTo-SecureString -AsPlainText -Force

    # Add necessary roles and create domain
    Write-Host "[*] Installing necessary roles and features (This may take some time)"
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools | Out-Null
    Write-Host "[*] Creating domain of $domain.local and installing DNS"
    Install-ADDSForest -DomainName "$domain.local" -DomainNetBiosName $domain.ToUpper() -InstallDNS -SafeModeAdministratorPassword $password -Force | Out-Null
    if ($dns){
        validateIPFormat($dns)
        Write-Host "[*] Setting up a DNS forwarder of $dns" | Out-Null
        Add-DNSServerForwarder -IPAddress $dns -PassThru
    }
}


# Display Help
function help(){
    $scriptName = split-path $MyInvocation.PSCommandPath -Leaf
    Write-Host "[*] Usage: ./$scriptName -domain <desired domain name> [-disable] [-static <ip> -gateway <gateway IP>]"
    Write-Host "[*] Setup Domain: ./$scriptName -domain matrix"
    Write-Host "[*] Disable Server Manager Auto-start: ./$scriptName -domain matrix -disable"
    Write-Host "[*] Setup Static IP: ./$scriptName -domain matrix -static 192.168.1.2 -gateway 192.168.1.1"
    Write-Host "[*] Setup Static IP: ./$scriptName -domain matrix -dns 1.1.1.1"
    exit
}


# Run script
if ($help){
    help
}
elseif ([string]::IsNullOrEmpty($domain)){
    # TODO: Better error handling for when -domain is passed but there is no value
    Write-Host "[!] ERROR: Required parameter '-domain' missing" -ForegroundColor Red
    help
}
else{
    checkServerType
    checkAdmin
    
    Write-Host ""
    Write-Host "[*] DO NOT CONTINUE UNLESS YOU HAVE TAKEN A SNAPSHOT!"  -ForegroundColor Red
    Write-Host "[*] The computer will automatically reboot when this is completed"
    Read-Host "Press ENTER to continue..."

    if ($static){
        # TODO: Better error handling for when -static is passed but there is no value
        if ([string]::IsNullOrEmpty($gateway)){
            Write-Host "[!] ERROR: '-static' entered but no '-gateway' given" -ForegroundColor Red
            help
        }
        else{
            validateIPFormat($static)
            validateIPFormat($gateway)
            setStaticIP($static, $gateway)
        }
    }
    if ($dns){
        # TODO: Better error handling for when -static is passed but there is no value
        if ([string]::IsNullOrEmpty($dns)){
            Write-Host "[!] ERROR: '-dns' entered but no DNS server given" -ForegroundColor Red
            help
        }
        else{
            validateIPFormat($dns)
        }
    }
    if ($disable){
        disableServerTools
    }
    promoteDC
}