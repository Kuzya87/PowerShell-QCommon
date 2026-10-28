class QCommonHostName {
    static [bool] CheckShortHostNameIsCorrect([string]$HostName) {
        [bool]$result = Test-ShortHostName -HostName $HostName
        return $result
    }

    static [bool] CheckFQDNIsCorrect([string]$FQDN) {
        [bool]$result = Test-FQDN -FQDN $FQDN
        return $result
    }

    static [bool] CheckIPv4Address([string]$IPv4Address) {
        [bool]$result = Test-IPv4Address -IPv4Address $IPv4Address
        return $result
    }

    static [bool] CheckIPv4Address([string]$IPv4Address, [bool]$OnlyLocal) {
        [bool]$result = Test-IPv4Address -IPv4Address $IPv4Address -OnlyLocal:$OnlyLocal
        return $result
    }

    static [bool] CheckIPv6Address([string]$IPv6Address) {
        [bool]$result = Test-IPv6Address -IPv6Address $IPv6Address
        return $result
    }

    static [bool] CheckIPv6Address([string]$IPv6Address, [bool]$OnlyLocal) {
        [bool]$result = Test-IPv6Address -IPv6Address $IPv6Address -OnlyLocal:$OnlyLocal
        return $result
    }

    static [string] JoinDomainSuffix([string]$HostName, [string]$DomainSuffix) {
        [string]$result = Join-DomainSuffix -HostName $HostName -DomainSuffix $DomainSuffix
        return $result
    }

    static [string[]] OptimizeHostNamesList([string[]]$HostName) {
        [string[]]$result = Optimize-HostNamesList -HostName $HostName
        return $result
    }

    static [string[]] OptimizeHostNamesList([string[]]$HostName, [string]$DomainSuffix) {
        [string[]]$result = Optimize-HostNamesList -HostName $HostName -DomainSuffix $DomainSuffix
        return $result
    }

    static [string[]] OptimizeIPAddressesList([string[]]$IPAddress) {
        [string[]]$result = Optimize-IPAddressesList -IPAddress $IPAddress
        return $result
    }
}
