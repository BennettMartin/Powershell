# Registry paths where the entries for x86 and x64 programs are stored, respectively
$RegUninstallPaths = @(
'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall')

# String for the version number of the desired version. Variable is cast to [System.Version] type in order to
# properly parse the string
[System.Version]$RequiredVersion = '1.1.1'

# The location of the installer and the arguments for silent install
$UpdateProgramPath = '\\path\to\file\location'
$UpdateProgramArgs = '/example /install /args' #Example /qn

# Stops Windows prompts asking if you trust the script
$env:SEE_MASK_NOZONECHECKS = 1

# Checks for running instances of the program to update and closes them
$ProgramLocation = '*Program Data\ProgramFolderName*'
Get-WmiObject -ClassName 'Win32_Process' | Where-Object {$_.ExecutablePath -like $ProgramLocation} | 
    Select-Object @{n='Name';e={$_.Name.Split('.')[0]}} | Stop-Process -Force

# Stops running instances of related programs that might interfere with uninstall process
$RunningPrograms = *exampleprogram*
get-process -Name $RunningPrograms | Stop-Process -Force -ErrorAction SilentlyContinue

# Search filter for Where-Object. Finds programs with names similiar to the desired program that don't have the correct
# version or newer
$ProgramRegistryName = '*eClinicalWorks*'
$UninstallSearchFilter = {($_.GetValue('DisplayName') -like $ProgramRegistryName) -and ([System.Version]$_.GetValue('DisplayVersion') -lt $RequiredVersion)}

# Initializes a counter variable
$ProgramPresentCount = 0

# For loop that tests each Registry install folder for installs of the desired program. Uninstalls each version
# that is older than the requested version. Keeps count of
# how many were uninstalled
$MSIExecPath = 'C:\Windows\System32\msiexec.exe'
$UninstallString = "/X$($_.PSChildName) /qn"
foreach ($Path in $RegUninstallPaths) {
    if (Test-Path $Path) {
        Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
       ForEach-Object { 
           
        Start-Process -Filepath $MSIExecPath $UninstallString -Wait
        
        $ProgramPresentCount += 1
        }
    }
}

# If statement that checks if at least one version of the desired program was uninstalled and installs the requested version if true
if ($ProgramPresentCount.Count -ge 1) {
    Start-Process -FilePath $UpdateProgramPath -ArgumentList $UpdateProgramArgs -Wait
}
