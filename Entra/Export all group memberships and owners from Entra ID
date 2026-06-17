$output_fn = ("c:\temp\AllEntraExport_GroupMemberships_{0:yyyyMMdd_HHmmss}.csv" -f (Get-Date))

Write-Host "Retrieving all groups from Entra ID..." -ForegroundColor Cyan

$results = @()
$groups = Get-MgGroup -All -Property Id, DisplayName

foreach ($group in $groups) {
    Write-Host "Processing: $($group.DisplayName)" -ForegroundColor Gray

    # Members
    $members = Get-MgGroupMember -GroupId $group.Id -All
    foreach ($member in $members) {
        if ($member.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.user") {
            $results += [PSCustomObject]@{
                GroupName = $group.DisplayName
                MemberUPN = $member.AdditionalProperties["userPrincipalName"]
                Role      = "Member"
            }
        }
    }

    # Owners
    $owners = Get-MgGroupOwner -GroupId $group.Id -All
    foreach ($owner in $owners) {
        if ($owner.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.user") {
            $results += [PSCustomObject]@{
                GroupName = $group.DisplayName
                MemberUPN = $owner.AdditionalProperties["userPrincipalName"]
                Role      = "Owner"
            }
        }
    }
}

$results | Export-Csv -Path $output_fn -NoTypeInformation -Delimiter ';' -Encoding UTF8

Write-Host "Export complete: $output_fn" -ForegroundColor Green

Disconnect-MgGraph
