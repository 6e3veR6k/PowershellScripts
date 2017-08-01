#So I had written a script for a customer to update all the SharePoint servers
# in a farm and then run PSConfig and it worked great (More of that later) 
# but one of the production farms is in the DMZ with firewalls, etc so being 
# able to update all farms from one central machine was a concern.  Did some digging, and here is what I found for them:
#By default PowerShell will use the following ports for communication (They are the same ports as WinRM)
#    TCP/5985 = HTTP
#    TCP/5986 = HTTPS
# While I would recommend you stay with the defaults, 
# If you are not happy with this or your security team is not happy with this there are some other choices
#You can set PowerShell remoting to use 80 (HTTP and 443 (HTTPS) by running the following commands

#Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpListener -Value true
#Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpsListener -Value true

# You can set powershell to use any other port that we desire by performing the following
# On each SharePoint server run the following command

#Set-Item wsman:\localhost\listener\listener*\port –value <Port>

#Then in your code you would declare that your connecting over the same port using the following 
#commands(There are other commands to deal with Sessions)

#New-PSSession –ComputerName <Netbios> -Port <Port>

#Enter-PSSession –ComputerName <Netbios> -Port <Port>

#Invoke-Command –ComputerName <Netbios> -Port <Port>

#
#Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpListener -Value true
#Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpsListener -Value true
#Set-Item wsman:\localhost\listener\listener*\port –value 443
#
#winrm e winrm/config/listener



#добавление
$servers = 'hq01ju01', 'hq01ju02', 'hq01ju03', 'hq01ju04', 'hq01ju06', 'hq01ju07', 'hq01db06', 'hq01db05' , 'hq01sdb3'

foreach ($server in $servers) {
Write-Host "adding host: $server"

$prev = (get-item WSMan:\localhost\Client\TrustedHosts).value
if ( ($prev.Contains( $server )) -eq $false)
{ 
    if ( $prev -eq '' ) 
    { 
        set-item WSMan:\localhost\Client\TrustedHosts -Value "$server" 
    }
    else
    {
        set-item WSMan:\localhost\Client\TrustedHosts -Value "$prev, $server"
    }
}

Write-Host ''
Write-Host 'Now TrustedHosts contains:'
(get-item WSMan:\localhost\Client\TrustedHosts).value
}

#удаление

Clear-Item WSMan:\localhost\Client\TrustedHosts

To remove a value:
$newvalue = ((Get-ChildItem WSMan:\localhost\Client\TrustedHosts).Value).Replace("computer01,","")
Set-Item WSMan:\localhost\Client\TrustedHosts $newvalue



#Have you ever been in a situation where you have PowerShell Remoting enabled and you need to put the configuration back the way it was before Enable-PSRemoting was run?
#
#While it might seem that just running Disable-PSRemoting should suffice, it turns out to be a bit more work than you would think. Let’s take a look.
#
#When you run Disable-PSRemoting, here’s what it tells you:
#
#PS C:\Windows\system32> Disable-PSRemoting
#WARNING: Disabling the session configurations does not undo all the changes made by the Enable-PSRemoting or
#Enable-PSSessionConfiguration cmdlet. You might have to manually undo the changes by following these steps.
#    1. Stop and disable the WinRM service.
#    2. Delete the listener that accepts requests on any IP address.
#    3. Disable the firewall exceptions for WS-Management communications.
#    4. Restore the value of the LocalAccountTokenFilterPolicy to 0, which restricts remote access to members of the
#Administrators group on the computer.
#As you see, the steps are pretty well documented. However, if you are like me, you would follow the order mentioned, and find out later that it’s a problem. Let’s see why.
#
#You stopped and disabled the WinRM service.
#You try to delete the listener using winrm commands only to find out the error:
#WSManFault
#    Message = The client cannot connect to the destination specified in the request. Verify that the service on the dest
#ination is running and is accepting requests. Consult the logs and documentation for the WS-Management service running o
#n the destination, most commonly IIS or WinRM. If the destination is the WinRM service, run the following command on the
# destination to analyze and configure the WinRM service: "winrm quickconfig".
#Well guess what, you just disabled the service. How will winrm commands connect to delete the listener?
#
#So here’s what you need to do:
#
#Delete the listener that accepts requests on any IP address, Usually this means listener with Address = * and Port = 5985 that is using Transport = HTTP. you can verify this by running
#winrm enumerate winrm/config/listener
#You can delete it by running
#
#winrm delete winrm/config/listener?address=*+transport=HTTP
#Disable firewall exceptions. This is pretty simple. Just uncheck Windows Remote Management checkbox for desired (or all) profiles. And if picture is worth thousand words, here it is:
#SNAGHTML2c896ffb
#
#Now if you fancy why I didn’t use PowerShell to disable firewall exceptions, I will point you to this link and let you figure out how to do that.
#
#Order doesn’t matter after step 1. So let’s disable service now. Do you need me to tell you how? Ok if you seriously want to know how, here’s how:
#Stop-Service winrm
#Set-Service -Name winrm -StartupType Disabled
#I know you will now ask why not just run:
#
#Set-Service -Name winrm -StartupType Disabled -Status Stopped
#that's because if you do that you will get this error:
#
#Set-Service : Cannot stop service 'Windows Remote Management (WS-Management) (winrm)' 
#because it is dependent on other services.
#Now, if you are still with me, this is last step left. Set value of LocalAccountTokenFilterPolicy to 0. You can do that by running:
#Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 0 -Type DWord
#This will create the value if it doesn't exist and will change it if it does. If you are curious as to why this value and why 0, it's documented here so I will let you read it.
#
#Oh, and one more thing (I wonder who does that remind you of!) make sure you do all this from elevated PowerShell. But you already knew that, didn’t you?

#WARNING: Disabling the session configurations does not undo all the changes made by the Enable-PSRemoting or Enable-PSSessionConfiguration cmdlet. You might have to manua
#lly undo the changes by following these steps:
#    1. Stop and disable the WinRM service.
#    2. Delete the listener that accepts requests on any IP address.
#    3. Disable the firewall exceptions for WS-Management communications.
#    4. Restore the value of the LocalAccountTokenFilterPolicy to 0, which restricts remote access to members of the Administrators group on the computer.



#winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
#Start-Sleep -s 3
#Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpListener -Value false
#Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpsListener -Value false

winrm e winrm/config/listener

winrm delete winrm/config/Listener?Address=*+Transport=HTTP



Disable-PSRemoting -Force
Start-Sleep -s 5
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 0 -Type DWord
Start-Sleep -s 1
Stop-Service winrm
Start-Sleep -s 1
Set-Service -Name winrm -StartupType Disabled
Start-Sleep -s 1