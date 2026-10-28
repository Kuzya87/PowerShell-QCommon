<#
Проверяет формат полного доменного имени (FQDN): первая метка проверяется как
короткое имя хоста (1–15 ASCII-символов, не только цифры), остальные метки
содержат по 1–63 ASCII-буквы, цифры или дефисы и не начинаются и не заканчиваются
дефисом. Общая длина без завершающей точки — не более 253 символов.
Ожидается как минимум 2 части в FQDN (например, "host.domain").
Завершающая точка допускается. Unicode-имена нужно передавать в Punycode;
существование имени и его разрешение через DNS не проверяются.
#>
function Test-FQDN {
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$FQDN
    )

    $ErrorActionPreference = "Stop"

    if ([string]::IsNullOrEmpty($FQDN)) {
        return $false
    }

    [string]$FQDNWithoutRoot = $FQDN
    if ($FQDNWithoutRoot.EndsWith('.')) {
        [string]$FQDNWithoutRoot = $FQDNWithoutRoot.Substring(0, ($FQDNWithoutRoot.Length - 1))
    }

    if ($FQDNWithoutRoot.Length -gt 253) {
        return $false
    }

    [string[]]$Labels = $FQDNWithoutRoot.Split('.')
    if ($Labels.Count -lt 2) {
        return $false
    }

    if (-not [QCommonHostName]::ValidateShortHostName($Labels[0])) {
        return $false
    }

    for ([int]$Index = 1; $Index -lt $Labels.Count; $Index++) {
        if (
            $Labels[$Index].Length -gt 63 -or
            $Labels[$Index] -notmatch '\A[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\z'
        ) {
            return $false
        }
    }

    return $true
}
