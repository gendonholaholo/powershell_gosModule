# SummaryAgent.ps1
# Agen untuk memberikan ringkasan dan penjelasan singkat

using module ..\GosModule.psm1

class SummaryAgent : BaseAgent {
    SummaryAgent() : base("AnalisisRingkasan", "memberikan ringkasan singkat dan penjelasan yang jelas", "summary") { }
    
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
Sebagai pakar dokumentasi teknis, mohon berikan ringkasan dari konten berikut:

$content

Mohon berikan ringkasan yang jelas dan singkat yang mencakup:
1. Tujuan utama dan fungsionalitas
2. Komponen dan fitur utama
3. Dependensi atau persyaratan penting
4. Pola desain atau pendekatan yang digunakan
5. Poin penting untuk pengguna atau pengembang

Fokus pada kejelasan dan kelengkapan sambil tetap ringkas.
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