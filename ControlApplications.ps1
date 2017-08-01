#param ( $NewAppOflineFileName = '____App_Offline.htm' )

class Application 
{

    [string[]]$Servers;
    hidden [PSCredential]$AppCredential;
    hidden [string]$AplicationPath;

    
    Application([string[]]$servers, [PSCredential]$appCredential, [string]$aplicationPath)
    {
        $this.Servers = $servers;
        $this.AppCredential = $appCredential;
        $this.AplicationPath = $aplicationPath
    }

    
    hidden [string]GetAppFilePath([string]$server)
    {
 
        $fileInfo = Invoke-Command -ComputerName $server `
                                    -Port '80'`
                                    -Credential $this.AppCredential `
                                    -ScriptBlock { param($Path) Get-ChildItem $Path | where {$_.Name -like "*App_Offline*"} } `
                                    -ArgumentList $this.AplicationPath;
        return  $fileInfo.FullName
    }


    
    hidden [void]RenameFile([string]$NewFileName, [string]$server)
    {
 
        Invoke-Command  -ComputerName $server `
                        -Port '80'`
                        -Credential $this.AppCredential `
                        -ScriptBlock { param($App_Offline_FullName, $App_Offline_NewName)  Rename-Item $App_Offline_FullName -NewName $App_Offline_NewName  } `
                        -ArgumentList $this.GetAppFilePath($server), $NewFileName;
        Write-Host "New file name: " $server $this.GetAppFilePath($server)
    }

    
    [void]ApplicationClose( [string]$NewFileName ) 
    {
        $workApplication = [Application]::new($this.Servers, $this.AppCredential, $this.AplicationPath);

        ForEach ($server in $this.Servers) 
        {
            
            $workApplication.RenameFile($NewFileName, $server)
        }
    }


    [void]IISsRestart()
    {
        $_sb = Start-Process -FilePath C:\Windows\System32\iisreset.exe -ArgumentList /RESTART -RedirectStandardOutput .\iisreset.txt

        ForEach ($server in $this.Servers) 
        {
            Invoke-Command -ComputerName $server `
                            -Port '80'`
                            -Credential $this.AppCredential `
                            -ScriptBlock $_sb;

            Get-Content .\iisreset.txt | Write-Log -Level Info;
        }

        
    }

}


#Get credential object for our users
$jAdmin = New-Object System.Management.Automation.PSCredential -ArgumentList 'oranta\jAdmin', (cat '.\jAdminPW.txt' | convertto-securestring);
$jIncore = New-Object System.Management.Automation.PSCredential -ArgumentList 'HQ01JU01\jincore', (cat '.\jIncore.txt' | convertto-securestring);


#Describe application servers
$JupiterServers = [psobject]@{
    "FrontOffice" = 'hq01ju01'
    "BackOffice"  = 'hq01ju02', 'hq01ju03', 'hq01ju04', 'hq01ju06', 'hq01ju07'
    "AmaltheeApp" = 'hq01ju06', 'hq01ju07'
    "DBServers" = '' 
}


#Define Amalthee application folder:
$AmaltheePath = 'C:\inetpub\Jupiter\Amalthee';

#Define Leda application folder:
#$LedaPath = 'C:\inetpub\Jupiter\Leda';


#Get access to application servers
$AmaltheeApp = [Application]::new($JupiterServers.AmaltheeApp, $jAdmin, $AmaltheePath)
#$BackOffice = [Application]::new($JupiterServers.BackOffice, $jAdmin, $AmaltheePath)




#Change filename on each servers. To stop application change parameter to 'App_Offline.htm'
$AmaltheeApp.ApplicationClose('_test3__App_Offline.htm');
#$BackOffice.IISsRestart();

#должен добавить порт
#Invoke-Command –ComputerName <Netbios> -Port <Port>



