# SecurityAnalysisAgent.ps1
# Agent for analyzing security concerns and vulnerabilities

using module ..\GosModule.psm1

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
    
    [string]FormatPrompt([string]$content) {
        return @"
As a security analysis expert, please analyze the following code for security concerns:

$content

Please provide a detailed security analysis covering:
1. Potential security vulnerabilities
2. Authentication and authorization concerns
3. Data handling and privacy issues
4. Input validation and sanitization
5. Security best practices recommendations

Focus on identifying and mitigating security risks.
"@
    }

    [object] ProcessWithOpenAI([object]$input) {
        $prompt = @"
Silakan analisis keamanan file $($input.Type) berikut:

$($input.Content)

Mohon berikan analisis keamanan terstruktur yang mencakup:
1. Potensi kerentanan
2. Masalah privasi
3. Risiko keamanan
4. Rekomendasi perbaikan
5. Praktik terbaik keamanan yang harus diterapkan
"@

        $body = @{
            model = $this.LLM.Model
            messages = @(
                @{
                    role = "system"
                    content = "Anda adalah pakar analisis keamanan kode. Berikan analisis yang terstruktur dan mendalam tentang aspek keamanan dalam Bahasa Indonesia."
                },
                @{
                    role = "user"
                    content = $prompt
                }
            )
            max_tokens = $this.LLM.MaxTokens
            temperature = $this.LLM.Temperature
        }

        $headers = @{
            "Authorization" = "Bearer $($this.LLM.APIKey)"
            "Content-Type" = "application/json"
        }

        $response = Invoke-RestMethod -Uri $this.LLM.APIEndpoint -Method Post -Headers $headers -Body ($body | ConvertTo-Json)
        return $response.choices[0].message.content
    }

    [object] ProcessWithGroq([object]$input) {
        $prompt = @"
Silakan analisis keamanan file $($input.Type) berikut:

$($input.Content)

Mohon berikan analisis keamanan terstruktur yang mencakup:
1. Potensi kerentanan
2. Masalah privasi
3. Risiko keamanan
4. Rekomendasi perbaikan
5. Praktik terbaik keamanan yang harus diterapkan
"@

        $body = @{
            model = $this.LLM.Model
            messages = @(
                @{
                    role = "system"
                    content = "Anda adalah pakar analisis keamanan kode. Berikan analisis yang terstruktur dan mendalam tentang aspek keamanan dalam Bahasa Indonesia."
                },
                @{
                    role = "user"
                    content = $prompt
                }
            )
            max_tokens = $this.LLM.MaxTokens
            temperature = $this.LLM.Temperature
        }

        $headers = @{
            "Authorization" = "Bearer $($this.LLM.APIKey)"
            "Content-Type" = "application/json"
        }

        $response = Invoke-RestMethod -Uri $this.LLM.APIEndpoint -Method Post -Headers $headers -Body ($body | ConvertTo-Json)
        return $response.choices[0].message.content
    }
} 