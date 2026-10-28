<#
Формирует список корректных IPv4- и IPv6-адресов: удаляет пробелы по краям,
нормализует адреса и исключает дубликаты, сохраняя порядок первого появления.
#>
function Optimize-IPAddressesList {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$IPAddress
    )

    $ErrorActionPreference = "Stop"

    $Result = [System.Collections.Generic.List[string]]::new()
    $UniqueAddresses = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::Ordinal
    )
    [int]$InputCount = $IPAddress.Count
    [int]$DuplicateCount = 0

    foreach ($Item in $IPAddress) {
        if ([string]::IsNullOrEmpty($Item)) {
            continue
        }

        [string]$Address = $Item.Trim()
        if ([string]::IsNullOrEmpty($Address)) {
            continue
        }

        if ([QCommonHostName]::CheckIPv4Address($Address)) {
            [string[]]$Octets = $Address.Split('.')
            for ([int]$Index = 0; $Index -lt $Octets.Count; $Index++) {
                [int]$Octet = [int]::Parse(
                    $Octets[$Index],
                    [System.Globalization.NumberStyles]::None,
                    [System.Globalization.CultureInfo]::InvariantCulture
                )
                $Octets[$Index] = $Octet.ToString(
                    [System.Globalization.CultureInfo]::InvariantCulture
                )
            }
            $Address = $Octets -join '.'
        }
        elseif ([QCommonHostName]::CheckIPv6Address($Address)) {
            try {
                $Address = [System.Net.IPAddress]::Parse($Address).ToString().ToLowerInvariant()
            }
            catch {
                throw [System.InvalidOperationException]::new(
                    "Не удалось нормализовать проверенный IPv6-адрес '$Address'.",
                    $_.Exception
                )
            }
        }
        else {
            continue
        }

        if ($UniqueAddresses.Add($Address)) {
            $Result.Add($Address)
        }
        else {
            $DuplicateCount++
        }
    }

    [string[]]$FinalResult = $Result.ToArray()

    Write-Verbose -Message "В итоговый список включено $($FinalResult.Count) из $InputCount исходных строк."
    Write-Verbose -Message "Пропущено дубликатов: $DuplicateCount."

    return , $FinalResult
}
