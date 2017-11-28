$IIS_servers_Jupiter = 'hq01ju02', 'hq01ju03', 'hq01ju04', 'hq01ju06', 'hq01ju07';
$juMainApp = 'hq01ju06', 'hq01ju07';
$IIS_server_Leda = 'hq01ju01';




$juUser = 'oranta\jAdmin'
$juPlPswrd = '__________________'
$juSecurePassword = $juPlPswrd | ConvertTo-SecureString -AsPlainText -Force
$juCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $juUser, $juSecurePassword


$ledaUser = 'HQ01JU01\jincore'
$ledaPlPswrd = '___________'
$ledaSecurePassword = $ledaPlPswrd | ConvertTo-SecureString -AsPlainText -Force
$ledaCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $ledaUser, $ledaSecurePassword



function RenameFile($newFileName, $serverList, $Credentials, $off_file_path) 
{


Write-Host "Renaming App_Offline ..."
ForEach ($server in $serverList) {



$file = Invoke-Command -ComputerName $server -Credential $Credentials -ScriptBlock { param($off_file_path)  Get-ChildItem $off_file_path | where {$_.Name -like "*App_Offline*"} } -ArgumentList $off_file_path;
$file_fullPath = $file.FullName;
$file_fullPath
Invoke-Command -ComputerName $server -Credential $Credentials -ScriptBlock { param($file_fullPath, $newFileName)  Rename-Item $file_fullPath -NewName $newFileName  } -ArgumentList $file_fullPath, $newFileName;


$file = Invoke-Command -ComputerName $server -Credential $Credentials -ScriptBlock { param($off_file_path)  Get-ChildItem $off_file_path | where {$_.Name -like "*App_Offline*"} } -ArgumentList $off_file_path;
$file_fullPath = $file.FullName;
}
Write-Host "Renamed App_Offline!"

}


function RemoteIISReset1($serverList, $Credentials)
{

Write-Host "Reset IIS ..."
ForEach ($server in $serverList) {

Invoke-Command -ComputerName $server -Credential $Credentials -ScriptBlock { iisreset } ;

}

}

function RemoteIISSTOP($serverList, $Credentials)
{

Write-Host "Stop IIS ..."
ForEach ($server in $serverList) {

Invoke-Command -ComputerName $server -Credential $Credentials {cd C:\Windows\System32\; ./cmd.exe /c "iisreset /noforce /stop" } ;
Write-Host $server;
Write-Host "Stoped IIS ...";
}

}

function RemoteIISSTART($serverList, $Credentials)
{

Write-Host "Start IIS ..."
ForEach ($server in $serverList) {

Invoke-Command -ComputerName $server -Credential $Credentials {cd C:\Windows\System32\; ./cmd.exe /c "iisreset /start" } ;
Write-Host $server;
Write-Host "Start IIS ...";
}

}

function RemoteServerRestart($serverList, $Credentials)
{

Write-Host "Start IIS ..."
ForEach ($server in $serverList) {

Invoke-Command -ComputerName $server -Credential $Credentials {cd C:\Windows\System32\; ./cmd.exe /c "shutdown -r -t 0 -m" } ;
Write-Host $server;
Write-Host "Start IIS ...";
}

}


#RemoteIISSTOP $IIS_servers_Jupiter $juCredentials;
#RemoteIISSTART $IIS_servers_Jupiter $juCredentials;


# Rename File 
RenameFile -newFileName '____App_Offline.htm' $juMainApp $juCredentials -off_file_path 'C:\inetpub\Jupiter\Amalthee';

# Stop Servers
#RemoteServerRestart $IIS_servers_Jupiter $juCredentials;



#RenameFile -newFileName '__App_Offline.htm' $IIS_server_Leda $ledaCredentials -off_file_path 'C:\inetpub\Jupiter\Leda'




