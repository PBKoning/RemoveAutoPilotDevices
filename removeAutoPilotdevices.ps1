# ********************************************************
# * REMOVE AUTOPILOT DEVICES BY Paul Koning - 09-06-2023 *
# ********************************************************

# This scripts reads a csv-file with serial numbers of AutoPilot devices.
# Each device is removed from:
#                               - The Endpoint device list      (endpoint.microsoft.com)
#                               - The AutoPilot device list     (endpoint.microsoft.com)
#                               - The Azure device list         (portal.azure.com)
#
# Execute this script from an elevated command prompt with the command: powershell -ExecutionPolicy Bypass .\removeAutopilotDevices.ps1



function Check-Module ($m) {
# Function to check if a module is installed
    if (-not (Get-Module -ListAvailable -Name $m)) {
	    Write-Host "`nModule $m is not available, please install it first.`n`n" -ForegroundColor Red
	    EXIT 1
    } else {
		Write-Host "`nModule $m is available." -ForegroundColor Green
    }
}

# Clear screen and write info on screen
Clear-Host
Write-Host "`n********************************************************" -ForegroundColor Blue
Write-Host "* REMOVE AUTOPILOT DEVICES BY Paul Koning - 09-06-2023 *" -ForegroundColor Blue
Write-Host "********************************************************`n" -ForegroundColor Blue


# Checking if required modules are installed
# If there are any errors, make sure to install the modules first with:
#   Install-Module -Name MSOnline
#   Install-Module -Name WindowsAutoPilotIntune

Write-Host "`nChecking if required modules are installed."
Check-Module("MSOnline")
Check-Module("WindowsAutoPilotIntune")


# Connect with Microsoft services

Write-Host "`nConnecting to Microsoft services. Credentials have to be entered twice."

# Coneccting with MSGraph might give a problem if module Microsoft.Graph.Intune is not imported
try {
    Write-Host "`nConnecting to MSGraph"
    Connect-MSGraph
} 
catch {
    Write-Host "`nCould not execute Connect-MSGraph." -ForegroundColor Red
    Write-Host "Importing module and trying again.`n" -ForegroundColor Red
    Import-Module Microsoft.Graph.Intune
    	
    try {
        Connect-MSGraph        		
    }
    catch {
        Write-Host "Unexpected error: could still not execute Connect-MSGraph.`n`n" -ForegroundColor Red
        Exit 1
    }
}

Write-Host "Connecting to MsolService`n"		
Connect-MsolService 					

# Paths to files
$csvPath = ".\serialNumbers.csv"        # This csv-file contains the serial numbers of the AutoPilot devices. Each serial number has to be stored on a seperate line.
$logPath = ".\notFoundDevices.log"      # Serial numbers that are not found as AutoPilotdevices are stored in this logfile

# Append date and time to logfile
$dateTimeString = Get-Date -Format "dd-MM-yyy HH:mm:ss"
" " | Out-File -FilePath $logPath -Append
$dateTimeString | Out-File -FilePath $logPath -Append

# Read the CSV file
$serialNumbers = Get-Content -Path $csvPath

Write-Host "Deleting all AutoPilotdevices by serial number.`n"	

# Iterate over each serial number
foreach ($serialNumber in $serialNumbers) {
    # Get the device by the serial number
    $device = Get-AutoPilotDevice | Where-Object SerialNumber -eq $serialNumber 

    if ($device) { # Device was found
        # Get required device information
        $deviceId = $device.azureActiveDirectoryDeviceId	
        $managedDeviceId = $device.managedDeviceId
		
        Write-Host "SerialNumber: $serialNumber" -ForegroundColor Blue
        Write-Host "DeviceId: $deviceId"
        Write-Host "ManagedDeviceId: $managedDeviceId `n"		

        # Remove the Intune managed device
        Write-Host "Removing from Intune" 
        try {
            Remove-IntuneManagedDevice -managedDeviceId $managedDeviceId
        }
        catch {
            Write-Host "Could not remove from Intune devicelist. The device might have been already deleted manually in Intune." -ForegroundColor Red
        }			

        # Remove the AutoPilot device
        Write-Host "Removing from AutoPilot"
        Get-AutoPilotDevice | Where-Object SerialNumber -eq $serialNumber | Remove-AutopilotDevice		

        # Remove the Azure AD device
        Write-Host "Removing from AzureAD`n`n"
        Remove-MsolDevice -DeviceId $deviceId -Force

    } else { # Device was not found
        # Write the serial number from the device that was not found to the log file
        $serialNumber | Out-File -FilePath $logPath -Append
		
        # Write the not found serial number to the screen
        Write-Host "Device with SerialNumber '$serialNumber' not found.`n`n" -ForegroundColor Red	
    }
}
