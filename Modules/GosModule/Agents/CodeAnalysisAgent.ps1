# CodeAnalysisAgent.ps1
# Agent for analyzing code structure and patterns

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
    
    [string]FormatPrompt([string]$content) {
        return @"
As a code analysis expert, please analyze the following code:

$content

Please provide a detailed analysis covering:
1. Code structure and organization
2. Patterns and practices used
3. Potential issues or concerns
4. Suggestions for improvement
5. Best practices recommendations

Focus on maintainability, readability, and code quality.
"@
    }

    [object] ProcessWithOpenAI([object]$input) {
        $prompt = @"
Silakan analisis file $($input.Type) berikut:

$($input.Content)

Mohon berikan analisis terstruktur yang mencakup:
1. Struktur dan organisasi kode
2. Pola dan praktik pengkodean
3. Masalah potensial atau perbaikan yang diperlukan
4. Rekomendasi praktik terbaik
"@

        $body = @{
            model = $this.LLM.Model
            messages = @(
                @{
                    role = "system"
                    content = "Anda adalah pakar analisis kode. Berikan analisis terstruktur dan detail tentang kode dalam Bahasa Indonesia."
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
Silakan analisis file $($input.Type) berikut:

$($input.Content)

Mohon berikan analisis terstruktur yang mencakup:
1. Struktur dan organisasi kode
2. Pola dan praktik pengkodean
3. Masalah potensial atau perbaikan yang diperlukan
4. Rekomendasi praktik terbaik
"@

        $body = @{
            model = $this.LLM.Model
            messages = @(
                @{
                    role = "system"
                    content = "Anda adalah pakar analisis kode. Berikan analisis terstruktur dan detail tentang kode dalam Bahasa Indonesia."
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