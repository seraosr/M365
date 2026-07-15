Connect-MgGraph -Scopes "Application.Read.All", "User.Read.All", "Group.Read.All"

$output_fn = ("c:\temp\AllEntraExport_EnterpriseApps_{0:yyyyMMdd_HHmmss}.csv" -f (Get-Date))

$results   = @()
$userCache = @{}

Write-Host "Retrieving enterprise apps from Entra ID..." -ForegroundColor Cyan

$apps = Get-MgServicePrincipal -All `
    -Filter "tags/any(t:t eq 'WindowsAzureActiveDirectoryIntegratedApp')" `
    -Property Id, DisplayName, AppId

foreach ($app in $apps) {
    Write-Host "Processing: $($app.DisplayName)" -ForegroundColor Gray

    # ── Assigned Users / Groups ───────────────────────────────────────────────
    $assignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $app.Id -All

    foreach ($assignment in $assignments) {

        if ($assignment.PrincipalType -eq "User") {
            # Direct user assignment
            if (-not $userCache.ContainsKey($assignment.PrincipalId)) {
                $user = Get-MgUser -UserId $assignment.PrincipalId `
                    -Property UserPrincipalName -ErrorAction SilentlyContinue
                $userCache[$assignment.PrincipalId] = $user.UserPrincipalName
            }
            $results += [PSCustomObject]@{
                AppName       = $app.DisplayName
                AppId         = $app.AppId
                PrincipalName = $assignment.PrincipalDisplayName
                PrincipalUPN  = $userCache[$assignment.PrincipalId]
                PrincipalType = "User"
                AssignedVia   = "Direct"
                Role          = "Assigned"
            }

        } elseif ($assignment.PrincipalType -eq "Group") {
            # Group assignment — expand members
            $groupMembers = Get-MgGroupMember -GroupId $assignment.PrincipalId -All

            foreach ($member in $groupMembers) {
                if ($member.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.user") {
                    $memberId = $member.Id
                    if (-not $userCache.ContainsKey($memberId)) {
                        $userCache[$memberId] = $member.AdditionalProperties["userPrincipalName"]
                    }
                    $results += [PSCustomObject]@{
                        AppName       = $app.DisplayName
                        AppId         = $app.AppId
                        PrincipalName = $member.AdditionalProperties["displayName"]
                        PrincipalUPN  = $userCache[$memberId]
                        PrincipalType = "User"
                        AssignedVia   = $assignment.PrincipalDisplayName  # Group name
                        Role          = "Assigned"
                    }
                }
            }
        }
    }

    # ── Owners ────────────────────────────────────────────────────────────────
    $owners = Get-MgServicePrincipalOwner -ServicePrincipalId $app.Id -All

    foreach ($owner in $owners) {
        if ($owner.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.user") {
            $results += [PSCustomObject]@{
                AppName       = $app.DisplayName
                AppId         = $app.AppId
                PrincipalName = $owner.AdditionalProperties["displayName"]
                PrincipalUPN  = $owner.AdditionalProperties["userPrincipalName"]
                PrincipalType = "User"
                AssignedVia   = "Direct"
                Role          = "Owner"
            }
        }
    }
}

$results | Export-Csv -Path $output_fn -NoTypeInformation -Delimiter ';' -Encoding UTF8

Write-Host "Export complete: $output_fn" -ForegroundColor Green

Disconnect-MgGraph
