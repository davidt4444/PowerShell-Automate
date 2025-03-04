# Import SQL Server module if needed
# Import-Module SqlServer

# Define connection details
$sourceServer = "SourceServer"
$destServer = "DestinationServer"
$sourceDB = "SourceDB"
$destDB = "DestinationDB"

# SQL query
$query = "INSERT INTO [$destDB].[dbo].[DestinationTable]
          SELECT * FROM [$sourceDB].[dbo].[SourceTable]"

try {
    Invoke-Sqlcmd -ServerInstance $destServer -Database $destDB -Query $query
    Write-Host "Data transfer completed successfully!"
}
catch {
    Write-Host "Error occurred: $_"
}
