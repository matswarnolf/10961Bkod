#Kapitel 4

Cd C:\
New-PSDrive -Name WINDIR -Root C:\Windows -PSProvider FileSystem
Get-ChildItem WINDIR:
New-Item -Path HKCU:\Software -Name Classroom -ItemType 
New-ItemProperty -Path HKCU:\Software\Classroom -Name Test -Value 1
Get-ChildItem HKCU:\Software\Classroom2

Remove-Item HKCU:\Software\Classroom


New-PSDrive -Name TEMP -Root C:\temp -PSProvider FileSystem
New-Item -Path temp:\test.txt -ItemType File 
Add-Content -Value "ugga" -Path TEMP:\test.txt -Encoding UTF8
