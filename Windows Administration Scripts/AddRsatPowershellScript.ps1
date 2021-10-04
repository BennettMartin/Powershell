# Script sourced from http://woshub.com/install-rsat-feature-windows-10-powershell/

# Disables updating from WSUS server before installing RSAT and enables it after
# Attempting to install RSAT without disabling WSUS causes issues and incomplete installations
$currentWU = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | Select-Object -ExpandProperty UseWUServer

Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0

Restart-Service wuauserv

Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online

Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $currentWU

Restart-Service wuauserv