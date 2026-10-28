<#
Формирует полное доменное имя (FQDN) из короткого имени хоста и доменного суффикса.
Ведущая точка у суффикса необязательна. Существование имени и его разрешение
через DNS не проверяются.
#>
function Join-DomainSuffix {
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$HostName,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$DomainSuffix
    )

    $ErrorActionPreference = "Stop"

    if (-not [QCommonHostName]::CheckShortHostNameIsCorrect($HostName)) {
        throw [System.ArgumentException]::new(
            "Некорректное короткое имя хоста '$HostName'. Используйте от 1 до 15 латинских букв, цифр или дефисов; имя должно начинаться и заканчиваться буквой или цифрой и не может состоять только из цифр.",
            "HostName"
        )
    }

    if ([string]::IsNullOrWhiteSpace($DomainSuffix)) {
        throw [System.ArgumentException]::new(
            "Доменный суффикс не может быть пустым.",
            "DomainSuffix"
        )
    }

    if ($DomainSuffix.StartsWith(".", [System.StringComparison]::Ordinal)) {
        [string]$DomainSuffix = $DomainSuffix.Substring(1)
    }

    [string]$FQDN = "$HostName.$DomainSuffix"
    if (-not [QCommonHostName]::CheckFQDNIsCorrect($FQDN)) {
        throw [System.ArgumentException]::new(
            "Не удалось сформировать корректное FQDN '$FQDN'. Проверьте доменный суффикс: каждая его метка должна содержать от 1 до 63 латинских букв, цифр или дефисов, не начинаться и не заканчиваться дефисом; общая длина FQDN не должна превышать 253 символа.",
            "DomainSuffix"
        )
    }

    return $FQDN
}
