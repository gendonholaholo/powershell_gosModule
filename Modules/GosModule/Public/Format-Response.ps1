function Format-Response {
    <#
    .SYNOPSIS
        Formats the response with professional CLI output formatting.
    
    .DESCRIPTION
        This function provides simple but effective output formatting with proper wrapping and alignment.
    
    .PARAMETER Text
        The text to be formatted.
    
    .PARAMETER Title
        Optional title for the output box.
    
    .PARAMETER Style
        The style of the output box. Can be 'default', 'info', 'warning', 'error', or 'success'.
    
    .EXAMPLE
        Format-Response "Hello, World!" -Title "Greeting" -Style "success"
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string]$Text = "Pesan Anda",
        
        [string]$Title = "",
        
        [ValidateSet('default', 'info', 'warning', 'error', 'success')]
        [string]$Style = 'default'
    )
    
    # Define style configurations
    $styles = @{
        default = @{ Color = [System.ConsoleColor]::Cyan }
        info = @{ Color = [System.ConsoleColor]::Blue }
        warning = @{ Color = [System.ConsoleColor]::Yellow }
        error = @{ Color = [System.ConsoleColor]::Red }
        success = @{ Color = [System.ConsoleColor]::Green }
    }
    
    # Apply style
    $Color = $styles[$Style].Color
    
    # Format output
    $output = "`n"
    if ($Title) {
        $output += "[$Title]`n"
    }
    $output += "$Text`n`n"
    
    # Write output with color
    Write-Host $output -ForegroundColor $Color
}

# Output linter function
function Test-OutputFormat {
    <#
    .SYNOPSIS
        Tests if the output format meets the required standards.
    
    .DESCRIPTION
        This function checks various aspects of the output formatting to ensure
        it meets the required standards for professional CLI output.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )
    
    $issues = @()
    
    # Check line length
    $lines = $Text -split "`n"
    foreach ($line in $lines) {
        if ($line.Length -gt 80) {
            $issues += "Line exceeds 80 characters: $line"
        }
    }
    
    # Check for proper spacing
    if ($Text -match "\s{3,}") {
        $issues += "Multiple consecutive spaces found"
    }
    
    # Check for proper line breaks
    if ($Text -match "\r\n") {
        $issues += "Mixed line endings found"
    }
    
    # Check for proper Unicode characters
    if ($Text -match "[^\x20-\x7E\u2500-\u257F]") {
        $issues += "Invalid or non-Unicode characters found"
    }
    
    # Return results
    if ($issues.Count -eq 0) {
        return $true
    } else {
        Write-Warning "Output format issues found:"
        $issues | ForEach-Object { Write-Warning $_ }
        return $false
    }
}

Export-ModuleMember -Function Format-Response 