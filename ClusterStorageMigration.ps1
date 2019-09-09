#Author: Magnun Scheffer
#linkedin: https://www.linkedin.com/in/magnunscheffer/

#Extra tip, show all cluster VMs with vm file location.
#Get-VM -CimSession S2D |  select Name,path,configurationlocation,snapshotfilelocation,@{L="Disks";E={$_.harddrives.path}} | Out-GridView 
Param(

   [Parameter(Mandatory=$true, Position = 0)]
   #List of VM to Migrate, Use comma to separate ex: vm01,vm02
   [string[]]$VMs,
   [Parameter(Mandatory=$true)]
   #Cluste Name. Ex: Cluster01.contoso.local
   [string]$Cluster,
   [Parameter(Mandatory=$true)]
   #New destination to VM Config, Snaps and VHDs, ex: C:\ClusterStorage\Volume01
   [string]$DestinationPath
) #end param 

foreach ($vm in $VMs){ 
#Create a folder to put vm files.
$Fullpath = $DestinationPath + "\" + $vm
#Show migration info to user
Write-Host "Moving Storage for vm:"$vm "to destination Storage path:"$Fullpath
#Move Storage VM to the new path
Move-VMStorage -CimSession $Cluster -DestinationStoragePath $Fullpath -Name $vm
 }


