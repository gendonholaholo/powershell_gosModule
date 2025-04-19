# GosModule.psm1
using namespace System.Management.Automation

# Cache configuration
$script:CachePath = Join-Path $PSScriptRoot "cache"
$script:MaxCacheAge = 24 # hours

# Initialize cache directory if it doesn't exist
if (-not (Test-Path $script:CachePath)) {
    New-Item -ItemType Directory -Path $script:CachePath | Out-Null
}

function Get-CacheKey {
    param(
        [string]$FilePath,
        [string]$Question,
        [string]$AgentType
    )
    
    if (-not [string]::IsNullOrEmpty($FilePath)) {
        $fileHash = (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash
        return "$($fileHash)_$($AgentType)"
    }
    elseif (-not [string]::IsNullOrEmpty($Question)) {
        $questionHash = [System.BitConverter]::ToString(
            [System.Security.Cryptography.SHA256]::Create().ComputeHash(
                [System.Text.Encoding]::UTF8.GetBytes($Question)
            )
        ) -replace '-', ''
        return "$($questionHash)_$($AgentType)"
    }
    else {
        return "$([guid]::NewGuid())_$($AgentType)"
    }
}

function Get-CachedData {
    param(
        [string]$Key
    )
    
    $cacheFile = Join-Path $script:CachePath "$Key.json"
    if (Test-Path $cacheFile) {
        $cacheData = Get-Content $cacheFile | ConvertFrom-Json
        $cacheAge = (Get-Date) - [DateTime]::Parse($cacheData.Timestamp)
        if ($cacheAge.TotalHours -lt $script:MaxCacheAge) {
            return $cacheData.Data
        }
        else {
            Remove-Item $cacheFile -Force
        }
    }
    return $null
}

function Set-CachedData {
    param(
        [string]$Key,
        [object]$Data
    )
    
    $cacheFile = Join-Path $script:CachePath "$Key.json"
    $cacheData = @{
        Timestamp = (Get-Date).ToString("o")
        Data = $Data
    }
    $cacheData | ConvertTo-Json | Set-Content $cacheFile
}

function Clear-Cache {
    Get-ChildItem $script:CachePath | Remove-Item -Force
}

# Define the base agent class
class BaseAgent {
    [string]$Name
    [string]$Description
    [string]$Type
    
    BaseAgent([string]$name, [string]$description, [string]$type) {
        $this.Name = $name
        $this.Description = $description
        $this.Type = $type
    }
    
    [string]Process([hashtable]$input) {
        throw "Process method must be implemented by derived classes"
    }
    
    [string]FormatPrompt([string]$content) {
        return @"
As an AI assistant specializing in $($this.Type) analysis, please analyze the following content:

$content

Please provide a detailed analysis focusing on $($this.Description).
"@
    }
    
    [string]CallAPI([string]$prompt) {
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
                        content = "You are an AI assistant specializing in $($this.Type) analysis."
                    },
                    @{
                        role = "user"
                        content = $prompt
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
                            content = "You are an AI assistant specializing in $($this.Type) analysis."
                        },
                        @{
                            role = "user"
                            content = $prompt
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
}

# Define agent classes
class CodeAnalysisAgent : BaseAgent {
    CodeAnalysisAgent() : base("CodeAnalysis", "code structure, patterns, and best practices", "code") { }
    
    [string]Process([hashtable]$input) {
        $content = if ($input.ContainsKey("Path")) {
            Get-Content -Path $input.Path -Raw
        } else {
            $input.Content
        }
        
        $prompt = $this.FormatPrompt($content)
        return $this.CallAPI($prompt)
    }
}

class SecurityAnalysisAgent : BaseAgent {
    SecurityAnalysisAgent() : base("SecurityAnalysis", "security concerns, vulnerabilities, and best practices", "security") { }
    
    [string]Process([hashtable]$input) {
        $content = if ($input.ContainsKey("Path")) {
            Get-Content -Path $input.Path -Raw
        } else {
            $input.Content
        }
        
        $prompt = $this.FormatPrompt($content)
        return $this.CallAPI($prompt)
    }
}

class OptimizationAgent : BaseAgent {
    OptimizationAgent() : base("OptimizationAnalysis", "performance optimization and efficiency improvements", "optimization") { }
    
    [string]Process([hashtable]$input) {
        $content = if ($input.ContainsKey("Path")) {
            Get-Content -Path $input.Path -Raw
        } else {
            $input.Content
        }
        
        $prompt = $this.FormatPrompt($content)
        return $this.CallAPI($prompt)
    }
}

class SummaryAgent : BaseAgent {
    SummaryAgent() : base("SummaryAnalysis", "providing concise summaries and clear explanations", "summary") { }
    
    [string]Process([hashtable]$input) {
        $content = if ($input.ContainsKey("Path")) {
            Get-Content -Path $input.Path -Raw
        } else {
            $input.Content
        }
        
        $prompt = $this.FormatPrompt($content)
        return $this.CallAPI($prompt)
    }
}

class CoordinatorAgent {
    [hashtable]$Agents
    
    CoordinatorAgent() {
        $this.Agents = @{
            code = [CodeAnalysisAgent]::new()
            security = [SecurityAnalysisAgent]::new()
            optimization = [OptimizationAgent]::new()
            summary = [SummaryAgent]::new()
        }
    }
    
    [string]Process([hashtable]$input) {
        if ($input.ContainsKey("Agent") -and $this.Agents.ContainsKey($input.Agent.ToLower())) {
            return $this.Agents[$input.Agent.ToLower()].Process($input)
        }
        
        if ($input.ContainsKey("Type") -and $input.Type -eq "question") {
            return $this.HandleQuestion($input)
        }
        
        return $this.HandleFileAnalysis($input)
    }
    
    [string]HandleQuestion([hashtable]$input) {
        $prompt = @"
Please answer the following question in Indonesian:

$($input.Content)

Provide a clear and direct answer, focusing on accuracy and helpfulness.
"@
        
        return $this.Agents["summary"].CallAPI($prompt)
    }
    
    [string]HandleFileAnalysis([hashtable]$input) {
        $results = @()
        
        foreach ($agent in $this.Agents.Values) {
            $results += $agent.Process($input)
        }
        
        return $results -join "`n`n---`n`n"
    }
}

# Import configuration
$configPath = Join-Path $PSScriptRoot "Config\config.ps1"
if (Test-Path $configPath) {
    . $configPath
}
else {
    Write-Warning "Configuration file not found at: $configPath"
}

# Import Windows-specific shortcuts and aliases
if ($IsWindows) {
    Import-Module -Name "$PSScriptRoot/Public/WindowsShortcuts.psm1" -Force
}

# Import all functions from Private folder
$privatePath = Join-Path $PSScriptRoot "Private"
if (Test-Path $privatePath) {
    Get-ChildItem -Path $privatePath -Filter "*.ps1" | ForEach-Object {
        . $_.FullName
    }
}

# Import all functions from Public folder
$publicPath = Join-Path $PSScriptRoot "Public"
if (Test-Path $publicPath) {
    Get-ChildItem -Path $publicPath -Filter "*.ps1" | ForEach-Object {
        . $_.FullName
    }
}

# Export public functions
Export-ModuleMember -Function (Get-ChildItem -Path $publicPath -Filter "*.ps1" | Select-Object -ExpandProperty BaseName)

# Export classes
Export-ModuleMember -Variable @('BaseAgent', 'CodeAnalysisAgent', 'SecurityAnalysisAgent', 'OptimizationAgent', 'SummaryAgent', 'CoordinatorAgent')

# Function to initialize conda in PowerShell
function Initialize-Conda {
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

# Function to get active conda environment
function Get-CondaEnvironment {
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

# Function to show loading indicator
function Show-LoadingIndicator {
    [CmdletBinding()]
    param()
    
    Write-Host "Loading..." -NoNewline
    Write-Host "`r" -NoNewline
}

# Function to format the prompt
function prompt {
    # Get conda environment status
    $condaStatus = Get-CondaEnvironment
    
    # Get current directory
    $currentDir = (Get-Location).Path
    
    # Get current time
    $currentTime = Get-Date -Format "HH:mm:ss"
    
    # Get battery status if available
    $batteryStatus = ""
    if (Get-Command Get-BatteryStatus -ErrorAction SilentlyContinue) {
        $battery = Get-BatteryStatus
        $batteryStatus = "[$($battery.Percentage)%]"
    }
    
    # Format the prompt without boxes
    $prompt = "`nGos@$env:COMPUTERNAME [$currentDir] $condaStatus $batteryStatus [ $currentTime]`n> "
    
    return $prompt
}

# Function to make AI requests
function Invoke-AIRequest {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Content,
        [string]$Type = "question",
        [string]$Agent = ""
    )
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $Global:GosAPIKey"
        }
        
        $systemPrompt = if ($Type -eq "file") {
            if ($Agent) {
                switch ($Agent) {
                    "code" { "You are a code analysis expert. Analyze the following code and provide detailed feedback on structure, patterns, and best practices." }
                    "security" { "You are a security analysis expert. Analyze the following code for security vulnerabilities and provide recommendations." }
                    "optimization" { "You are a performance optimization expert. Analyze the following code and provide suggestions for improving efficiency." }
                    "summary" { "You are a technical documentation expert. Provide a clear and concise summary of the following code." }
                    default { "You are a helpful AI assistant that analyzes code and provides feedback." }
                }
            }
            else {
                "You are a helpful AI assistant that analyzes code and provides comprehensive feedback."
            }
        }
        else {
            "You are a helpful AI assistant that answers questions in Indonesian."
        }
        
        $body = @{
            model = $Global:GosAPIModel
            messages = @(
                @{
                    role = "system"
                    content = $systemPrompt
                },
                @{
                    role = "user"
                    content = $Content
                }
            )
            max_tokens = $Global:GosAPIMaxTokens
            temperature = $Global:GosAPITemperature
        } | ConvertTo-Json -Depth 10
        
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
                        content = $systemPrompt
                    },
                    @{
                        role = "user"
                        content = $Content
                    }
                )
                max_tokens = $Global:GroqAPIMaxTokens
                temperature = $Global:GroqAPITemperature
            } | ConvertTo-Json -Depth 10
            
            $response = Invoke-RestMethod -Uri $Global:GroqAPIEndpoint -Method Post -Headers $headers -Body $body
            return $response.choices[0].message.content
        }
        catch {
            Write-Error "Failed to call both OpenAI and Groq APIs: $_"
            return "Error: Failed to get response from AI services."
        }
    }
}

# Format-Response function
function Format-Response {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Text,

        [Parameter(Position = 1)]
        [int]$MaxWidth = 80,

        [Parameter(Position = 2)]
        [System.ConsoleColor]$Color = [System.ConsoleColor]::Cyan,

        [Parameter(Position = 3)]
        [string]$Title = "",

        [Parameter(Position = 4)]
        [ValidateSet('default', 'info', 'warning', 'error', 'success')]
        [string]$Style = 'default'
    )
    
    # Clear the loading indicator
    Write-Host "`r" -NoNewline
    Write-Host " " -NoNewline
    Write-Host "`r" -NoNewline
    
    # Get terminal width if available
    try {
        $terminalWidth = $host.UI.RawUI.WindowSize.Width
        if ($terminalWidth -and $terminalWidth -gt 40) {
            $MaxWidth = [Math]::Min($terminalWidth - 4, $MaxWidth)
        }
    } catch {
        # Fallback to default width if terminal width can't be determined
        Write-Debug "Failed to get terminal width: $_"
    }
    
    # Define style configurations
    $styles = @{
        default = @{
            Color = [System.ConsoleColor]::Cyan
            Icon = '📝'
            BorderColor = [System.ConsoleColor]::DarkCyan
        }
        info = @{
            Color = [System.ConsoleColor]::Blue
            Icon = 'ℹ️'
            BorderColor = [System.ConsoleColor]::DarkBlue
        }
        warning = @{
            Color = [System.ConsoleColor]::Yellow
            Icon = '⚠️'
            BorderColor = [System.ConsoleColor]::DarkYellow
        }
        error = @{
            Color = [System.ConsoleColor]::Red
            Icon = '❌'
            BorderColor = [System.ConsoleColor]::DarkRed
        }
        success = @{
            Color = [System.ConsoleColor]::Green
            Icon = '✅'
            BorderColor = [System.ConsoleColor]::DarkGreen
        }
    }
    
    # Apply style
    $styleConfig = $styles[$Style]
    $Color = $styleConfig.Color
    $BorderColor = $styleConfig.BorderColor
    $Icon = $styleConfig.Icon
    
    # Define box drawing characters
    $boxChars = @{
        TopLeft = '╭'
        TopRight = '╮'
        BottomLeft = '╰'
        BottomRight = '╯'
        Horizontal = '─'
        Vertical = '│'
        Divider = '├'
        DividerRight = '┤'
        TitleLeft = '┤'
        TitleRight = '├'
    }
    
    # Process the text
    $processedText = $Text -replace '`n', "`n"  # Ensure proper line breaks
    $paragraphs = $processedText -split "(\r?\n){2,}"
    $wrappedLines = @()
    
    # Word wrap and process each paragraph
    foreach ($paragraph in $paragraphs) {
        if (-not [string]::IsNullOrWhiteSpace($paragraph)) {
            # Handle special content types
            $paragraph = $paragraph -replace 'https?://\S+', {
                param($match)
                if ($match.Length -gt $MaxWidth - 8) {
                    $match.Substring(0, $MaxWidth - 11) + '...'
                } else {
                    $match
                }
            }
            
            # Split paragraph into words
            $words = $paragraph.Trim() -split '\s+'
            $currentLine = ""
            
            # Word wrap the paragraph
            foreach ($word in $words) {
                if ($currentLine.Length -eq 0) {
                    $currentLine = $word
                }
                elseif (($currentLine.Length + 1 + $word.Length) -le ($MaxWidth - 4)) {
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
    
    # Calculate box width based on longest line
    $maxLineLength = ($wrappedLines | Measure-Object -Property Length -Maximum).Maximum
    if ($Title) {
        $maxLineLength = [Math]::Max($maxLineLength, $Title.Length + 4)
    }
    $boxWidth = [Math]::Min($maxLineLength + 4, $MaxWidth)
    
    # Build the box
    $border = $boxChars.Horizontal * ($boxWidth - 2)
    $output = "`n"
    
    # Add title if provided
    if ($Title) {
        $titleLine = " $Icon $Title"
        $titlePadding = $boxWidth - $titleLine.Length - 2
        $output += "$($boxChars.TopLeft)$($boxChars.Horizontal * ($titleLine.Length + 1))$($boxChars.TitleLeft)$($boxChars.Horizontal * $titlePadding)$($boxChars.TopRight)`n"
        $output += "$($boxChars.Vertical)$titleLine $($boxChars.Vertical)" + (" " * $titlePadding) + "$($boxChars.Vertical)`n"
        $output += "$($boxChars.Divider)$($boxChars.Horizontal * ($boxWidth - 2))$($boxChars.DividerRight)`n"
    } else {
        $output += "$($boxChars.TopLeft)$border$($boxChars.TopRight)`n"
    }
    
    # Add content
    foreach ($line in $wrappedLines) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            # Empty line for paragraph separation
            $output += "$($boxChars.Vertical)" + (" " * ($boxWidth - 2)) + "$($boxChars.Vertical)`n"
        }
        else {
            # Add padding to content
            $paddedLine = $line.PadRight($boxWidth - 4)
            $output += "$($boxChars.Vertical) $paddedLine $($boxChars.Vertical)`n"
        }
    }
    
    $output += "$($boxChars.BottomLeft)$border$($boxChars.BottomRight)`n"
    
    # Write the formatted output with colors
    Write-Host $output -ForegroundColor $Color
}

# Export functions
Export-ModuleMember -Function @(
    'Format-Response',
    'Get-CacheKey',
    'Get-CachedData',
    'Set-CachedData',
    'Clear-Cache'
)

# Define gosTanya function
function gosTanya {
    [CmdletBinding(DefaultParameterSetName="Interactive")] # Make Interactive the default if no parameters are explicitly bound
    param(
        [Parameter(Position=0, ParameterSetName="Question")]
        [string]$Question,
        
        [Parameter(ParameterSetName="Read")]
        [string]$Read,
        
        [Parameter(ParameterSetName="Read")]
        [ValidateSet("code", "security", "optimization", "summary")]
        [string]$Agent,

        [Parameter(ParameterSetName="Read")] # Apply Style to Read mode
        [Parameter(ParameterSetName="Question")] # Apply Style to Question mode
        # Style parameter doesn't make as much sense for interactive mode, but keep it for consistency
        [Parameter(ParameterSetName="Interactive")] 
        [ValidateSet('default', 'info', 'warning', 'error', 'success')]
        [string]$Style = 'default'
    )
    
    # Check if running interactively (default parameter set is active)
    if ($PSCmdlet.ParameterSetName -eq "Interactive") {
        # --- Interactive Thread Mode ---
        Write-Host "Entering interactive mode. Type 'exit' or 'quit' to end." -ForegroundColor Green

        # Configuration checks are typically done when the module loads or globally,
        # so we might not need to repeat them here unless necessary.
        # Write-Host "Current Primary Model: $($Global:GosAPIModel)"
        # Write-Host "Current Fallback Model: $($Global:GroqAPIModel)"

        while ($true) {
            try {
                # Use Write-Host for the prompt in interactive mode for clarity
                Write-Host ">> " -NoNewline
                $userInput = Read-Host 

                if ($null -eq $userInput) { # Handle Ctrl+C during Read-Host
                    Write-Host "`nExiting interactive mode." -ForegroundColor Yellow
                    break
                }

                $userInputClean = $userInput.Trim()

                if ($userInputClean -in @('exit', 'quit')) {
                    Write-Host "Exiting interactive mode." -ForegroundColor Yellow
                    break
                }

                if (-not $userInputClean) {
                    continue # Ignore empty input
                }

                # Inform user about the primary model being attempted
                Write-Host "Attempting primary model: $($Global:GosAPIModel)" -ForegroundColor DarkCyan

                # Display thinking indicator before calling API
                Show-LoadingIndicator # Use the module's loading indicator
                # Call the module's Invoke-AIRequest for questions
                $aiResponse = Invoke-AIRequest -Content $userInputClean -Type "question"
                # Clear the loading indicator line
                Write-Host "`r$((' ' * ($Host.UI.RawUI.WindowSize.Width - 1)))`r" -NoNewline 


                # Display AI response using the module's formatter
                Format-Response -Text $aiResponse -Style $Style # Use the style parameter if needed

            }
            catch [System.Management.Automation.PipelineStoppedException] {
                 # Catch Ctrl+C specifically if it happens outside Read-Host
                Write-Host "`nExiting interactive mode (Ctrl+C detected)." -ForegroundColor Yellow
                break
            }
            catch {
                Write-Error "An error occurred in interactive mode: $_"
                # Continue the loop
            }
        }
    }
    else {
        # --- One-Shot Mode (Existing Logic) ---
        try {
            # Inform user about the primary model being attempted
            Write-Host "Attempting primary model: $($Global:GosAPIModel)" -ForegroundColor DarkCyan

            Show-LoadingIndicator

            $result = "" # Initialize result variable
            if ($PSCmdlet.ParameterSetName -eq "Read") {
                if (-not (Test-Path $Read)) {
                    Write-Error "File not found: $Read"
                    # Clear loading indicator on error before returning
                    Write-Host "`r$((' ' * ($Host.UI.RawUI.WindowSize.Width - 1)))`r" -NoNewline
                    return
                }
                
                $content = Get-Content -Path $Read -Raw
                if ($Agent) {
                    $result = Invoke-AIRequest -Content $content -Type "file" -Agent $Agent
                } else {
                    # If no specific agent, use the comprehensive file analysis
                    $result = Invoke-AIRequest -Content $content -Type "file" 
                }
            }
            elseif ($PSCmdlet.ParameterSetName -eq "Question") { # ParameterSetName is "Question"
                $result = Invoke-AIRequest -Content $Question -Type "question"
            }
            
            # Clear the loading indicator line before showing response
            Write-Host "`r$((' ' * ($Host.UI.RawUI.WindowSize.Width - 1)))`r" -NoNewline 
            
            # Format and display result with style
            Format-Response -Text $result -Style $Style
        }
        catch {
             # Clear the loading indicator line on error
            Write-Host "`r$((' ' * ($Host.UI.RawUI.WindowSize.Width - 1)))`r" -NoNewline
            Write-Error "Error processing request: $_"
        }
    }
} 
# Ensure gosTanya is exported if not already covered by the wildcard export
# Export-ModuleMember -Function 'gosTanya' # This might be redundant if already exported above 