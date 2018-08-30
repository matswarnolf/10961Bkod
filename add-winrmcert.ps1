$cred = get-credential
$session = New-PSSession -ComputerName lon-dc1 -Credential $cred 

#Installera ett klientcertifikat om det inte redan finns ett
$hostname = $env:COMPUTERNAME
$myFQDN=(Get-WmiObject win32_computersystem).DNSHostName+"."+(Get-WmiObject win32_computersystem).Domain
$mycert = Get-ChildItem cert:\LocalMachine\My -DnsName $myFQDN 
new-item -Path WSman:\localhost\listener -Address * -Transport https -CertificateThumbPrint $mycert.Thumbprint -HostName $hostname #this command require elevetion
