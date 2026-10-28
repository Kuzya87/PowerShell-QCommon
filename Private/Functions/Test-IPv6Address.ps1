function Test-IPv6Address {
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$IPv6Address,

        [Parameter(Mandatory = $false)]
        [switch]$OnlyLocal
    )

    $ErrorActionPreference = "Stop"

    if (
        [string]::IsNullOrEmpty($IPv6Address) -or
        $IPv6Address -ne $IPv6Address.Trim() -or
        $IPv6Address.Contains('.') -or
        $IPv6Address.Contains('%') -or
        $IPv6Address.Contains('[') -or
        $IPv6Address.Contains(']')
    ) {
        return $false
    }

    [System.Net.IPAddress]$Address = $null
    if (
        -not [System.Net.IPAddress]::TryParse($IPv6Address, [ref]$Address) -or
        $Address.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetworkV6
    ) {
        return $false
    }

    [byte[]]$AddressBytes = $Address.GetAddressBytes()
    [bool]$IsLoopback = $Address.Equals([System.Net.IPAddress]::IPv6Loopback)
    [bool]$IsUnspecified = $Address.Equals([System.Net.IPAddress]::IPv6Any)
    [bool]$IsIPv4Mapped = $Address.IsIPv4MappedToIPv6
    [bool]$IsZeroPrefix = $true
    [bool]$IsFirstEightZero = $true
    for ([int]$Index = 0; $Index -lt 12; $Index++) {
        if ($AddressBytes[$Index] -ne 0) {
            $IsZeroPrefix = $false
            if ($Index -lt 8) {
                $IsFirstEightZero = $false
            }
        }
    }
    [bool]$IsIPv4Compatible = (
        $IsZeroPrefix -and
        -not $IsUnspecified -and
        -not $IsLoopback
    )
    [bool]$IsIPv4Translatable = (
        $IsFirstEightZero -and
        $AddressBytes[8] -eq 255 -and
        $AddressBytes[9] -eq 255 -and
        $AddressBytes[10] -eq 0 -and
        $AddressBytes[11] -eq 0
    )
    [bool]$IsDiscardOnly = (
        $AddressBytes[0] -eq 0x01 -and
        $AddressBytes[1] -eq 0x00 -and
        $AddressBytes[2] -eq 0 -and
        $AddressBytes[3] -eq 0 -and
        $AddressBytes[4] -eq 0 -and
        $AddressBytes[5] -eq 0 -and
        $AddressBytes[6] -eq 0 -and
        $AddressBytes[7] -eq 0
    )
    [bool]$IsSiteLocal = (
        $AddressBytes[0] -eq 0xfe -and
        ($AddressBytes[1] -band 0xc0) -eq 0xc0
    )
    [bool]$IsDocumentation = (
        (
            $AddressBytes[0] -eq 0x20 -and
            $AddressBytes[1] -eq 0x01 -and
            $AddressBytes[2] -eq 0x0d -and
            $AddressBytes[3] -eq 0xb8
        ) -or (
            $AddressBytes[0] -eq 0x3f -and
            $AddressBytes[1] -eq 0xff -and
            ($AddressBytes[2] -band 0xf0) -eq 0
        )
    )
    [bool]$IsOrchid = (
        $AddressBytes[0] -eq 0x20 -and
        $AddressBytes[1] -eq 0x01 -and
        $AddressBytes[2] -eq 0 -and
        (($AddressBytes[3] -band 0xf0) -eq 0x10 -or ($AddressBytes[3] -band 0xf0) -eq 0x20)
    )
    [bool]$IsNat64WellKnownPrefix = (
        $AddressBytes[0] -eq 0x00 -and
        $AddressBytes[1] -eq 0x64 -and
        $AddressBytes[2] -eq 0xff -and
        $AddressBytes[3] -eq 0x9b -and
        $AddressBytes[4] -eq 0 -and
        $AddressBytes[5] -eq 0 -and
        $AddressBytes[6] -eq 0 -and
        $AddressBytes[7] -eq 0 -and
        $AddressBytes[8] -eq 0 -and
        $AddressBytes[9] -eq 0 -and
        $AddressBytes[10] -eq 0 -and
        $AddressBytes[11] -eq 0
    )
    [bool]$IsNat64LocalUsePrefix = (
        $AddressBytes[0] -eq 0x00 -and
        $AddressBytes[1] -eq 0x64 -and
        $AddressBytes[2] -eq 0xff -and
        $AddressBytes[3] -eq 0x9b -and
        $AddressBytes[4] -eq 0 -and
        $AddressBytes[5] -eq 1
    )
    [bool]$IsDummyPrefix = (
        $AddressBytes[0] -eq 0x01 -and
        $AddressBytes[1] -eq 0 -and
        $AddressBytes[2] -eq 0 -and
        $AddressBytes[3] -eq 0 -and
        $AddressBytes[4] -eq 0 -and
        $AddressBytes[5] -eq 0 -and
        $AddressBytes[6] -eq 0 -and
        $AddressBytes[7] -eq 1
    )
    [bool]$IsSrv6Sid = $AddressBytes[0] -eq 0x5f -and $AddressBytes[1] -eq 0

    # Special-purpose ranges that are not assignable as ordinary host unicast addresses.
    if (
        $IsUnspecified -or
        $Address.IsIPv6Multicast -or
        $IsIPv4Mapped -or
        $IsIPv4Compatible -or
        $IsIPv4Translatable -or
        $IsDiscardOnly -or
        $IsSiteLocal -or
        $IsDocumentation -or
        $IsOrchid -or
        $IsNat64WellKnownPrefix -or
        $IsNat64LocalUsePrefix -or
        $IsDummyPrefix -or
        $IsSrv6Sid
    ) {
        return $false
    }

    if (-not $OnlyLocal) {
        return $true
    }

    return (
        ($AddressBytes[0] -eq 0xfc -or $AddressBytes[0] -eq 0xfd) -or
        ($AddressBytes[0] -eq 0xfe -and ($AddressBytes[1] -band 0xc0) -eq 0x80) -or
        $IsLoopback
    )
}
