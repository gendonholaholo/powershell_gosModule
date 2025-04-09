# Import required modules
Import-Module (Join-Path $PSScriptRoot "GosModule.psm1") -Force

function Invoke-AIRequest {
    param(
        [string]$Question
    )
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $Global:GosAPIKey"
        }
        
        $body = @{
            model = $Global:GosAPIModel
            messages = @(
                @{
                    role = "system"
                    content = "You are a helpful AI assistant that answers questions in Indonesian."
                },
                @{
                    role = "user"
                    content = $Question
                }
            )
            max_tokens = $Global:GosAPIMaxTokens
            temperature = $Global:GosAPITemperature
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri $Global:GosAPIEndpoint -Method Post -Headers $headers -Body $body
        return $response.choices[0].message.content
    }
    catch {
        Write-Warning "Error calling OpenAI API. Falling back to Groq..."
        try {
            $headers = @{
                "Content-Type" = "application/json"
                "Authorization" = "Bearer $Global:GroqAPIKey"
            }
            
            $body = @{
                model = $Global:GroqAPIModel
                messages = @(
                    @{
                        role = "system"
                        content = "You are a helpful AI assistant that answers questions in Indonesian."
                    },
                    @{
                        role = "user"
                        content = $Question
                    }
                )
                max_tokens = $Global:GroqAPIMaxTokens
                temperature = $Global:GroqAPITemperature
            } | ConvertTo-Json
            
            $response = Invoke-RestMethod -Uri $Global:GroqAPIEndpoint -Method Post -Headers $headers -Body $body
            return $response.choices[0].message.content
        }
        catch {
            Write-Error "Failed to call both OpenAI and Groq APIs: $_"
            return "Error: Failed to get response from AI services."
        }
    }
}

function Format-Response {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )
    
    # Fixed width settings
    $contentWidth = 55      # Width of content
    $padding = 2           # Spaces on each side
    $totalWidth = $contentWidth + ($padding * 2) + 2  # Total width including borders
    
    # Split text into paragraphs
    $paragraphs = $Text -split "(\r?\n){2,}"
    $wrappedLines = @()
    
    foreach ($paragraph in $paragraphs) {
        if (-not [string]::IsNullOrWhiteSpace($paragraph)) {
            $words = $paragraph.Trim() -split '\s+'
            $currentLine = ""
            
            foreach ($word in $words) {
                if ($currentLine.Length -eq 0) {
                    $currentLine = $word
                }
                elseif (($currentLine.Length + 1 + $word.Length) -le $contentWidth) {
                    $currentLine += " $word"
                }
                else {
                    $wrappedLines += $currentLine
                    $currentLine = $word
                }
            }
            
            if ($currentLine.Length -gt 0) {
                $wrappedLines += $currentLine
            }
            
            # Add blank line after paragraph (except for last paragraph)
            if ($paragraph -ne $paragraphs[-1]) {
                $wrappedLines += ""
            }
        }
    }
    
    # Create box
    $border = "─" * ($totalWidth - 2)
    $output = "`n╭$border╮`n"
    
    foreach ($line in $wrappedLines) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            # Empty line for paragraph separation
            $output += "│" + (" " * ($totalWidth - 2)) + "│`n"
        }
        else {
            # Add padding to content
            $paddedLine = (" " * $padding) + $line.PadRight($contentWidth) + (" " * $padding)
            $output += "│$paddedLine│`n"
        }
    }
    
    $output += "╰$border╯`n"
    Write-Host $output -ForegroundColor Green
}

# Get the question from arguments
$Question = $args[0]

if (-not $Question) {
    Write-Error "Please provide a question"
    exit 1
}

try {
    # Get response from AI
    $result = Invoke-AIRequest -Question $Question
    
    # Format and display result
    Format-Response -Text $result
}
catch {
    Write-Error "Error processing question: $_"
    exit 1
} 