using namespace System.Management.Automation

# Cache configuration
$script:CachePath = Join-Path $PSScriptRoot "cache"
$script:MaxCacheAge = 24 # hours

# Initialize cache directory if it doesn't exist
if (-not (Test-Path $script:CachePath)) {
    New-Item -ItemType Directory -Path $script:CachePath | Out-Null
}

function Get-CacheKey {
    param(
        [string]$FilePath,
        [string]$Question,
        [string]$AgentType
    )
    
    if (-not [string]::IsNullOrEmpty($FilePath)) {
        $fileHash = (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash
        return "$($fileHash)_$($AgentType)"
    }
    elseif (-not [string]::IsNullOrEmpty($Question)) {
        $questionHash = [System.BitConverter]::ToString(
            [System.Security.Cryptography.SHA256]::Create().ComputeHash(
                [System.Text.Encoding]::UTF8.GetBytes($Question)
            )
        ) -replace '-', ''
        return "$($questionHash)_$($AgentType)"
    }
    else {
        return "$([guid]::NewGuid())_$($AgentType)"
    }
}

function Get-CachedData {
    param(
        [string]$Key
    )
    
    $cacheFile = Join-Path $script:CachePath "$Key.json"
    if (Test-Path $cacheFile) {
        $cacheData = Get-Content $cacheFile | ConvertFrom-Json
        $cacheAge = (Get-Date) - [DateTime]::Parse($cacheData.Timestamp)
        if ($cacheAge.TotalHours -lt $script:MaxCacheAge) {
            return $cacheData.Data
        }
        else {
            Remove-Item $cacheFile -Force
        }
    }
    return $null
}

function Set-CachedData {
    param(
        [string]$Key,
        [object]$Data
    )
    
    $cacheFile = Join-Path $script:CachePath "$Key.json"
    $cacheData = @{
        Timestamp = (Get-Date).ToString("o")
        Data = $Data
    }
    $cacheData | ConvertTo-Json | Set-Content $cacheFile
}

function Clear-Cache {
    Get-ChildItem $script:CachePath | Remove-Item -Force
}

# Export functions
Export-ModuleMember -Function Get-CacheKey, Get-CachedData, Set-CachedData, Clear-Cache 