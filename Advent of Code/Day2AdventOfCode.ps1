# Part 1

$AdventPuzzleInput = Get-Content -Path "Z:\sugden\GitHub\Advent of Code\Day2Puzzle.txt"
$CorrectPassCount = $Null
ForEach ($Line in $AdventPuzzleInput) {
    $PassPolicy,$PassLetter,$PasswordActual = ($Line.Split(" "))
    $PassPolicy = $PassPolicy.Split("-")
    $PassLetter = $PassLetter.Trim(":")
    $IntPassPolicy = New-Object System.Collections.Generic.List[System.Object]
    ForEach ($PolicyElement in $PassPolicy) {
        $IntPassPolicy.Add([Int]$PolicyElement)
    }
    $PasswordArray = $PasswordActual.ToCharArray() | Select-String -Pattern $PassLetter -Allmatch
    If ( $IntPassPolicy[0] -le $PasswordArray.Count -And $PasswordArray.Count -le $IntPasspolicy[1] ) {
        $CorrectPassCount += 1
    }
}
$CorrectPassCount

# Part 2

$AdventPuzzleInput = Get-Content -Path "Z:\sugden\GitHub\Advent of Code\Day2Puzzle.txt"
$CorrectPassCount = $Null
ForEach ($Line in $AdventPuzzleInput) {
    $PassPolicy,$PassLetter,$PasswordActual = ($Line.Split(" "))
    $PassPolicy = $PassPolicy.Split("-")
    $PassLetter = $PassLetter.Trim(":")
    $IntPassPolicy = New-Object System.Collections.Generic.List[System.Object]
    ForEach ($PolicyElement in $PassPolicy) {
        $IntPassPolicy.Add([Int]$PolicyElement)
    }
    $PasswordArray = $PasswordActual.ToCharArray()
    $PassLetterFreq = $Null
    ForEach ($PolicyInt in $IntPassPolicy) {
        If ( $PasswordArray[$PolicyInt - 1] -eq $PassLetter) {
            $PassLetterFreq += 1
        }
    }
    If ($PassLetterFreq -eq 1) {
        $CorrectPassCount += 1
    }
}
$CorrectPassCount