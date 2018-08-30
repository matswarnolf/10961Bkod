$cred = get-credential
$session = New-PSSession -ComputerName lon-dc1 -Credential $cred 

#Installera ett klientcertifikat om det inte redan finns ett
Get-ChildItem cert:\LocalMachine\My |Where-Object { $_.Subject -eq "CN=HOSTNAME" } #kolla och kopiera "Thumbprint"
winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname="HOSTNAME";CertificateThumbprint="Klistra in thumbprint här"}