using System;
using System.Management.Automation;

namespace GosModule
{
    class Program
    {
        static void Main(string[] args)
        {
            using (PowerShell powerShell = PowerShell.Create())
            {
                powerShell.AddScript(@"
                    Set-PSReadLineOption -EditMode Vi
                    Set-PSReadLineKeyHandler -Key 'Ctrl+p' -Function PreviousHistory
                    Set-PSReadLineKeyHandler -Key 'Ctrl+n' -Function NextHistory
                    Set-PSReadLineKeyHandler -Key 'Ctrl+w' -Function BackwardDeleteWord
                    Set-PSReadLineKeyHandler -Key 'Ctrl+e' -Function NextWord
                    Set-PSReadLineKeyHandler -Key 'Ctrl+b' -Function BackwardWord

                    Set-Alias dr dir
                    Set-Alias di dir
                    Set-Alias ir dir
                    Set-Alias dri dir
                    Set-Alias csl Clear-Host
                    Set-Alias cl Clear-Host
                    Set-Alias lsc Clear-Host
                    Set-Alias lcs Clear-Host
                    Set-Alias slc Clear-Host
                    Set-Alias tt tree
                    Set-Alias ll ls
                    Set-Alias g git
                    Set-Alias vim nvim
                    Set-Alias gosel nvim
                    Set-Alias time 'G:\Python Apps\time.ps1'
                    Set-Alias pot PotPlayerMini64
                    Set-Alias python C:/Users/fafag/AppData/Local/Programs/Python/Python310/python.exe

                    function whereis { 
                        param ([string]$command)
                        try {
                            $path = Get-Command -Name $command -ErrorAction Stop | Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
                            if ($null -eq $path) {
                                throw ""Command '$command' tidak ditemukan.""
                            } else {
                                return $path
                            }
                        } catch {
                            return ""Error: blog, '$command' ora ono nyuk.""
                        }
                    }

                    function goto { 
                        param ([string]$location)
                        $u = 'H:\UII'
                        $p = 'C:\Users\fafag\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1'
                        $d = '$HOME\Downloads'
                        $dv = 'E:\Developer'
                        switch($location) {
                            'uii' { Set-Location $u }
                            'pws' { nvim $p }
                            'downloads' { Set-Location $d }
                            'dev' { Set-Location $dv }
                            default { Write-Host 'Lokasi raono nyuk.' }
                        }
                    }

                    function open { 
                        param ([string]$arg)
                        switch($arg) {
                            'file' { Start $(fzf) }
                            'folder' { Get-ChildItem . -Recurse -Attributes Directory | Invoke-Fzf | Set-Location }
                        }
                    }

                    function :q { Exit }

                    function p { param ([string]$url) ping $url }

                    oh-my-posh init pwsh --config 'C:\Users\fafag\.config\oh-my-posh\themes\atomicBit.omp.json' | Invoke-Expression
                ");

                var results = powerShell.Invoke();
                foreach (var result in results)
                {
                    Console.WriteLine(result);
                }
            }
        }
    }
}

