# get current user proxy settings
$CUProxySettings = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' | Select-Object ProxyServer, ProxyEnable,ProxyOverride

# output proxy commands to host console
Write-Host 'Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings -name ProxyServer -Value' $($CUProxySettings.ProxyServer)
Write-Host 'Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings -name ProxyEnable -Value' $($CUProxySettings.ProxyEnable)
Write-Host 'Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings -name ProxyOverride -Value' $($CUProxySettings.ProxyOverride)
        
