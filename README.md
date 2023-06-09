# RemoveAutoPilotDevices
Powershell script to remove AutoPilot devices completely by serial number

## What this script is about
Removing AutoPilot devices can be time consuming. You have to:
1. Remove the device from the device list in Endpoint
2. Remove the device from the AutoPilot device list (also found in Endpoint)
3. Remove the device from the device list in the Azure portal.

This script automates that tasks. All you need is a simple csv-file with the serial numbers of the AutoPilot devices.
Then start the script and the steps as described above are executed for all devices in the list of serial numbers. 

### Disclaimer: **use of this script is at your own risk!**

## Step-by-step

1. Create a csv-file with the serial numbers.   
This is just a simple file, with no headers. Each line should contain just 1 serial number. This file **serialNumbers.csv** is stored in the same folder as the script.

2. Install the necessary powershell modules.  
You will need **MSOnline** and **WindowsAutoPilotIntune**.  
Start a powershell console with elevated rights and use these commands to install the modules:  
- **Install-Module MSOnline**
- **Install-Module -Name WindowsAutoPilotIntune**

~~Now you also have to execute this command once: **Import-Module Microsoft.Graph.Intune**   
You may get an error message that you don't have rights to execute scripts. In that case first you first have to change the Executionpolicy with: **Set-Executionpolicy RemoteSigned**  
There are also other ways to accomplish this, but this worked for me.~~
* *Seems to work in the script withoout doing this.* *

3. Execute the script.  
Start a command prompt with elevated rights. Navigate to the folder with the script and the csv-file, like this:
**cd "C:\path\to\folder\with\script"**

Then start the script with this command:
**powershell -ExecutionPolicy Bypass .\removeAutopilotDevices.ps1**

4. Monitor the results. The script will output the results to the screen. If a device can not be found in the list with AutoPilot devices the serial number will be written to a logfile named **notFoundDevices.log**. 

## Updates
**09-06-2023**   
Added several improvements to the scripts.  
- More information for the users during the execution of the script.
- It checks if the required modules are installed and stops the script if this is not the case.
- It checks if **Microsoft.Graph.Intune** is imported (although it seems that when the script runs it always works).
- It checks if a device has already been removed from Intune by hand.
- 
