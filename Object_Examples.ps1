

class DefaultUser {
    
    [string]$User;
    [PSCredential]$Credential;
    [SecureString]$Password;

    DefaultUser([string]$User, [string]$PasswordFilePath)
    {
        $This.User = [string]$User;
        $This.Password = cat $PasswordFilePath | convertto-securestring ;
        $This.Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $This.User, $This.Password;
    }


    
}


$jAdmin = New-Object -TypeName DefaultUser 'oranta\jAdmin', '.\jAdminPW.txt';
$jAdmin.User;