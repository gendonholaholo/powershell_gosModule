function Get-BatteryStatus {
    <#
    .SYNOPSIS
        Gets the current battery status of the system.
    
    .DESCRIPTION
        This function retrieves the current battery status including percentage, charging status,
        and remaining time if available.
    
    .EXAMPLE
        Get-BatteryStatus
    
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    param()
    
    try {
        $battery = Get-WmiObject -Class Win32_Battery -ErrorAction Stop
        if ($battery) {
            [PSCustomObject]@{
                Percentage = $battery.EstimatedChargeRemaining
                Status = if ($battery.BatteryStatus -eq 2) { "Charging" } else { "Discharging" }
                TimeRemaining = if ($battery.EstimatedRunTime -ne -1) { 
                    [TimeSpan]::FromMinutes($battery.EstimatedRunTime) 
                } else { $null }
            }
        } else {
            Write-Warning "No battery detected"
            return $null
        }
    }
    catch {
        Write-Error "Failed to get battery status: $_"
        return $null
    }
} 