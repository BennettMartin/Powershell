# Part 1

$AdventPuzzleInput = Get-Content -Path "Z:\sugden\GitHub\Advent of Code\Day3Puzzle.txt"
$TreeHitCount = $Null
$SkiPosition = 0
ForEach ($Slope in $AdventPuzzleInput) {
    If ($SkiPosition -gt 30) {
        $SkiPosition = $SkiPosition - 31
    }
    $SlopeArray = $Slope.ToCharArray()
    If ($SlopeArray[$SkiPosition] -eq "#") {
        $TreeHitCount += 1
    }
    $SkiPosition += 7
}
$TreeHitCount

# Part 2

$AdventPuzzleInput = Get-Content -Path "Z:\sugden\GitHub\Advent of Code\Day3Puzzle.txt"
$TreeHitCount = New-Object System.Collections.Generic.List[System.Object]
$SkiPosition = @((1,1),(3,1),(5,1),(7,1),(1,2))
ForEach ($SkiSlope in $SkiPosition) {
    $TreeCollision = $Null
    $SkiCurrent = 0
    $SkiLine = 0
    ForEach ($Line in $AdventPuzzleInput) {
        $SkiSlopeArray = $Line.ToCharArray()
        If ($SkiCurrent -gt 30) {
            $SkiCurrent = $SkiCurrent - 31
        }
        If (($SkiLine % $SkiSlope[1]) -eq 0) {
            If ($SkiSlopeArray[$SkiCurrent] -eq "#") {
                $TreeCollision++
            }
            $SkiCurrent = $SkiCurrent + $SkiSlope[0]
            $SkiLine++
        }
        ElseIf (($SkiLine % $SkiSlope[1]) -ne 0) {
            $SkiLine++
        }
    }
    $TreeHitCount.Add($TreeCollision)
}
$TreeHitProduct = 0
ForEach ($CollisionCount in $TreeHitCount) {
    If ($TreeHitProduct -eq 0) {
        $TreeHitProduct = $CollisionCount
    }
    ElseIf ($TreeHitProduct -ne 0) {
        $TreeHitProduct = $TreeHitProduct * $CollisionCount
    }
}
$TreeHitProduct