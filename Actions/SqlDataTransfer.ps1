# Define parameters that Power Automate can pass
param (
    [Parameter(Mandatory=$true)]
    [string]$SourceServer,
    
    [Parameter(Mandatory=$true)]
    [string]$SourceDB,
    
    [Parameter(Mandatory=$true)]
    [string]$SourceTable,
    
    [Parameter(Mandatory=$true)]
    [string]$DestServer,
    
    [Parameter(Mandatory=$true)]
    [string]$DestDB,
    
    [Parameter(Mandatory=$true)]
    [string]$DestTable,
    
    [Parameter(Mandatory=$false)]
    [int]$BatchSize = 10000,
    
    [Parameter(Mandatory=$false)]
    [int]$Timeout = 600
)

# Define connection strings
$sourceConnStr = "Server=$SourceServer;Database=$SourceDB;Integrated Security=True;"
$destConnStr = "Server=$DestServer;Database=$DestDB;Integrated Security=True;"

# SQL query to select data from source table
$sqlQuery = "SELECT * FROM $SourceTable"

# Object to store results for Power Automate
$result = [PSCustomObject]@{
    Status = "Failed"
    RowsTransferred = 0
    ErrorMessage = ""
    ExecutionTimeSeconds = 0
}

$startTime = Get-Date

try {
    # Create and open source connection
    $sourceConn = New-Object System.Data.SqlClient.SqlConnection($sourceConnStr)
    $sourceConn.Open()

    # Create SQL command
    $command = $sourceConn.CreateCommand()
    $command.CommandText = $sqlQuery

    # Execute query and get data reader
    $reader = $command.ExecuteReader()

    # Create and open destination connection
    $destConn = New-Object System.Data.SqlClient.SqlConnection($destConnStr)
    $destConn.Open()

    # Create bulk copy object
    $bulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy($destConn)
    $bulkCopy.DestinationTableName = "$DestTable"
    $bulkCopy.BatchSize = $BatchSize
    $bulkCopy.BulkCopyTimeout = $Timeout

    # Write data from reader to destination table
    $bulkCopy.WriteToServer($reader)

    # Update result object
    $result.Status = "Success"
    $result.RowsTransferred = $bulkCopy.RowsCopied
    $result.ExecutionTimeSeconds = ((Get-Date) - $startTime).TotalSeconds

}
catch {
    $result.ErrorMessage = $_.Exception.Message
    $result.ExecutionTimeSeconds = ((Get-Date) - $startTime).TotalSeconds
}
finally {
    # Clean up
    if ($reader) { $reader.Close() }
    if ($sourceConn) { $sourceConn.Close() }
    if ($destConn) { $destConn.Close() }
    if ($bulkCopy) { $bulkCopy.Close() }
}

# Output result as JSON for Power Automate to consume
ConvertTo-Json -InputObject $result
