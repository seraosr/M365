# Get all synced users with password policies and export to CSV

Connect-MgGraph -Scopes "User.ReadWrite.All","Directory.ReadWrite.All" -NoWelcome

$users = Get-MgUser -All -Property "id,displayName,userPrincipalName,onPremisesSyncEnabled,accountEnabled,passwordPolicies"
$report = $users | Select-Object `
  DisplayName,
  UserPrincipalName,
  OnPremisesSyncEnabled,
  @{Name="PasswordPolicies";Expression={
      if ($null -eq $_.PasswordPolicies) { "<null>" } else { $_.PasswordPolicies }
  }},
  @{Name="PolicyState";Expression={
      if ($null -eq $_.PasswordPolicies) { "Null" }
      elseif ($_.PasswordPolicies -eq "None") { "None" }
      else { "Override" }
  }}
$report | Export-Csv "C:\temp\PasswordPolicies_Audit.csv" -NoTypeInformation -Encoding UTF8
