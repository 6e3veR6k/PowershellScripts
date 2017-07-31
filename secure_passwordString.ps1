#convert from plaintext to securestring;
#choose your password and write it to a file:

read-host -assecurestring | convertfrom-securestring | out-file C:\securestring.txt;

#In the future, you won't have to enter your credentials over and over again, 
#instead you can just read in your password from the file, and create a new PSCredential object from that.

$pass = cat C:\securestring.txt | convertto-securestring;
$mycred = new-object -typename System.Management.Automation.PSCredential -argumentlist "test",$pass;