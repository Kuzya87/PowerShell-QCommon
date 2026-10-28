function Test-IPv4Address {
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$IPv4Address,

        [Parameter(Mandatory = $false)]
        [switch]$OnlyLocal
    )

    $ErrorActionPreference = "Stop"

    if ([string]::IsNullOrEmpty($IPv4Address) -or $IPv4Address -ne $IPv4Address.Trim()) {
        return $false
    }

    [string[]]$Octets = $IPv4Address.Split('.')
    if ($Octets.Count -ne 4) {
        return $false
    }

    [byte[]]$AddressBytes = [byte[]]::new(4)
    for ([int]$Index = 0; $Index -lt $Octets.Count; $Index++) {
        if ($Octets[$Index] -notmatch '\A[0-9]{1,3}\z') {
            return $false
        }

        [int]$Octet = 0
        if (
            -not [int]::TryParse(
                $Octets[$Index],
                [System.Globalization.NumberStyles]::None,
                [System.Globalization.CultureInfo]::InvariantCulture,
                [ref]$Octet
            ) -or
            $Octet -gt 255
        ) {
            return $false
        }

        $AddressBytes[$Index] = [byte]$Octet
    }

    # These ranges are not assignable as ordinary unicast host addresses.
    if (
        $AddressBytes[0] -eq 0 -or
        ($AddressBytes[0] -ge 224 -and $AddressBytes[0] -le 255)
    ) {
        return $false
    }

    if (-not $OnlyLocal) {
        return $true
    }

    return (
        $AddressBytes[0] -eq 10 -or
        ($AddressBytes[0] -eq 192 -and $AddressBytes[1] -eq 168) -or
        ($AddressBytes[0] -eq 172 -and $AddressBytes[1] -ge 16 -and $AddressBytes[1] -le 31) -or
        $AddressBytes[0] -eq 127 -or
        ($AddressBytes[0] -eq 169 -and $AddressBytes[1] -eq 254)
    )
}
