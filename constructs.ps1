if ($x -eq $y) {
    #gör något
}
Elseif ($x -eq $z) {
    #gör nåt annat
}
Else {
    #Gör något helt annat
}

$drive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceId='C:'" 
switch ($drive.DriveType) {
    3{ Write-Output 'Fixed Local'}
    5{Write-Output 'Optical'}
    default {Write-Output 'Other'}
    }
    
    $services = Get-Service
    foreach ($service in $services) {
    $service | Select-Object -Property servicename | export-csv -Path c:\temp\testar.csv -Append -NoTypeInformation
    Write-Output "the servicename is $($service.name)"}
    