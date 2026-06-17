Connect-MgGraph -Scopes "Group.Read.All"

$output_fn = ("c:\temp\AllEntraExport_GroupTypes_{0:yyyyMMdd_HHmmss}.csv" -f (Get-Date))

Write-Host "Retrieving group types from Entra ID..." -ForegroundColor Cyan

Get-MgGroup -All -Property DisplayName, GroupTypes, MailEnabled, SecurityEnabled |
Select-Object DisplayName,
    @{Name="GroupType"; Expression={
        $gt   = $_.GroupTypes
        $mail = $_.MailEnabled
        $sec  = $_.SecurityEnabled

        if ($gt -contains "Unified")   { "M365" }
        elseif ($sec -and $mail)       { "Mail-Enabled" }
        elseif ($sec -and -not $mail)  { "Security" }
        elseif ($mail -and -not $sec)  { "Distribution" }
        else                           { "Unknown" }
    }} |
Export-Csv -Path $output_fn -NoTypeInformation -Delimiter ';' -Encoding UTF8

Write-Host "Export complete: $output_fn" -ForegroundColor Green

Disconnect-MgGraph
