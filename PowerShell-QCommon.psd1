@{
    RootModule        = 'Root.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '7d36588c-1b08-4aeb-b4a2-b3eb96667957'
    Author            = 'Юрий Кузьмин'
    Copyright         = '(c) Юрий Кузьмин. Все права защищены.'
    Description       = 'Базовые и вспомогательные функции и классы для других модулей PowerShell.'
    PowerShellVersion = '7.6'

    FunctionsToExport = @()
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData       = @{
        PSData = @{
            Tags = @(
                'PowerShell',
                'Utilities',
                'Common'
            )
        }
    }
}
