#Requires -Module Microsoft.Graph.Intune
#This script retrieves the serial number and other details of a device from Microsoft Intune using Microsoft Graph API based on the device name.


Connect-MgGraph -Scopes "User.Read.All","DeviceManagementManagedDevices.Read.All" -NoWelcome

$EntraDeviceName = "DESKTOP1"
$EntraRecord = Get-MgDevice -Filter "displayName eq '$EntraDeviceName'"

#Get Autopilot Device Record
$AutopilotDevice = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity -Filter "AzureActiveDirectoryDeviceId eq '$($EntraRecord.DeviceId)'" 
$AutopilotDevice | Select-Object SerialNumber,Model,Manufacturer,EnrollmentState,AzureActiveDirectoryDeviceId,ManagedDeviceId,LastContactedDateTime,ProductKey,GroupTag
