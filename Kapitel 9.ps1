
#Lesson 1 demo
set-executionPolicy RemoteSigned
Enable-Psremoting
Enable-PSremoting -SkipNetwork
Enter-PSSession -ComputerName LON-DC1
Get-Process
Remove-PSSession
Invoke-Command -ComputerName LON-CL1,LON-DC1 -ScriptBlock { Get-EventLog -LogName Security -Newest 10 }

#Lesson 2 demo
$quantity = Read-Host "Query how many log entries?"
Invoke-Command -ArgumentList $quantity -ComputerName LON-DC1 -ScriptBlock { Param($x) Get-EventLog -LogName Security -newest $x }

#multi-hop 
Enable-WsManCredSSP -Role Client -Delegate servername
Enable-WsManCredSSP -Role Server

#Lesson 3 demo
$dc = New-PSSession -ComputerName LON-DC1
$all = New-PSSession -ComputerName LON-DC1,LON-CL1
Get-PSSession
$dc
Enter-PSSession -Session $dc
Get-Process
Exit-PSSession
$dc
Invoke-Command -Session $all -ScriptBlock { Get-Service | Where { $_.Status -eq 'Running' }}
$dc | Remove-PSSession
Get-PSSession
Get-PSSession | Remove-PSSession

#Demo2
$dc = New-PSSession -ComputerName LON-DC1
Disconnect-PSSession -Session $dc
Get-PSSession -ComputerName LON-DC1
Get-PSSession -ComputerName LON-DC1 | Connect-PSSession
$dc 
Remove-PSSession -Session $dc

#Demo3
 $dc = New-PSSession LON-DC1
 Get-Module -PSSession $dc -ListAvailable
 Import-Module -PSSession $dc -Name ActiveDirectory -Prefix Rem
 Help Get-RemADUser


