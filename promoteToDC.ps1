[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true)]
    [string]$domain
    )

# Disable all the normal warnings when creating a test domain
$WarningPreference = 'SilentlyContinue'

# Remind user to take a snapshot before running
Write-Host "[!] DO NOT CONTINUE UNLESS YOU HAVE TAKEN A SNAPSHOT!"  -ForegroundColor Red
read-host “Press ENTER to continue...”

<# Sets the DSRM password according to default group policy requirements.
This is hardcoded to avoid special character escaping issues when passed 
as a command line parameter as well as make it entirely automated.
#>
$password = 'P@$$w0rd123' | ConvertTo-SecureString -AsPlainText -Force

# Disable the loading of the server manager tool automatically at login
Write-Host "[*] Disabling automatic startup of Server Manager"
Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose

# Install the AD DS role along with management tools such as RSAT
Write-Host "[*] Installing necessary roles and features"
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Create the forest and domain
Write-Host "[*] Creating domain of $domain.local"
Install-ADDSForest -DomainName "$domain.local" -DomainNetBiosName $domain.ToUpper() -InstallDNS -SafeModeAdministratorPassword $password -Force
