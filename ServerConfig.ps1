param([bool]$Datadisk)

if ($Datadisk) {
    write-host "Partition disk"
    Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -DriveLetter F -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "ADDSDATA" -Confirm:$false
}
