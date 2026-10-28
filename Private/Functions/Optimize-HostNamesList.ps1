<#
Формирует список корректных имён хостов из входной коллекции: обрезает пробелы,
удаляет завершающую точку у FQDN и пропускает пустые и некорректные значения.
Доменный суффикс добавляется только к коротким именам; дубликаты удаляются без
учёта регистра. В коротких именах используется верхний регистр, а в суффиксах
FQDN — нижний. Всегда возвращает [string[]].
#>
function Optimize-HostNamesList {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$HostName,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$DomainSuffix
    )

    $ErrorActionPreference = "Stop"

    $Result = [System.Collections.Generic.List[string]]::new()
    $UniqueHostNames = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::OrdinalIgnoreCase
    )
    [bool]$HasDomainSuffix = $PSBoundParameters.ContainsKey("DomainSuffix")
    [int]$InputCount = $HostName.Count
    [int]$DuplicateCount = 0
    [int]$DomainSuffixCount = 0

    foreach ($Item in $HostName) {
        # Проверка на пустую строку или null
        if ([string]::IsNullOrEmpty($Item)) {
            continue
        }

        # Обрезаются пробелы в начале и конце строки
        [string]$Name = $Item.Trim()

        # Проверка на FQDN или короткое имя хоста
        if ([QCommonHostName]::CheckFQDNIsCorrect($Name)) {
            if ($Name.EndsWith(".", [System.StringComparison]::Ordinal)) {
                $Name = $Name.Substring(0, ($Name.Length - 1))
            }
        }
        elseif ([QCommonHostName]::CheckShortHostNameIsCorrect($Name)) {
            if ($HasDomainSuffix) {
                try {
                    $Name = [QCommonHostName]::JoinDomainSuffix($Name, $DomainSuffix)
                    $DomainSuffixCount++
                }
                catch [System.ArgumentException] {
                    Write-Verbose -Message "Имя хоста '$Name' пропущено: $($_.Exception.Message)"
                    continue
                }
            }
        }
        else {
            continue
        }

        if ($UniqueHostNames.Add($Name)) {
            $Result.Add($Name)
        }
        else {
            $DuplicateCount++
        }
    }

    [string[]]$FinalResult = $Result.ToArray()

    for ([int]$Index = 0; $Index -lt $FinalResult.Count; $Index++) {
        [int]$FirstDotIndex = $FinalResult[$Index].IndexOf(".")
        if ($FirstDotIndex -ge 0) {
            $FinalResult[$Index] = $FinalResult[$Index].Substring(0, $FirstDotIndex).ToUpperInvariant() +
            $FinalResult[$Index].Substring($FirstDotIndex).ToLowerInvariant()
        }
        else {
            $FinalResult[$Index] = $FinalResult[$Index].ToUpperInvariant()
        }
    }

    Write-Verbose -Message "В итоговый список включено $($FinalResult.Count) из $InputCount исходных строк."
    Write-Verbose -Message "Пропущено дубликатов: $DuplicateCount."
    if ($HasDomainSuffix) {
        Write-Verbose -Message "Доменный суффикс успешно добавлен к $DomainSuffixCount строкам."
    }

    return , $FinalResult    # Возвращаем массив, даже если он пустой
}
