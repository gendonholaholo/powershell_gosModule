function Get-CondaEnvironment {
    <#
    .SYNOPSIS
        Gets the current active conda environment.
    
    .DESCRIPTION
        This function retrieves the name of the currently active conda environment using multiple methods.
    
    .EXAMPLE
        Get-CondaEnvironment
    
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    param()
    
    # Check for conda environment in multiple ways
    $condaEnv = $null
    
    # Method 1: Check CONDA_DEFAULT_ENV
    if ($env:CONDA_DEFAULT_ENV) {
        $condaEnv = $env:CONDA_DEFAULT_ENV
    }
    
    # Method 2: Check CONDA_PREFIX
    if (-not $condaEnv -and $env:CONDA_PREFIX) {
        $condaEnv = Split-Path $env:CONDA_PREFIX -Leaf
    }
    
    # Method 3: Check if conda is in PATH and get active environment
    if (-not $condaEnv -and (Get-Command conda -ErrorAction SilentlyContinue)) {
        try {
            $condaInfo = conda info --json | ConvertFrom-Json
            if ($condaInfo.active_prefix) {
                $condaEnv = Split-Path $condaInfo.active_prefix -Leaf
            }
        }
        catch {
            Write-Debug "Failed to get conda info: $_"
        }
    }
    
    if ($condaEnv) {
        return "($condaEnv)"
    }
    return ""
} 