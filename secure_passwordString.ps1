############################################
#1.Working with Password in secure way
############################################

#convert from plaintext to securestring;
#choose your password and write it to a file:

read-host -assecurestring | convertfrom-securestring | out-file C:\securestring.txt;

#In the future, you won't have to enter your credentials over and over again, 
#instead you can just read in your password from the file, and create a new PSCredential object from that.

$pass = cat C:\securestring.txt | convertto-securestring;
$mycred = new-object -typename System.Management.Automation.PSCredential -argumentlist "test",$pass;


############################################
#2.Add access on remote computer
############################################

#Step 1 on remote computer
#Add client host into TrustedHosts
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

#Step 2 on remote computer
Enable-PSRemoting


#example script-block
$deployRemote = {
param(
[string]$targetEnvName,
[string]$targetUsername)
$Global:ErrorActionPreference = «Stop»
#…
}

Invoke-Command -Session $session -ScriptBlock $deployRemote -ArgumentList ($targetEnvName, $targetUsername)
