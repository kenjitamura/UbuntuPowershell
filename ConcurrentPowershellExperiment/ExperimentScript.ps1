. (Join-Path -Path $PSScriptRoot -ChildPath "ModuleLoader.ps1")

$testDict=[System.Collections.Concurrent.ConcurrentDictionary[string,testSync]]::new(2,3)


$testScript={
    for ($i=0; $i -lt 10000; $i++){
        if ($i % 2  -eq 0){
            ($testDict).AddOrUpdate("one",${function:Test-CreateVal},${function:Test-UpdateVal}) | Out-Null
        } else {
            ($testDict).AddOrUpdate("two",${function:Test-CreateVal},${function:Test-UpdateVal}) | Out-Null
        }
    }
}

$testScriptP={
    . (Join-Path -Path $using:PSScriptRoot -ChildPath "ModuleLoader.ps1")
    for ($i=0; $i -lt 10000; $i++){
        if ($i % 2  -eq 0){
            ($using:testDict).AddOrUpdate("one",${function:Test-CreateVal},${function:Test-UpdateVal}) | Out-Null
        } else {
            ($using:testDict).AddOrUpdate("two",${function:Test-CreateVal},${function:Test-UpdateVal}) | Out-Null
        }
    }
}

# single thread experiment
Write-Host "Single Threaded Results:"
Measure-Command -Expression $testScript

# multi thread experiment
Write-Host "Multi-Threaded Results:"
Measure-Command -Expression {Start-ThreadJob -ScriptBlock $testScriptP | Out-Null;& $testScript}

Function Find-IndexOfBackgroundThread ([Entry]$E){
    $MainThread=$testDict["one"].List[0].owner
    return $E.owner -ne $MainThread
}

$index=($testDict["one"].List.FindIndex(4999,${function:Find-IndexOfBackgroundThread}))-1
Write-Host "Dictionary Sample Results:"
Write-Host ($testDict["one"].List[$index..($index+10)]|Format-Table|Out-String)