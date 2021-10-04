# Stops Windows prompts asking if you trust the script
$env:SEE_MASK_NOZONECHECKS = 1

# Script to automate installs of software for APH Windows 10 initial install.

[xml]$configXML = Get-Content -Path '\\path\to\xml.xml'
$requiredAppsXML =  $configXML.scriptdata.required.applist.app
$requiredArgsXML = $configXML.scriptdata.required.installers.args
$OptionalApp1XML = $configXML.scriptdata.additionalapps.applist.Sample
$OptionalArgs1XML = $configXML.scriptdata.additionalapps.args.Sample
$OptionalApp2XML = $configXML.scriptdata.sample.applist.app
$OptionalArgs2XML = $configXML.scriptdata.sample.installers.args
$Optional2TempPaths = $configXML.scriptdata.sample.installerpath.path
$OptionalApp3XML = $configXML.scriptdata.sample.applist.app
$OptionalArgs3XML = $configXML.scriptdata.sample.installers.args
$OptionalApp4XML = $configXML.scriptdata.sample.section.applist.app
$OptionalArgs4XML = $configXML.scriptdata.sample.section.installers.args
$OptionalApp5XML = $configXML.scriptdata.sample.section.applist.app
$OptionalArgs5XML = $configXML.scriptdata.sample.section.installers.args





<# 
Class for objects that store information needed for installs. The different properties
needed for Start-Process are stored as individual properties, and can be called by their
methods.
#>
Class InstallerInfo
{
    # Properties
    [String] $InstallerPath
    [String] $InstallerArgs
    [String] $ProgramName

    #Parameterless Constructor
    InstallerInfo ()
    {
    }

    # Constructor
    InstallerInfo ([String] $InstallerPath, [String] $InstallerArgs, [String] $ProgramName)
    {
        $this.InstallerPath = $InstallerPath
        $this.InstallerArgs = $InstallerArgs
        $this.ProgramName = $ProgramName
    }

    # Methods
    [String] getInstallerPath()
    {
        return $this.InstallerPath
    }
    
    [String] getInstallerArgs()
    {
        return $this.InstallerArgs
    }
    
    [String] getProgramName()
    {
        return $this.ProgramName
    }
}


<# 
Main script function. Creates 2 variables to hold the lists of installed programs and installer objects so they can be
iterated over and calls functions to perform tasks.
#>
function installApplications {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Object[]]
        $AppList,

        [Parameter()]
        [Object[]]
        $AppArgs
    )
    $installerObjects = (objectInitializer -AppList $AppList -AppArgs $AppArgs)
    runInstallers -Installers $installerObjects
    $installChecklist = (getInstalls -ProgramList $AppList -ObjectList $installerObjects)
    checkInstalls -ProgramList $installChecklist
}



# Function to copy installer for programs that need it to a temp folder to avoid security warning pop-up during installation.
# Can probably be avoided by adding $env:SEE_MASK_NOZONECHECKS = 1
function setupTempFolder {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]$FolderPath,

        [Parameter()]
        [Object[]]
        $FilePath
    )
    New-Item -Path $FolderPath -ItemType Directory
    Copy-Item -Path $FilePath -Destination $FolderPath
}

# Function to delete the temp folder.
function deleteTempFolder {
    param (
        [Parameter()]
        [String]$FolderPath
    )
    Remove-Item -Path $FolderPath -Recurse -Force
}


<#
Function to create objects to hold install information.
#> 
function objectInitializer {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Object[]]
        $AppList,

        [Parameter()]
        [Object[]]
        $AppArgs
    )
    $arrayIndex = 0
    $installerObjects = @()
    ForEach ($installer in $AppList) {
        $installerArgs = $AppArgs | Select-Object -Index $arrayIndex
        $splitArgs = $installerArgs -Split ",, "
        $installer = New-Object InstallerInfo -ArgumentList $splitArgs
        $installerObjects += $installer
        $arrayIndex += 1
    }
    Return $installerObjects
}


# Function to check if a program is installed. Modified version of script from https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/reading-installed-software-from-registry
function Confirm-Install {
    param
    (
        [string]
        $DisplayName='*'
    )

    $keys = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 
            'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    
    Get-ItemProperty -Path $keys | 
      Where-Object { $_.DisplayName } |
      Select-Object -Property DisplayName, DisplayVersion |
      Where-Object { $_.DisplayName -like $DisplayName }
}

<#
Function to create an array object to iterate over for functions that iterate over two indexed
lists, e.g. installApplications and getInstalls.
#>
function getAppNames {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Object[]]
        $NamePath
    )
    $appArray = @()
    $xmlIndex = 0
    ForEach ($app in $NamePath) {
        $app = $NamePath[$xmlIndex]
        $appArray += $app
        $xmlIndex += 1
    }

    return $appArray
}
<#
Function to create an array of arguments for the application installs from the information stored in 
the XML file.
#>
function getAppArgs {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Object[]]
        $AppArray,

        [Parameter()]
        [Object[]]
        $ArgsPath
    )
    $configArray = @()
    $xmlIndex = 0
    ForEach ($config in $appArray) {
        $appArgs = $ArgsPath[$xmlIndex]
        $configArray += $appArgs
        $xmlIndex += 1
    }

    return $configArray
}

<#
Function to install applications. Iterates over the list in the $Installers parameter, the list needs
to contain only objects of the InstallerInfo class.
#>
function runInstallers {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Object[]]
        $Installers
    )
    ForEach ($installerInfo in $Installers) {
        Start-Process -FilePath $installerInfo.getInstallerPath() -ArgumentList $installerInfo.getInstallerArgs() -Wait
        Confirm-Install -DisplayName $installerInfo.getProgramName() | Format-Table
    }
}

<#
Creates a list of app install names from the $ProgramName properties of a list of InstallerInfo objects.
Meant to be fed into the checkInstalls function.
#>
function getInstalls {
    param (
        [Parameter()]
        [object[]]
        $ProgramList,

        [Parameter()]
        [object[]]
        $ObjectList
    )
    $objectIndex = 0
    $installList = @()
    ForEach ($program in $ProgramList) {
        $programObject = $ObjectList | Select-Object -Index $objectIndex
        $searchName = $programObject.getProgramName()
        $installList += $searchName
        $objectIndex += 1
    }
    return $installList
}

<#
Iterates over a list of install names with the Confirm-Install function to check
if an application installed correctly.
#>
function checkInstalls {
    
    param (
        [Parameter()]
        [object[]]
        $ProgramList
    )

    $allInstalls = @()
    ForEach ($program in $ProgramList) {
        $confirmedInstall = Confirm-Install -DisplayName $program
        $allInstalls += $confirmedInstall
    }
    $allInstalls | Format-Table
    Read-Host -Prompt 'Press enter to continue'
}

<#
Function to display a text menu.
#>
Function Invoke-Menu {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "Enter the menu text")]
        [ValidateNotNullOrEmpty()]
        [string]$Menu,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Title = "Install Menu",
        
        [Alias("cls")]
        [switch]$ClearScreen
    )

    # Clears the shell screen if chosen
    if ($ClearScreen) {
        Clear-Host
    }

    # Creates the menu
    $menuScreen = $Title
    $menuScreen += "`n"
    $menuScreen += "-"*$Title.Length
    $menuScreen += "`n"
    $menuScreen += $Menu

    Read-Host -Prompt $menuScreen
}


<#
Function to display a menu and handle choices for additional applications
not included in the default application install.
#>
function Invoke-AdditionalApps {
    Do {
        Switch (Invoke-Menu -Menu $additionalAppsMenu -Title "Additional Apps" -Clear) {
            "1" {
                Write-Host "`n`nInstalling Optional App 1" -ForegroundColor Green
                Start-Sleep -Seconds 1
                $appsToInstall = getAppNames -NamePath $OptionalApp1XML
                $argsToInstall = getAppArgs -AppArray $appsToInstall -ArgsPath $OptionalArgs1XML
                installApplications -Applist $appsToInstall -AppArgs $argsToInstall
                Start-Sleep -Seconds 1
            }
            "2" {
                Invoke-OptionalApps45
            }
            "Q" {
                Write-Host "`n`nExiting Menu" -ForegroundColor Red
                Start-Sleep -Seconds 1
                Clear-Host
                Return
            }
            Default {
                Write-Host "`n`nInvalid choice. Please choose an option listed on the menu."
                Start-Sleep -Seconds 3
            }
        }
    } While ($True)  
}

function Invoke-OptionalApps45 {
    Do {
        Switch (Invoke-Menu -Menu $OptionalApps45Menu -Title "Optional Apps 4 & 5" -Clear) {
            "1" {
                Write-Host "`n`nInstalling Optional App 4" -ForegroundColor Green
                Start-Sleep -Seconds 1
                $appsToInstall = getAppNames -NamePath $OptionalApp4XML
                $argsToInstall = getAppArgs -AppArray $appsToInstall -ArgsPath $OptionalArgs4XML
                installApplications -Applist $appsToInstall -AppArgs $argsToInstall
                Start-Sleep -Seconds 1
            }
            "2" {
                Write-Host "`n`nInstalling Optional App 5" -ForegroundColor Green
                Start-Sleep -Seconds 1
                $appsToInstall = getAppNames -NamePath $OptionalApp5XML
                $argsToInstall = getAppArgs -AppArray $appsToInstall -ArgsPath $OptionalArgs5XML
                installApplications -Applist $appsToInstall -AppArgs $argsToInstall
                Start-Sleep -Seconds 1
            }
            "Q" {
                Write-Host "`n`nExiting Menu" -ForegroundColor Red
                Start-Sleep -Seconds 1
                Clear-Host
                Return
            }
            Default {
                Write-Host "`n`nInvalid choice. Please choose an option listed on the menu."
                Start-Sleep -Seconds 3
            }
        }
    } While ($True)  
}

$installMenu = @"
Select a list of apps to install.

1. Required Apps
2. Optional Apps 2 & 3
3. Optional App 3
4. Additional Apps

Enter a number or Q to exit
"@

$additionalAppsMenu = @"
Select additional apps to install.

1. Optional App 1
2. Optional App 4 & 5

Enter a number or Q to exit
"@

$OptionalApps45Menu = @"
Select a version of Avaya One-X to install.

1. Optional App 4
2. Optional App 5

Enter a number or Q to exit
"@

<#
Logic to display installation menu and handle user input selection.
#>

Do {
    Switch (Invoke-Menu -Menu $installMenu -Title "Powershell Install Script" -Clear) {
        "1" {
            Write-Host "`n`nInstalling Required Apps" -ForegroundColor Green
            Start-Sleep -Seconds 1
            $appsToInstall = getAppNames -NamePath $requiredAppsXML
            $argsToInstall = getAppArgs -AppArray $appsToInstall -ArgsPath $requiredArgsXML
            installApplications -AppList $appsToInstall -AppArgs $argsToInstall
            Start-Sleep -Seconds 1
        }
        "2" {
            Write-Host "`n`nInstalling Optional App 2" -ForegroundColor Green
                Start-Sleep -Seconds 1
                foreach ($installerPath in $Optional2TempPaths) { 
                    setupTempFolder -FolderPath "C:\Temp\InstallerTempFolder\" -FilePath $installerPath
                }
                $appsToInstall = getAppNames -NamePath $OptionalApp2XML
                $argsToInstall = getAppArgs -AppArray $appsToInstall -ArgsPath $OptionalArgs2XML
                installApplications -Applist $appsToInstall -AppArgs $argsToInstall
                deleteTempFolder -FolderPath "C:\Temp\InstallerTempFolder"
                Start-Sleep -Seconds 1
        }
        "3" {
            Write-Host "`n`nInstalling Optional App 3" -ForegroundColor Green
                Start-Sleep -Seconds 1
                $appsToInstall = getAppNames -NamePath $OptionalApp3XML
                $argsToInstall = getAppArgs -AppArray $appsToInstall -ArgsPath $OptionalArgs3XML
                installApplications -Applist $appsToInstall -AppArgs $argsToInstall
                Start-Sleep -Seconds 1
        }
        "4" {
            Invoke-AdditionalApps
        }
        "Q" {
            Write-Host "`n`nExiting Script" -ForegroundColor Red
            Start-Sleep -Seconds 1
            Clear-Host
            Return
        }
        Default {
            Write-Host "`n`nInvalid choice. Please choose an option listed on the menu."
            Start-Sleep -Seconds 3
        }
    }
} While ($True)

