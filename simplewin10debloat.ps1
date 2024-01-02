# Create a system restore point
Write-Host "Creating a system restore point..."
Checkpoint-Computer -Description "Before Windows 10 Optimization Script" -RestorePointType "MODIFY_SETTINGS"

# Disable visual effects to improve performance
Write-Host "Disabling visual effects..."
[SystemPropertiesAdvanced]::Set("PerformanceVisualEffects", "AdjustForBestPerformance")

# Set Windows Update to manual
Write-Host "Setting Windows Update to manual..."
Set-Service -Name wuauserv -StartupType Manual

# Disable unnecessary startup programs
Write-Host "Disabling unnecessary startup programs..."
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$startupItems = Get-ItemProperty -Path $registryPath
foreach ($item in $startupItems.PSObject.Properties) {
    Write-Host "Disabling $($item.Name)..."
    Remove-ItemProperty -Path $registryPath -Name $item.Name
}

# Disable search indexing
Write-Host "Disabling search indexing..."
Set-Service -Name WSearch -StartupType Disabled

# Set a static pagefile size
Write-Host "Setting a static pagefile size..."
$ramSize = (Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB
$pagefileSize = [Math]::Ceiling($ramSize * 1.5)
Set-WmiInstance -Class Win32_PageFileSetting -Argument @{Name="C:\pagefile.sys";InitialSize=$pagefileSize;MaximumSize=$pagefileSize}

# Disable unnecessary Windows features
Write-Host "Disabling unnecessary Windows features..."
Disable-WindowsOptionalFeature -Online -FeatureName "Internet Explorer 11" -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName "Media Player" -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName "Print and Document Services" -NoRestart

# Remove unnecessary built-in apps
Write-Host "Removing unnecessary built-in apps..."
$appsToRemove = @(
    "Microsoft.Office.OneNote",
    "Microsoft.SkypeApp",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.BingFinance",
    "Microsoft.BingNews",
    "Microsoft.BingSports",
    "Microsoft.BingWeather",
    "Microsoft.BingTravel",
    "Microsoft.People"
)

foreach ($app in $appsToRemove) {
    Get-AppxPackage -Name $app | Remove-AppxPackage
}

# Reboot the computer
Write-Host "Rebooting the computer..."
Restart-Computer -Force

Write-Host "Optimizations completed. Please reboot your computer for the changes to take effect."
