    Kapitel 3 
    #Demo 1
    Get-Service -Name BITS | Stop-Service
    Get-Service | Get-Member
    help Stop-Service -ShowWindow
    "BITS" | Out-File -FilePath service.txt
    Get-Content -Path service.txt | Stop-Service
    Get-Content -Path service.txt | Stop-Service -Name BITS




    Get-Service | Sort-Object -Property Status | Select-Object -Property Name,Status 
#   Get-ADComputer -Filter * | Get-Service -Name *
    Get-Help Get-Service -ShowWindow

#	Get-ADComputer -Filter * | Select-Object @{n='ComputerName';e={$PSItem.Name}} | Get-Service -Name *
#	Get-ADComputer -Filter * |Select-Object @{n='ComputerName';e={$PSItem.Name}} | Get-WmiObject -Class Win32_BIOS
    "PB00BD6G" | Out-File -FilePath Names.txt
	Get-Service -ComputerName (Get-Content Names.txt)
#	Get-Service -ComputerName (Get-ADComputer -Filter *)
#	Get-EventLog -LogName Security -ComputerName (Get-ADComputer -Filter * | Select-Object -Expand Name)
	