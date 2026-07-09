#This script adds users from a CSV file to a specific Microsoft 365 group using Microsoft Graph PowerShell SDK.

Connect-MgGraph -Scopes "GroupMember.ReadWrite.All","User.Read.All"

$GroupName = "<GROUP-NAME>"
$GroupId = (Get-MgGroup -Filter "displayName eq '$GroupName'").Id

$Users = Import-Csv "C:\Temp\Users.csv"

foreach ($User in $Users) {
    try {
        $UserObject = Get-MgUser -UserId $User.UserPrincipalName -ErrorAction Stop
        New-MgGroupMemberByRef `
            -GroupId $GroupId `
            -BodyParameter @{
                "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($UserObject.Id)"
            }

        Write-Host "Added $($User.UserPrincipalName)" -ForegroundColor Green
    }
    catch {

        Write-Host "Failed: $($User.UserPrincipalName)" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}
