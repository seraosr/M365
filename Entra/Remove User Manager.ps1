Connect-MgGraph -Scopes "User.ReadWrite.All"
Get-MgContext

$csvPath = "C:\temp\users.csv"
$rows = Import-Csv $csvPath

foreach ($r in $rows) {
  $u = $r.UserPrincipalName
  try {
    Remove-MgUserManagerByRef -UserId $u -ErrorAction Stop
    Write-Host "Cleared manager for $u" -ForegroundColor Green
  }
  catch {
    Write-Host "Failed for $u : $($_.Exception.Message)" -ForegroundColor Red
  }
}
