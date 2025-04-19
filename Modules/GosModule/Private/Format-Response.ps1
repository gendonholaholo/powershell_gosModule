function Format-Response {
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

Export-ModuleMember -Function Format-Response 