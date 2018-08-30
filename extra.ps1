Invoke-Command -ComputerName LONDC1 -ScriptBlock {get-process -Name note* } | stop-process 
Invoke-Command -ComputerName LONDC1 -ScriptBlock {get-process -Name note*  | stop-process }


$log = 'Security'
$quantity = 10
Invoke-Command -ComputerName ett, två -ScriptBlock {
    param ($x,$y) 
    Get-eventlog -LogName $x -Newest $y} -ArgumentList $log,$quantity
    