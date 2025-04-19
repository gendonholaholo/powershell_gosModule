# OptimizationAgent.ps1
# Agen untuk menganalisis performa dan peluang optimasi

using module ..\GosModule.psm1

class OptimizationAgent : BaseAgent {
    OptimizationAgent() : base("AnalisisOptimasi", "optimasi performa dan peningkatan efisiensi", "optimization") { }
    
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
Sebagai pakar optimasi performa, mohon analisis kode berikut:

$content

Mohon berikan analisis detail yang mencakup:
1. Potensi optimasi performa
2. Penggunaan sumber daya yang tidak efisien
3. Saran untuk meningkatkan efisiensi
4. Praktik terbaik untuk optimasi
5. Rekomendasi spesifik untuk perbaikan

Fokus pada peningkatan performa dan pemanfaatan sumber daya.
"@
    }

    [object] ProcessWithOpenAI([object]$input) {
        $prompt = @"
Silakan analisis optimasi file $($input.Type) berikut:

$($input.Content)

Mohon berikan analisis optimasi terstruktur yang mencakup:
1. Potensi optimasi performa
2. Penggunaan resource yang tidak efisien
3. Saran untuk meningkatkan efisiensi
4. Praktik terbaik untuk optimasi
5. Rekomendasi spesifik untuk perbaikan
"@

        $body = @{
            model = $this.LLM.Model
            messages = @(
                @{
                    role = "system"
                    content = "Anda adalah pakar optimasi kode. Berikan analisis yang terstruktur dan mendalam tentang aspek optimasi dalam Bahasa Indonesia."
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
Silakan analisis optimasi file $($input.Type) berikut:

$($input.Content)

Mohon berikan analisis optimasi terstruktur yang mencakup:
1. Potensi optimasi performa
2. Penggunaan resource yang tidak efisien
3. Saran untuk meningkatkan efisiensi
4. Praktik terbaik untuk optimasi
5. Rekomendasi spesifik untuk perbaikan
"@

        $body = @{
            model = $this.LLM.Model
            messages = @(
                @{
                    role = "system"
                    content = "Anda adalah pakar optimasi kode. Berikan analisis yang terstruktur dan mendalam tentang aspek optimasi dalam Bahasa Indonesia."
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