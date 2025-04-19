# SecurityAnalysisAgent.ps1
# Agen untuk menganalisis masalah keamanan dan kerentanan

using module ..\GosModule.psm1

class SecurityAnalysisAgent : BaseAgent {
    SecurityAnalysisAgent() : base("AnalisisKeamanan", "masalah keamanan, kerentanan, dan praktik terbaik", "security") { }
    
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
Sebagai pakar analisis keamanan, mohon analisis kode berikut untuk masalah keamanan:

$content

Mohon berikan analisis detail yang mencakup:
1. Kerentanan keamanan potensial
2. Masalah autentikasi dan otorisasi
3. Masalah penanganan data dan privasi
4. Validasi dan sanitasi input
5. Rekomendasi praktik keamanan terbaik

Fokus pada identifikasi dan mitigasi risiko keamanan.
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