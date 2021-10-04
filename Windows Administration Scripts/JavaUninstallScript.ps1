$RegUninstallPaths = @(
'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall')
$VersionsToKeep = @('Java(TM) 6 Update 12', 'Java(TM) 6 Update 13', 'Java(TM) 6 Update 20 (64-bit)', 'Java(TM) 6 Update 25 (64-bit)')
 
Get-WmiObject -ClassName 'Win32_Process' | Where-Object {$_.ExecutablePath -like '*Program Files\Java*'} | 
    Select-Object @{n='Name';e={$_.Name.Split('.')[0]}} | Stop-Process -Force
 
get-process -Name *iexplore* | Stop-Process -Force -ErrorAction SilentlyContinue
 
$UninstallSearchFilter = {($_.GetValue('DisplayName') -like '*Java*') -and ($VersionsToKeep -notcontains $_.GetValue('DisplayName'))}
 
# Uninstall unwanted Java versions and clean up program files
 
foreach ($Path in $RegUninstallPaths) {
    if (Test-Path $Path) {
        Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
       ForEach-Object { 
           
        Start-Process -Filepath 'C:\Windows\System32\msiexec.exe' "/X$($_.PSChildName) /qn" -Wait
    
        }
    }
}
 
<#

New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
$ClassesRootPath = "HKCR:\Installer\Products"
Get-ChildItem $ClassesRootPath | 
    Where-Object { ($_.GetValue('ProductName') -like '*Java*')} | Foreach {Remove-Item $_.PsPath -Force -Recurse}
 
 
$JavaSoftPath = 'HKLM:\SOFTWARE\JavaSoft'
if (Test-Path $JavaSoftPath) {
    Remove-Item $JavaSoftPath -Force -Recurse
}

#>