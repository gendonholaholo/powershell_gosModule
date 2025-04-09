function gosTanya {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0, ParameterSetName="Question")]
        [string]$Question,
        
        [Parameter(Mandatory=$true, ParameterSetName="Read")]
        [string]$Read,
        
        [Parameter(Mandatory=$false, ParameterSetName="Read")]
        [ValidateSet("code", "security", "optimization", "summary")]
        [string]$Agent
    )
    
    try {
        if ($PSCmdlet.ParameterSetName -eq "Read") {
            if (-not (Test-Path $Read)) {
                Write-Error "File not found: $Read"
                return
            }
            
            $content = Get-Content -Path $Read -Raw
            if ($Agent) {
                $result = Invoke-AIRequest -Content $content -Type "file" -Agent $Agent
            } else {
                $result = Invoke-AIRequest -Content $content -Type "file"
            }
        }
        else {
            $result = Invoke-AIRequest -Content $Question -Type "question"
        }
        
        # Format and display result using Format-Response from Private module
        Format-Response -Text $result
    }
    catch {
        Write-Error "Error processing request: $_"
    }
}

# Export function
Export-ModuleMember -Function gosTanya 