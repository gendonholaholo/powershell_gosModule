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
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Text,

        [Parameter(Position = 1)]
        [string]$Title = "",

        [Parameter(Position = 2)]
        [ValidateSet('default', 'info', 'warning', 'error', 'success')]
        [string]$Style = 'default'
    )

    begin {
        # Define style configurations
        $styles = @{
            default = @{ Color = 'Cyan'; Icon = '>' }
            info = @{ Color = 'Blue'; Icon = 'i' }
            warning = @{ Color = 'Yellow'; Icon = '!' }
            error = @{ Color = 'Red'; Icon = 'x' }
            success = @{ Color = 'Green'; Icon = '√' }
        }
    }

    process {
        # Get style configuration
        $styleConfig = $styles[$Style]
        
        # Calculate width
        $width = 60
        $border = "─" * ($width - 2)
        
        # Build output
        $output = "`n"
        
        # Add title if provided
        if ($Title) {
            $titleLine = " $($styleConfig.Icon) $Title"
            $output += "╭$($border)╮`n"
            $output += "│$($titleLine.PadRight($width - 2))│`n"
            $output += "├$($border)┤`n"
        } else {
            $output += "╭$($border)╮`n"
        }
        
        # Add content with word wrap
        $words = $Text -split '\s+'
        $currentLine = ""
        
        foreach ($word in $words) {
            if ($currentLine.Length -eq 0) {
                $currentLine = $word
            }
            elseif (($currentLine.Length + 1 + $word.Length) -le ($width - 4)) {
                $currentLine += " $word"
            }
            else {
                $output += "│ $($currentLine.PadRight($width - 4)) │`n"
                $currentLine = $word
            }
        }
        
        if ($currentLine) {
            $output += "│ $($currentLine.PadRight($width - 4)) │`n"
        }
        
        $output += "╰$($border)╯`n"
        
        # Output with color
        Write-Host $output -ForegroundColor $styleConfig.Color
    }
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

# Penggunaan dasar
Format-Response "Pesan Anda"

# Dengan judul
Format-Response "Pesan Anda" -Title "Judul"

# Dengan gaya berbeda
Format-Response "Pesan Anda" -Style warning

# Menggunakan pipeline
"Pesan Anda" | Format-Response -Title "Dari Pipeline" 