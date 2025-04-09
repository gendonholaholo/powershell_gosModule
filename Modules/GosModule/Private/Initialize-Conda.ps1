function Initialize-Conda {
    <#
    .SYNOPSIS
        Initializes conda in PowerShell.
    
    .DESCRIPTION
        This function loads the conda profile and initializes conda in PowerShell.
    
    .EXAMPLE
        Initialize-Conda
    
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    param()
    
    # Check if conda is available
    if (-not (Get-Command conda -ErrorAction SilentlyContinue)) {
        Write-Warning "Conda not found in PATH. Please make sure conda is installed and initialized."
        return $false
    }

    # Load conda profile if it exists
    $condaProfile = Join-Path $env:USERPROFILE "Documents\WindowsPowerShell\profile.ps1"
    if (Test-Path $condaProfile) {
        . $condaProfile
        Write-Host "Conda profile loaded successfully" -ForegroundColor Green
        return $true
    } else {
        Write-Warning "Conda profile not found at $condaProfile"
        return $false
    }
} 