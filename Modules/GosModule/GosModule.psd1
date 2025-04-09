@{
    RootModule = 'GosModule.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'a1b2c3d4-e5f6-4a5b-9c8d-7e6f5d4c3b2a'
    Author = 'Your Name'
    CompanyName = 'Your Company'
    Copyright = '(c) 2024. All rights reserved.'
    Description = 'PowerShell module for AI-powered assistance'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('gosTanya', 'Invoke-AIRequest', 'Format-Response')
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('AI', 'Assistant', 'OpenAI', 'Groq')
            LicenseUri = 'https://opensource.org/licenses/MIT'
            ProjectUri = 'https://github.com/yourusername/GosModule'
            ReleaseNotes = 'Initial release'
        }
    }
} 