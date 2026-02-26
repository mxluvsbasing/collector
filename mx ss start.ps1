Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/CommonDirectories.ps1)'
Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/DoomsdayFinder.ps1)'
Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/SchedulesV2.ps1)'
Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/Services.ps1)'
Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/mxluvsbasing/collector/blob/bc4db255bc514d3686c36509dfc09b0baea15ccd/collector.ps1)'
Start-Process explorer.exe $env:TEMP

Start-Process explorer.exe 'shell:recent'




