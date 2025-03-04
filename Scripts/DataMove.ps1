# Define connection strings
$sourceConnStr = "Server=SourceServer;Database=SourceDB;Integrated Security=True;"
$destConnStr = "Server=DestinationServer;Database=DestinationDB;Integrated Security=True;"

# SQL query to select data from source table
$sqlQuery = "SELECT * FROM SourceTable"

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
    $bulkCopy.DestinationTableName = "DestinationTable"
    
    # Optional: Map columns if column names differ between tables
    # $bulkCopy.ColumnMappings.Add("SourceColumn1", "DestColumn1")
    # $bulkCopy.ColumnMappings.Add("SourceColumn2", "DestColumn2")

    # Set batch size and timeout
    $bulkCopy.BatchSize = 10000
    $bulkCopy.BulkCopyTimeout = 600  # 10 minutes

    # Write data from reader to destination table
    $bulkCopy.WriteToServer($reader)

    Write-Host "Data transfer completed successfully!"
    Write-Host "Rows transferred: $($bulkCopy.RowsCopied)"

}
catch {
    Write-Host "Error occurred: $_"
}
finally {
    # Clean up
    if ($reader) { $reader.Close() }
    if ($sourceConn) { $sourceConn.Close() }
    if ($destConn) { $destConn.Close() }
    if ($bulkCopy) { $bulkCopy.Close() }
}
