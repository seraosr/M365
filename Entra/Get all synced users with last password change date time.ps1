#This script retrieves all users that are synced from on-premises to Entra ID (Azure AD) and exports their display name, user principal name, and last password change date/time to a CSV file.

Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

Get-MgUser -All -Property "id,displayName,userPrincipalName,onPremisesSyncEnabled,lastPasswordChangeDateTime" |
  Where-Object { $_.OnPremisesSyncEnabled -eq $true } |
  Select-Object DisplayName, UserPrincipalName, LastPasswordChangeDateTime |
  Sort-Object LastPasswordChangeDateTime -Descending |
  Export-Csv "C:\Temp\SyncedUsers_LastPasswordChange_Entra.csv" -NoTypeInformation -Encoding UTF8
