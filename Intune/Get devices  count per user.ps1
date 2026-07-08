#This script retrieves all users and their associated Windows devices from Microsoft Intune using Microsoft Graph API. It counts the number of Windows devices each user has and exports the results to a CSV file.

Connect-MgGraph -Scopes "User.Read.All","DeviceManagementManagedDevices.Read.All" -NoWelcome

$users = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName |
         Select-Object Id,DisplayName,UserPrincipalName

$userLookup = @{}
$users | ForEach-Object {
    $userLookup[$_.Id] = $_
}

$devices = Get-MgDeviceManagementManagedDevice -All |
    Where-Object { $_.OperatingSystem -eq "Windows" } |
    Select-Object DeviceName, UserId, LastSyncDateTime

$deviceCounts = $devices |
    Group-Object UserId -AsHashTable

$result = foreach ($device in $devices) {

    $user = if ($device.UserId) {
        $userLookup[$device.UserId]
    }

    [PSCustomObject]@{
        DisplayName        = $user.DisplayName
        UserPrincipalName  = $user.UserPrincipalName
        WindowsDeviceCount = if ($device.UserId) { $deviceCounts[$device.UserId].Count } else { 0 }
        DeviceName         = $device.DeviceName
        LastContact        = $device.LastSyncDateTime
        HasPrimaryUser     = [bool]$device.UserId
    }
}

$result |
    Sort-Object HasPrimaryUser, DisplayName, DeviceName |
    Export-Csv "C:\Temp\User-WindowsDeviceCount.csv" -NoTypeInformation
