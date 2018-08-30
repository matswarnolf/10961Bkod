# Win32_BIOS

Get-WMIObject -Namespace root -List -Recurse | Select-Object -Unique __NAMESPACE

Get-WmiObject -Namespace root\SecurityCenter2 -List
Get-CimClass -Namespace ROOT\Microsoft\Windows\Defender | Sort-Object -Property CimClassName

Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{'commandline'='Notepad.exe'}

(Get-CimClass -ClassName Win32_process).CimClassMethods
(Get-CimClass -ClassName Win32_Process).CimClassMethods['Create'].Parameters


Get-WmiObject -Class Win32_Service
Get-CimInstance -ClassName Win32_Process
Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"
Get-CimInstance -Query "SELECT * FROM Win32_NetworkAdapter"

Get-WmiObject -Class Win32_Service | Get-Member
Get-WmiObject -Class Win32_Service | Get-Member | Where-Object Name -eq 'Change' | Format-List Name,Definition
Get-CimClass -Class Win32_Service | Select-Object -ExpandProperty CimClassMethods

Invoke-CimMethod -ComputerName LON-DC1 -ClassName Win32_OperatingSystem -MethodName Reboot
Get-WmiObject -Class Win32_Process -Filter "Name='mspaint.exe'" | Invoke-WmiMethod -Name Terminate