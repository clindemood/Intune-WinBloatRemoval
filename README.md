# Intune-WinBloatRemoval
Script meant to be ran using InTune to remove windows 10/11 bloatware
Adapted from : https://www.burgerhout.org/remove-bloatware-on-windows-10/


At the Install command field, type this:
powershell.exe -noprofile -executionpolicy bypass -file .\RemoveW10Bloatware.ps1
At the Uninstall command field, type this:
cmd.exe /c del %ProgramData%\Microsoft\RemoveW10Bloatware\RemoveW10Bloatware.ps1.tag


From the Rules format dropdown, select Manually configure detection rules
Click on + Add
At the Rule type dropdown, select File
In the Path field, type %ProgramData%\Microsoft\RemoveW10Bloatware
In the File or folder field, type RemoveW10Bloatware.ps1.tag
From the Detection method dropdown, select File or folder exist
Click on OK
