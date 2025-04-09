function Show-LoadingIndicator {
    <#
    .SYNOPSIS
        Shows a loading animation in the console.
    
    .DESCRIPTION
        This function displays a simple loading animation using ASCII characters.
    
    .EXAMPLE
        Show-LoadingIndicator
    
    .OUTPUTS
        None
    #>
    [CmdletBinding()]
    param()
    
    $chars = @('|', '/', '-', '\')
    for ($i = 0; $i -lt 12; $i++) {
        Write-Host "`r$($chars[$i % $chars.Length])" -NoNewline
        Start-Sleep -Milliseconds 100
    }
} 