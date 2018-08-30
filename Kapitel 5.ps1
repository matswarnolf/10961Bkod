Get-Process | Format-Wide -Property ID
Get-Process | Format-Wide -Property ID -Column 5
Get-Process | Format-Wide -AutoSize
Get-Service | Format-List -Property Name,Status
Get-Process | Format-List -Property *
Get-EventLog -LogName Application -Newest 50 | Format-Table -Property EventID,TimeWritten -AutoSize


Get-Process | 
Format-Table -Property Name,ID,@{name='VM(MB)';                
                                 expression={$PSItem.VM / 1MB};
                                 formatString='N2';
                                 align='right'} -AutoSize 
                                 
get-process | Select-Object name,id,@{name='VM(MB)'
 expression={$PSItem.VM / 1MB}}

Get-Service | Format-Table -GroupBy Status
Get-Service | Sort-Object Status -Descending| Format-Table -GroupBy Status 

Get-Process | Get-Member
Get-Process | Select-Object Name,ID | Get-Member
#Notice that the output type name is similar, and that fewer properties are listed.
Get-Process | Format-Table Name,ID | Get-Member
#Notice that the output is completely different from the previous examples.
Get-Process | Format-Table Name,ID | Export-CSV Procs.csv
Notepad procs.csv
