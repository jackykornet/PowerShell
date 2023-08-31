# get current user proxy settings
# you can get all proxy settings with Get-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings if you need to add more
$CUProxySettings = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' | Select-Object ProxyServer, ProxyEnable,ProxyOverride

# output proxy commands to host console
Write-Host 'Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings -name ProxyServer -Value' $($CUProxySettings.ProxyServer)
Write-Host 'Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings -name ProxyEnable -Value' $($CUProxySettings.ProxyEnable)
Write-Host 'Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings -name ProxyOverride -Value' $($CUProxySettings.ProxyOverride)

# copy output to an ps1 file or paste them in a powershell prompt        
