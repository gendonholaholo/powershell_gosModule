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
Sebagai asisten AI yang berspesialisasi dalam analisis $($this.Type), mohon analisis konten berikut:

$content

Mohon berikan analisis detail yang berfokus pada $($this.Description) dalam Bahasa Indonesia.
"@
    }

    [string]CallAPI([string]$prompt) {
        try {
            $headers = @{
                "Content-Type" = "application/json"
                "Authorization" = "Bearer $($this.LLM.APIKey)"
            }
            
            $body = @{
                model = $this.LLM.Model
                messages = @(
                    @{
                        role = "system"
                        content = "Anda adalah asisten AI yang berspesialisasi dalam analisis $($this.Type). Mohon berikan semua respons dalam Bahasa Indonesia."
                    },
                    @{
                        role = "user"
                        content = $prompt
                    }
                )
                max_tokens = $this.LLM.MaxTokens
                temperature = $this.LLM.Temperature
            } | ConvertTo-Json
            
            $response = Invoke-RestMethod -Uri $this.LLM.APIEndpoint -Method Post -Headers $headers -Body $body
            return $response.choices[0].message.content
        }
        catch {
            Write-Warning "Error memanggil OpenAI API. Beralih ke Groq..."
            try {
                $headers = @{
                    "Content-Type" = "application/json"
                    "Authorization" = "Bearer $($this.LLM.APIKey)"
                }
                
                $body = @{
                    model = $this.LLM.Model
                    messages = @(
                        @{
                            role = "system"
                            content = "Anda adalah asisten AI yang berspesialisasi dalam analisis $($this.Type). Mohon berikan semua respons dalam Bahasa Indonesia."
                        },
                        @{
                            role = "user"
                            content = $prompt
                        }
                    )
                    max_tokens = $this.LLM.MaxTokens
                    temperature = $this.LLM.Temperature
                } | ConvertTo-Json
                
                $response = Invoke-RestMethod -Uri $this.LLM.APIEndpoint -Method Post -Headers $headers -Body $body
                return $response.choices[0].message.content
            }
            catch {
                Write-Error "Gagal memanggil API OpenAI dan Groq: $_"
                return "Error: Gagal mendapatkan respons dari layanan AI."
            }
        }
    }
} 