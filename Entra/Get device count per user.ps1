#This script retrieves all users and their associated Windows devices from Microsoft Intune using Microsoft Graph API. It counts the number of Windows devices each user has and exports the results to a CSV file.

Connect-MgGraph -Scopes "User.Read.All","DeviceManagementManagedDevices.Read.All"

$users = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName |
         Select-Object Id,DisplayName,UserPrincipalName

$devices = Get-MgDeviceManagementManagedDevice -All |
    Where-Object { $_.OperatingSystem -eq "Windows" } |
    Select-Object DeviceName, UserId, LastSyncDateTime

$result = foreach ($device in $devices) {

    $user = if ($device.UserId) {
        $users | Where-Object { $_.Id -eq $device.UserId }
    } else {
        $null
    }

    $userDeviceCount = if ($device.UserId) {
        ($devices | Where-Object { $_.UserId -eq $device.UserId }).Count
    } else {
        0
    }

    [pscustomobject]@{
        DisplayName        = $user.DisplayName
        UserPrincipalName  = $user.UserPrincipalName
        WindowsDeviceCount = $userDeviceCount
        DeviceName         = $device.DeviceName
        LastContact        = $device.LastSyncDateTime?.ToLocalTime()
        HasPrimaryUser     = [bool]$device.UserId
    }
}

$result | Sort-Object HasPrimaryUser, DisplayName, DeviceName
``

$result | Export-Csv "C:\Temp\User-WindowsDeviceCount.csv" -NoTypeInformation
