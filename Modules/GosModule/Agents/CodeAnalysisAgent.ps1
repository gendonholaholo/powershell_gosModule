# CodeAnalysisAgent.ps1
# Agen untuk menganalisis struktur kode dan pola

class CodeAnalysisAgent : BaseAgent {
    CodeAnalysisAgent() : base("AnalisisKode", "struktur kode, pola, dan praktik terbaik", "code") { }
    
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
Sebagai pakar analisis kode, mohon analisis kode berikut:

$content

Mohon berikan analisis detail yang mencakup:
1. Struktur dan organisasi kode
2. Pola dan praktik yang digunakan
3. Masalah atau kekhawatiran potensial
4. Saran untuk perbaikan
5. Rekomendasi praktik terbaik

Fokus pada kemudahan pemeliharaan, keterbacaan, dan kualitas kode.
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