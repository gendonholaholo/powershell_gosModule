# CoordinatorAgent.ps1
# Agen untuk mengkoordinasikan dan mengelola agen lainnya

using module ..\GosModule.psm1

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
        
        if ($input.Type -eq "question") {
            return $this.HandleQuestion($input)
        }
        
        return $this.HandleFileAnalysis($input)
    }
    
    [string]HandleQuestion([hashtable]$input) {
        $prompt = @"
Mohon jawab pertanyaan berikut dalam Bahasa Indonesia:

$($input.Content)

Berikan jawaban yang jelas dan langsung, fokus pada keakuratan dan bermanfaat.
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