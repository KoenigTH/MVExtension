Import-Module LithnetRMA

$cutoff = (Get-Date).AddDays(-90)

Search-Resources `
    -ResourceType Request `
    -AttributesToGet ObjectID, CreatedTime |
    Where-Object {$_.CreatedTime -lt $cutoff} |
    Remove-Resource