$AdventArray = Get-Content -Path "Z:\sugden\GitHub\Advent of Code\Day1Puzzle.txt"
$AdventIntArray = @()
Foreach ($Line in $AdventArray) {
    $IntLine = [int]$Line
    $AdventIntArray += $IntLine
}
$OperationCount = $Null
$CorrectSums = New-Object System.Collections.Generic.List[System.Object]
$CorrectNumber = $Null
$CorrectLine = $Null
$CorrectThird = $Null
ForEach ($Line in $AdventIntArray) {
    If ( $Line -ne $CorrectNumber -And $Line -ne $CorrectLine -And $Line -ne $CorrectThird ) {
        Foreach ($Entry in $AdventIntArray) {
            If ( $Entry -ne $CorrectNumber -And $Entry -ne $CorrectLine -And $Entry -ne $CorrectThird ) {
                Foreach ($Part in $AdventIntArray) {
                    If ($Part -ne $CorrectNumber -And $Part -ne $CorrectLine -And $Part -ne $CorrectThird) {
                        $VarSum = $Line + $Entry + $Part
                        $OperationCount += 1
                        If ($VarSum -eq 2020) {
                            $CorrectSums.Add(1)
                            $CorrectNumber = $Line
                            $CorrectLine = $Entry
                            $CorrectThird = $Part
                        }
                    }
                }
            }
        }
    }
}
$CorrectProduct = $CorrectNumber * $CorrectLine * $CorrectThird
$CorrectProduct

