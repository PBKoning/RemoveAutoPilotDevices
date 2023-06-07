# ********************************************************
# * REMOVE AUTOPILOT DEVICES BY Paul Koning - 07-06-2023 *
# ********************************************************

# This scripts reads a csv-file with serial numbers of AutoPilot devices.
# Each device is removed from:
#                               - The Endpoint device list      (endpoint.microsoft.com)
#                               - The AutoPilot device list     (endpoint.microsoft.com)
#                               - The Azure device list         (portal.azure.com)

# Execute this script from an elevated command prompt in with the command: powershell -ExecutionPolicy Bypass .\removeAutopilotDevices.ps1


# Connect to Microsoft services. You have to enter your credentials twice.
Connect-MsolService # Make shure to install the module first with:          Install-Module MSOnline
Connect-MSGraph     # Make shure to install the module first  with:         Install-Module -Name WindowsAutoPilotIntune
                    # Then run this command once:                           Import-Module Microsoft.Graph.Intune
                    # If you get an error that you are not allowed to run
                    # scripts then first change the Executionpolicy with:   Set-Executionpolicy RemoteSigned

$csvPath = ".\serialNumbers.csv"        # This csv-file contains the serial numbers of the AutoPilot devices. Each serialnumber has top be stored on a seperate line.
$logPath = ".\notFoundDevices.log"      # Serial numbers that are not found as AutoPilotdevices are stored in this logfile

# Read the CSV file
$serialNumbers = Get-Content -Path $csvPath

# Iterate over each serial number
foreach ($serialNumber in $serialNumbers) {
    # Get the device by the serialnumber
    $device = Get-AutoPilotDevice | Where-Object SerialNumber -eq $serialNumber 

    if ($device) { # Device was found
        # Get required device information
        $deviceId = $device.azureActiveDirectoryDeviceId	
        $managedDeviceId = $device.managedDeviceId
		
        Write-Host "SerialNumber: $serialNumber"
        Write-Host "  DeviceId: $deviceId"
        Write-Host "  ManagedDeviceId: $managedDeviceId `n"		

        # Remove the Intune managed device
        Write-Host "Removing from Intune"
        Remove-IntuneManagedDevice -managedDeviceId $managedDeviceId

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
        Write-Host "Device with SerialNumber '$serialNumber' not found.`n`n"		
    }
}