
$jAdmin = New-Object System.Management.Automation.PSCredential -ArgumentList 'oranta\jAdmin', (cat '.\jAdminPW.txt' | convertto-securestring);
$jIncore = New-Object System.Management.Automation.PSCredential -ArgumentList 'oranta\jIncore', (cat '.\jIncore.txt' | convertto-securestring);


Invoke-Command -ComputerName 'hq01ju06' -Credential $jAdmin -ScriptBlock {  Get-ChildItem 'C:\inetpub\Jupiter\Amalthee' | where {$_.Name -like "*App_Offline*"} };

Restart-Computer -ComputerName 'hq01ju06' -Credential $jAdmin -AsJob