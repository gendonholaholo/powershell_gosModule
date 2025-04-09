function Format-Response {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,

        [int]$MaxWidth = 40  # Default width for better readability
    )

    # Gunakan lebar terminal jika tersedia, fallback ke default
    try {
        $terminalWidth = $host.UI.RawUI.WindowSize.Width
        if (-not $terminalWidth -or $terminalWidth -lt 40) {
            $terminalWidth = $MaxWidth
        }
    } catch {
        $terminalWidth = $MaxWidth
    }

    $padding = 2
    $contentWidth = [Math]::Min($terminalWidth - ($padding * 2) - 4, $MaxWidth - ($padding * 2) - 4)
    $totalWidth = $contentWidth + ($padding * 2) + 2

    # Bangun border atas
    $border = "─" * ($totalWidth - 2)
    $output = "`n╭$border╮`n"

    # Bungkus teks per kata agar tidak memotong di tengah kata
    $words = $Text -split '\s+'
    $lines = @()
    $currentLine = ""

    foreach ($word in $words) {
        if (($currentLine.Length + $word.Length + 1) -le $contentWidth) {
            if ($currentLine) {
                $currentLine += " $word"
            } else {
                $currentLine = $word
            }
        } else {
            if ($currentLine) {
                $lines += $currentLine
            }
            $currentLine = $word
        }
    }
    if ($currentLine) { $lines += $currentLine }

    # Tambahkan isi teks ke dalam box
    foreach ($line in $lines) {
        $padded = $line.PadRight($contentWidth)
        $output += "│" + (" " * $padding) + $padded + (" " * $padding) + "│`n"
    }

    # Tutup box
    $output += "╰$border╯`n"

    # Tampilkan hasil ke layar
    Write-Host $output -ForegroundColor Green
}

# Export function
Export-ModuleMember -Function Format-Response 