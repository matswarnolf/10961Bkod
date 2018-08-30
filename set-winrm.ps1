#enable winrm default
Set-WSManQuickConfig #uses http
 # you should use HTTPS instead
# Set-WSManQuickConfig -UseSSL


#disable winrm default
Remove-WSManInstance -ResourceURI winrm/config/listener -SelectorSet @{Transport="HTTP";Address="*"} #change transport to HTTPS if you use SSL
Stop-Service -Name WinRM
Set-Service -Name WinRM -StartupType disabled
Get-NetFirewallRule | ? {$_.Displayname -eq "Windows Remote Management (HTTP-In)"} | Set-NetFirewallRule -Enabled "False"
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name LocalAccountTokenFilterPolicy

