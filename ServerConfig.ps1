<#
    .SYNOPSIS
        Downloads and configures Azure VMs.
#>

Param(
    [string]$Datadisk
)

if ($Datadisk -eq "true") {
    write-host "Partition disk"
    Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -DriveLetter F -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "ADDSDATA" -Confirm:$false
}
