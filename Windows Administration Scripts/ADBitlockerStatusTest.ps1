using namespace System.Collections

$SampleOUObject = Get-ADComputer -Filter 'name -like "ComputerPrefix*" -and name -notlike "ComputerPrefix *"' -SearchBase "OU=Full,OU=OU,DC=path,DC=net"
[ArrayList]$NoBLComputerArray = @()

foreach ($adobject in $SampleOUObject) {
    [Array]$BLInfo = Get-ADObject -Filter 'objectclass -eq "msFVE-RecoveryInformation"' -SearchBase $adobject.DistinguishedName -Properties 'WhenCreated', 'msFVE-RecoveryPassword'
    if (-not $BLInfo) {
        [void]$NoBLComputerArray.Add($adobject.Name)
    } 
}

$NoBLComputerArray.Count

$NoBLComputerArray | Out-File -FilePath C:\Users\$env:USERNAME\Desktop\outfiletest.csv
