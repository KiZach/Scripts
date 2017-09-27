<#
    .SYNOPSIS
        Downloads and configures Azure VMs.
#>

Param(
    [string]$Datadisk,
    [string]$FirstDC,
    [string]$FQDNDomainName,
    [string]$NetbiosDomainName,
    [string]$RestorePassword
)

if ($Datadisk -eq "true") {
    write-host "Partition disk"
    Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -DriveLetter F -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "DATA" -Confirm:$false
}

if ($FirstDC -eq "true") {
    $SafeModeAdministratorPassword = $RestorePassword | ConvertTo-SecureString -asPlainText -Force
    write-host "Configuring first domain controller"
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
    Install-ADDSForest -DomainName $FQDNDomainName -DomainNetbiosName $NetbiosDomainName -InstallDns -SafeModeAdministratorPassword $SafeModeAdministratorPassword -DatabasePath "F:\NTDS" -LogPath "F:\NTDS" -SysvolPath "F:\Sysvol" -Force      
}