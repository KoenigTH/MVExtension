Add-PSSnapin FIMAutomation

$cutoffDate = (Get-Date).AddDays(-90)

$filter = "/Request[
    RequestStatus='Completed' and
    CreatedTime<'$($cutoffDate.ToString("s"))'
]"

Export-FIMConfig -CustomConfig $filter | `
ForEach-Object {

    $requestId = $_.ResourceManagementObject.ResourceManagementAttributes[
        "ObjectID"
    ].Value

    Write-Host "Deleting Request $requestId"

    Remove-FIMResource `
        -ObjectID $requestId `
        -Confirm:$false
}