<#
Проверяет короткое имя хоста: от 1 до 15 ASCII-символов, только латинские буквы,
цифры и дефис; имя должно начинаться и заканчиваться буквой или цифрой и не
может состоять только из цифр. Точки, пробелы и другие символы не допускаются.
#>
function Test-ShortHostName {
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$HostName
    )

    $ErrorActionPreference = "Stop"

    if ($HostName -notmatch '\A(?=.{1,15}\z)(?![0-9]+\z)[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\z') {
        return $false
    }

    return $true
}
