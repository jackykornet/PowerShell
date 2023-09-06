<# 
.SYNOPSIS 
      Plan a reboot on a remote server. This script will add or modify a scheduletask on the server
      If the tasks already exist, the date and time will be changed.
      the default reboot time is 3AM the next day
.DESCRIPTION 
      Describe the function in more detail.
.EXAMPLE 
      . "D:\Scripts\Beheerscripts\Set-ServerReboot.ps1" -ComputerName SW0123
.PARAMETER paramName 
      -ComputerName, the computer the reboot is planned

      -logfile, an aditional logfile path
#>
[CmdletBinding()]
param 
(
    [Parameter(Mandatory=$True,Position=1,
    ValueFromPipeline=$true)]
    [string]$ComputerName,

    [Parameter(Mandatory=$false)]
    [string]$logfile
) 

# This block is used to provide optional one-time pre-processing for the function. 
# The PowerShell runtime uses the code in this block one time for each instance of the function in the pipeline.
BEGIN {

    # Variables
    $CurrentDate = get-date -Format yyMMdd
    $HostName = Get-WMIObject Win32_ComputerSystem| Select-Object -ExpandProperty Name
    $UserName = $env:USERNAME
    # date to run (next day)
    $RunDate = (Get-Date).AddDays(1).tostring("MM/dd/yyyy")

    # Schedule Task variables
    $TaskInfo= [PSCustomObject]@{

        TaskName = 'RebootPlanner'
        Description =  "Planned Reboot Created On $(get-date) by script Set-ServerReboot from $hostname by $username "
        action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& {Restart-Computer -Force}"'
        trigger = New-ScheduledTaskTrigger -Once -At "$RunDate 4am"
        principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        settings = New-ScheduledTaskSettingsSet -MultipleInstances Paralle
    }

    # check if paramater logfile is not set, and set default if not.
    if([string]::IsNullOrWhiteSpace($logfile)){
        $logfile = ($MyInvocation.MyCommand.Path -replace '\.ps1$', "_$CurrentDate.log")
    }

    If(!(Test-Connection -ComputerName $ComputerName -Count 1 -quiet)){
        Write-Error "$ComputerName not reacheble"
        Exit
    }

    # import modules
    #Install-Module -Name PSFramework -Scope CurrentUser
    
    # start transcript
    Start-Transcript -Path $logfile

    # connect to computer
    #Enter-PSSession $ComputerName -RunAsAdministrator

} 

# This block is used to provide record-by-record processing for the function. 
# This block might be used any number of times, or not at all, depending on the input to the function.
PROCESS {


      # Do some stuff 
      try{
            Invoke-Command -ComputerName $ComputerName -Scriptblock {

                             
                if(Get-ScheduledTask | where{$_.TaskName -eq 'RebootPlanner'}){
            
                   write-host $args[0].TaskName"exist"

                   # Change the schedule to new data
                   Set-ScheduledTask -TaskName $args[0].TaskName -Action $args[0].action -Trigger $args[0].trigger -Settings $args[0].settings -Principal $args[0].principal -ErrorAction Stop

                   # output schedule task
                   Get-ScheduledTask | where{$_.TaskName -eq $args[0].TaskName}
        
                } else {

                   write-host $args[0].TaskName"NOT exist"
           
                   # Create a schedule
                   Register-ScheduledTask -TaskName $args[0].TaskName -Action $args[0].action -Trigger $args[0].trigger -Settings $args[0].settings -Principal $args[0].principal -Description $args[0].Description -ErrorAction Stop

                   # output schedule task
                   Get-ScheduledTask | where{$_.TaskName -eq $args[0].TaskName}
        
                }
           } -ArgumentList $TaskInfo

      }

      # Got an error do something else 
      catch{
      
        # write error
        Write-Error $_

      }

      # Runs even when an error is catch
      finally{

      }

}

# This block is used to provide optional one-time post-processing for the function.
END {
    
    # exit the ps session to the computer
    #Exit-PSSession

    # stop the transcript
    Stop-Transcript

}
