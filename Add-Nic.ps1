#Parameters
$VMMServerName = "srvVmm01"
$VMnetValidPool = @()
Set-ExecutionPolicy RemoteSigned -Force CurrentUser


#Aviso
   $caption = "Please Confirm"    
    $message = "This task will restart the VM, do you want to continue?:"
    [int]$defaultChoice = 0
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Do the job."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Do not do the job."
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $choiceRTN = $host.ui.PromptForChoice($caption,$message, $options,$defaultChoice)

if ( $choiceRTN -ne 1 )
{
    #Select VM to Configure New Network Adapter
    $VMSelect = Get-SCVirtualMachine | Select Name,CpuCount, MemoryAssignedMB,VirtualMachineState,Version,OperatingSystem | Out-Gridview -PassThru -Title 'Select VM:'
    $VM = Get-SCVirtualMachine -Name $VMSelect.Name

    #$PortProfile = Get-SCVMHostNetworkAdapter -VMHost $VM.VMHost | Select UplinkPortProfileSet | ?{$_.UplinkPortProfileSet -ne $null} | Get-Unique
    #Get-SCNativeUplinkPortProfile -Name $PortProfile.UplinkPortProfileSet.DisplayName | Select LogicalNetworkDefinitions
    


    #Select VM Network With a Valid IP Pool
    $VMNetList = Get-SCVMNetwork -VMMServer $VMMServerName 
    foreach ($VMnet in $VMNetList) 
    {       
        $VMNetwork = Get-SCVMNetwork -VMMServer $VMMServerName -Name $VMNet.Name
        $VMSubnet = Get-SCVMSubnet -VMMServer $VMMServerName -VMNetwork $VMNetwork 
        $IPPool = Get-SCStaticIPAddressPool -VMMServer $VMMServerName -VMSubnet $VMSubnet[0]
        If ($IPPool)
        {
            $Item = New-Object -TypeName psobject -Property @{
                "VMNetwork" = $VMNetwork
                "Logical Network" = $VMNetwork.LogicalNetwork
                "Description" = $VMnet.Description  
                "Enabled" = $VMnet.Enabled
                "VM Subnet" = $VMnet.VMSubnet
                "IPPool" = $IPPool                        
            }
            $VMnetValidPool += $item
        }
    }
    $VMNetworkSelect  = $VMnetValidPool | Out-Gridview -PassThru -Title 'Select VM Network with a Valid IP-Pool:'
    #Stop VM to Assign NetAdapter with Static Mac

    Stop-SCVirtualMachine $VM -Shutdown
    $NEWNIC = New-SCVirtualNetworkAdapter -VM $VM -VMNetwork $VMNetworkSelect.VMNetwork -MACAddressType Static -Synthetic -MACAddress "00:00:00:00:00:00"
    Start-SCVirtualMachine $VM

    #Reserve and ADD IPAddress to VM.
    $IPAddress = Grant-SCIPAddress -GrantToObjectType VirtualNetworkAdapter -GrantToObjectID $VM.VirtualNetworkAdapters[($NEWNIC.SlotID)].ID -StaticIPAddressPool $VMNetworkSelect.IPPool -Description $VM.Name
    Try {
        Set-SCVirtualNetworkAdapter -VirtualNetworkAdapter $VM.VirtualNetworkAdapters[($NEWNIC.SlotId)] -VMNetwork $VMNetworkSelect.VMNetwork -IPv4AddressType Static -IPv4Addresses $IPAddress.Address -ErrorAction Stop
    }
    Catch
    {
        [System.Windows.Forms.MessageBox]::Show($_, "Error to ADD Nic to VM",0,48)
        Remove-SCVirtualNetworkAdapter -VirtualNetworkAdapter $NEWNIC          
    }    
}
Else
{
    Write-Host "This task was cancelled!"
}