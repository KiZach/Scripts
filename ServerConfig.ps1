<#
    .SYNOPSIS
        Downloads and configures Azure VMs.
#>

Param(
    [string]$Datadisk,
    [string]$FirstDC,
    [string]$ExtraDC,
    [string]$AADSync,
    [string]$ADFS,
    [string]$FQDNDomainName,
    [string]$NetbiosDomainName,
    [string]$AdminName,
    [string]$RestorePassword
)

function DownloadFile
{
    Param([string]$Source,
        [string]$Destination)

        Try
        {
            Write-Host "Downloading $Source...";
            $webclient = New-Object System.Net.WebClient;
            $webclient.DownloadFile($Source,$Destination);
            Write-Host -Message "Downloaded $Source successful" -source "DownloadFile"
            Return $true
        }
        Catch
        {
            Write-Host -Message "Failed to download $Source" -source "DownloadFile"
            Return $false
        }
}

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

if ($ExtraDC -eq "true") {
    $SafeModeAdministratorPassword = $RestorePassword | ConvertTo-SecureString -asPlainText -Force
    $CredentialUser = "$NetbiosDomainName\$AdminName"
    $ADCredential = New-Object System.Management.Automation.PSCredential($CredentialUser,$SafeModeAdministratorPassword)    
    write-host "Configuring extra domain controller"
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
    Install-ADDSDomainController -DomainName $FQDNDomainName -InstallDns -Credential $ADCredential -SafeModeAdministratorPassword $SafeModeAdministratorPassword -DatabasePath "F:\NTDS" -LogPath "F:\NTDS" -SysvolPath "F:\Sysvol" -Force 
 }

 if ($AADSync -eq "true") {
    write-host "Installing AAD Connect"
    $DownloadDirectory = [Environment]::GetFolderPath("CommonDesktopDirectory")
    IF (!(DownloadFile -Source "https://download.microsoft.com/download/B/0/0/B00291D0-5A83-4DE7-86F5-980BC00DE05A/AzureADConnect.msi" -Destination "$DownloadDirectory\AzureADConnect.msi")) {
        Exit-Script -ExitCode 1
    }
 }

 if ($ADFS -eq "true") {
    write-host "Installing ADFS"
    Install-WindowsFeature ADFS-Federation -IncludeManagementTools
 }