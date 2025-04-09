using namespace System.Management.Automation

class BaseAgent {
    [string]$Name
    [string]$Description
    [string]$Type
    [bool]$UseOpenAI = $true
    [object]$LLM

    BaseAgent([string]$name, [string]$description, [string]$type) {
        $this.Name = $name
        $this.Description = $description
        $this.Type = $type
        $this.InitializeLLM()
    }

    [void] InitializeLLM() {
        if ($this.UseOpenAI) {
            $this.LLM = @{
                APIKey = $Global:GosAPIKey
                APIEndpoint = $Global:GosAPIEndpoint
                Model = $Global:GosAPIModel
                MaxTokens = $Global:GosAPIMaxTokens
                Temperature = $Global:GosAPITemperature
            }
        } else {
            $this.LLM = @{
                APIKey = $Global:GroqAPIKey
                APIEndpoint = $Global:GroqAPIEndpoint
                Model = $Global:GroqAPIModel
                MaxTokens = $Global:GroqAPIMaxTokens
                Temperature = $Global:GroqAPITemperature
            }
        }
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