import-module dataprotectionmanager

Start-Transcript -Path "C:\util\dpmtdrive-log.txt" 

#Ready Reg Keys and DPM values.
$key="hklm:\SOFTWARE\Microsoft\Microsoft Data Protection Manager"
$reg="TapeDriverDisabled"
$DriverDisabled = (Get-ItemProperty -Path $key -Name $reg).$reg
$DpmLibrary = Get-DPMLibrary
$DpmTapeDrive = Get-DPMTapeDrive -DPMLibrary $DpmLibrary
$startlog = Get-Date -Format g
#Start Chance of drive
echo "############Log start at: $startlog###########################"
echo "The Driver currently disabled is:"$DriverDisabled

If ($DriverDisabled -eq 0) 
    {
    Enable-TapeDrive $DpmTapeDrive[0] -Confirm:$false 
    echo $log "Driver 0 has Enabled"  
    Disable-TapeDrive $DpmTapeDrive[1] -Confirm:$false
    echo $log "Driver 1 has disabled"      
    Set-ItemProperty -Path $key -Name $reg -Value 1
    
    }
If ($DriverDisabled -eq 1)
    {
    Enable-TapeDrive $DpmTapeDrive[1] -Confirm:$false
    echo $log "Driver 1 has Enabled" 
    Disable-TapeDrive $DpmTapeDrive[0] -Confirm:$false
    echo $log "Driver 0 has disabled" 
    Set-ItemProperty -Path $key -Name $reg -Value 0
    }
$endlog = Get-Date -Format g
echo "---------------------END of LOG: $endlog--------"
Stop-Transcript

