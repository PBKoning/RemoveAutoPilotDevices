# RemoveAutoPilotDevices
Powershell script to remove AutoPilot devices completely by serial number

## What this script is about
Removing AutoPilot devices can be time consuming. You have to:
1. Remove the device from the device list in Endpoint
2. Remove the device from the AutoPilot device list (also found in Endpoint)
3. Remove the device from the device list in the Azure portal.

This script automates that tasks. All you need is a simple csv-file with the serial numbers of the AutoPilot devices.
Then start the script and the steps as described above are executed for all devices. 



## Disclaimer: **use of this script is at your own risk!**
