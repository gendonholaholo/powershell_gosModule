# SummaryAgent.ps1
# Agent for providing concise summaries and explanations

using module ..\GosModule.psm1

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
    
    [string]FormatPrompt([string]$content) {
        return @"
As a technical documentation expert, please provide a summary of the following:

$content

Please provide a clear and concise summary covering:
1. Main purpose and functionality
2. Key components and features
3. Important dependencies or requirements
4. Notable design patterns or approaches
5. Key takeaways for users or developers

Focus on clarity and comprehensiveness while maintaining brevity.
"@
    }

    [object] ProcessWithOpenAI([object]$input) {
        $prompt = @"
Silakan berikan ringkasan singkat dan terstruktur dalam Bahasa Indonesia untuk file berikut:

$($input.Content)

Mohon berikan ringkasan yang mencakup:
1. Tujuan utama file
2. Komponen utama
3. Dependensi penting
4. Fitur menarik
5. Catatan khusus
"@

        $body = @{
            model = $this.LLM.Model
            messages = @(
                @{
                    role = "system"
                    content = "Anda adalah pakar dalam meringkas kode dan memberikan penjelasan teknis dalam Bahasa Indonesia."
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
Silakan berikan ringkasan singkat dan terstruktur dalam Bahasa Indonesia untuk file berikut:

$($input.Content)

Mohon berikan ringkasan yang mencakup:
1. Tujuan utama file
2. Komponen utama
3. Dependensi penting
4. Fitur menarik
5. Catatan khusus
"@

        $body = @{
            model = $this.LLM.Model
            messages = @(
                @{
                    role = "system"
                    content = "Anda adalah pakar dalam meringkas kode dan memberikan penjelasan teknis dalam Bahasa Indonesia."
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