########################################################
# Name: FreeTapeWithGUI.ps1                              
# Creator: Michael Seidl aka Techguy                    
# CreationDate: 12.05.2014                              
# LastModified: 12.05.2014                               
# Version: 1.0   
# Doc: http://www.techguy.at/tag/freetapewithgui/
#
# Description: Uses PowerShell Out-GridView to select the 
# Library and the Tapes you want to delete an mark as free
# Uses the ForceFree-Tape.ps1 from SCDPM, but build a GUI with
# OutGridView to easily select Liobrary an Tapes
# 
#
# Beschreibung: Ich nutzer die Powershell OutGrifView um
# eine Benutzeroberfläche u gestaltet in der man die Library
# und ie Bänder auswählen kann, die nach mit SCDPM 
# Boradmitteln ForceFree-Tape.ps1 gelöscht und als frei
# markiert werden
#
# Version 1.0 - RTM
########################################################
#
# www.techguy.at                                        
# www.facebook.com/TechguyAT                            
# www.twitter.com/TechguyAT                             
# michael@techguy.at 
########################################################


Import-Module DataProtectionManager

$PSPre="3"

if ($Host.Version.Major -ge $PSPre) {
    } else {
    Write-Host "Wrong PS Version, you are running Version: " $Host.Version.Major
    Write-Host "You need PowerShell V3"
    Write-Host "Download PowerShell V3: http://www.microsoft.com/en-us/download/details.aspx?id=34595"
    Write-Host "Press Key to exit...."
    $x=$HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
    exit
    }



$DPMServer=$env:COMPUTERNAME
$Library=Get-DPMLibrary  | Select userfriendlyname, DriveCount, SlotCount, ProtectionGroups | Out-GridView -PassThru -Title "Choose Library"
$Library = Get-DPMLibrary | where {$_.userfriendlyname -eq $Library.userfriendlyname}
$Slots=Get-DPMTape -DPMLibrary $Library | Out-GridView -PassThru -Title "Choose Tapes" | select Location

if ($Slots.count -gt "1") {
    foreach ($Slot in $Slots) {
        Write-Host "1"
        ForceFree-Tape.ps1 -DPMServerName $DPMServer -LibraryName $Library.userfriendlyname -TapeLocationList $Slot.Location
    }} else {
        Write-Host "3"
        ForceFree-Tape.ps1 -DPMServerName $DPMServer -LibraryName $Library.userfriendlyname -TapeLocationList $Slots.Location
    }
