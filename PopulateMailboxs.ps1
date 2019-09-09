#requires -version 3.0

<#
This script is designed to populate a test Exchange server
with mail messages. The script can be run from a client
desktop that has the Active Directory module installed. 
#>

Param (

[string]$PSEmailServer = "Exchange.lab.seprol",
#number of messages to create
[int]$Count = 25
)

#import the module
Import-Module ActiveDirectory


#use about help topics as message bodies
$topics = Get-help about* | where {$_.synopsis}

Try {
    #get all enabled users with mailboxes in the Employees OU
    $OUPath = "OU=Users,OU=LAB Corp,DC=lab,DC=seprol"
    $users = get-aduser -filter {mail -like "*" -AND Enabled -eq $True} -properties mail -SearchBase $OUPath -ErrorAction Stop
}
Catch {
    Write-Warning "Failed to find any mail-enabled user accounts in $OUPath. $($_.Exception.Message)"

}

#only proceed if users were found
if ($users.count -ge 1) {

    0..$count | foreach {

        $per = ($_/$count)*100
        #get a random user
        $sender = $users | Get-Random
        #get a random number of users, between 1 and 5 
        #to send the message to
        $numUsers = Get-Random -Minimum 1 -Maximum 5
        $sendto = $users | Get-Random -Count $numUsers

        #get a random help topic
        $topic = $topics[(get-random -Minimum 0 -Maximum $topics.count)]

        Write-Progress -Activity "Generating Mail Data" -Status "Item $_" `
        -CurrentOperation "From $($sender.mail) Subject re: $($topic.name)" -percentComplete $per

        #send the mail message
        Send-MailMessage -To $sendto.mail -From $sender.mail `
        -Subject "re: $($topic.name)" -body ($topic.Synopsis | out-string)
    
        #insert a random time offset so not all the messages show up
        #at once.
    
        $sleep = Get-Random -Minimum 1 -Maximum 30
        Start-Sleep -Seconds $sleep

    } #foreach
} #if users found