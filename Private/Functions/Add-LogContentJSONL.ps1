function Add-LogContentJSONL {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Message,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$LogFile,

        [Parameter(Mandatory = $false)]
        [System.Object]$Object
    )

    $ErrorActionPreference = "Stop"

    if ($Message.Length -lt 1 -or $Message.Length -gt 1000 -or [string]::IsNullOrWhiteSpace($Message)) {
        throw [System.ArgumentOutOfRangeException]::new(
            "Message",
            $Message.Length,
            "Сообщение для записи в лог должно содержать от 1 до 1000 символов и не состоять только из пробельных символов."
        )
    }

    if ([string]::IsNullOrWhiteSpace($LogFile)) {
        throw [System.ArgumentException]::new(
            "Путь к файлу лога не должен быть пустым.",
            "LogFile"
        )
    }

    [System.Collections.IDictionary]$LogEntry = [ordered]@{
        timestamp = Get-Date -AsUTC -Format FileDateTimeUniversal
        user      = "$env:COMPUTERNAME\$env:USERNAME"
        message   = $Message
        object    = $Object
    }

    try {
        [string]$JsonLine = ConvertTo-Json -InputObject $LogEntry -Depth 2 -Compress -ErrorAction Stop
    }
    catch {
        throw [System.InvalidOperationException]::new(
            "Не удалось преобразовать запись в JSON: $($_.Exception.Message)",
            $_.Exception
        )
    }

    try {
        [System.IO.File]::AppendAllText(
            $LogFile,
            $JsonLine + [System.Environment]::NewLine,
            [System.Text.UTF8Encoding]::new($false)
        )
    }
    catch {
        throw [System.IO.IOException]::new(
            "Не удалось добавить запись в файл лога '$LogFile': $($_.Exception.Message)",
            $_.Exception
        )
    }
}
