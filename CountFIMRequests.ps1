Add-PSSnapin FIMAutomation

$cutoffDate = (Get-Date).AddDays(-90)

Export-FIMConfig -CustomConfig "/Request[CreatedTime<'$($cutoffDate.ToString("s"))']" |
Measure-Object


--------------



Add-PSSnapin FIMAutomation

$cutoffDate = (Get-Date).AddDays(-90)

Export-FIMConfig `
    -OnlyBaseResources `
    -CustomConfig "/Request[CreatedTime<'$($cutoffDate.ToString("s"))']" |
    Measure-Object