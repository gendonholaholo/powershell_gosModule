# WindowsShortcuts.psm1
# Module containing Windows-specific shortcuts and aliases

# Function to set common Windows aliases
function Set-WindowsAliases {
    # Navigation
    Set-Alias -Name ls -Value Get-ChildItem -Option AllScope
    Set-Alias -Name ll -Value Get-ChildItem -Option AllScope
    Set-Alias -Name la -Value Get-ChildItem -Option AllScope
    Set-Alias -Name cd -Value Set-Location -Option AllScope
    Set-Alias -Name pwd -Value Get-Location -Option AllScope
    Set-Alias -Name clear -Value Clear-Host -Option AllScope
    
    # File operations
    Set-Alias -Name cp -Value Copy-Item -Option AllScope
    Set-Alias -Name mv -Value Move-Item -Option AllScope
    Set-Alias -Name rm -Value Remove-Item -Option AllScope
    Set-Alias -Name cat -Value Get-Content -Option AllScope
    
    # Process management
    Set-Alias -Name ps -Value Get-Process -Option AllScope
    Set-Alias -Name kill -Value Stop-Process -Option AllScope
}

# Function to get Windows system information
function Get-WindowsSystemInfo {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $cs = Get-CimInstance -ClassName Win32_ComputerSystem
    
    [PSCustomObject]@{
        OSVersion = $os.Version
        OSName = $os.Caption
        Architecture = $os.OSArchitecture
        Manufacturer = $cs.Manufacturer
        Model = $cs.Model
        Memory = "$([math]::Round($cs.TotalPhysicalMemory / 1GB, 2)) GB"
        LastBoot = $os.LastBootUpTime
    }
}

# Export functions
Export-ModuleMember -Function Set-WindowsAliases, Get-WindowsSystemInfo
Export-ModuleMember -Alias ls, ll, la, cd, pwd, clear, cp, mv, rm, cat, ps, kill 