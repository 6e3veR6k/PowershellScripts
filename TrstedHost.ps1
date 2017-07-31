######################################################################################
# добавляет NewHost в список TrustedHost с фильтрацией если такая строка уже есть
# можно дергать из командной строки указывая параметр напрямую например
# .\Add-TrustedHost.ps1 192.168.2.1
######################################################################################
param ( $NewHost = '192.168.2.89' )

Write-Host "adding host: $NewHost"

$prev = (get-item WSMan:\localhost\Client\TrustedHosts).value
if ( ($prev.Contains( $NewHost )) -eq $false)
{ 
    if ( $prev -eq '' ) 
    { 
        set-item WSMan:\localhost\Client\TrustedHosts -Value "$NewHost" 
    }
    else
    {
        set-item WSMan:\localhost\Client\TrustedHosts -Value "$prev, $NewHost"
    }
}

Write-Host ''
Write-Host 'Now TrustedHosts contains:'
(get-item WSMan:\localhost\Client\TrustedHosts).value