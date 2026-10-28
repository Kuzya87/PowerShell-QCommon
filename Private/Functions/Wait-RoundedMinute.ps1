<#
Цель функции - синхронизация по границе минуты.
Пауза до начала минуты, наступающей через IntervalMinutes минут (секунды отбрасываются),
чтобы запуски выравнивались по целым минутам.
#>
function Wait-RoundedMinute {
    param (
        [Parameter(Mandatory = $true)]
        [uint]$IntervalMinutes
    )

    $ErrorActionPreference = "Stop"
    [uint]$MaximumIntervalMinutes = 1440    # 1 сутки = 1440 минут

    if ($IntervalMinutes -lt 1) {
        throw [System.ArgumentOutOfRangeException]::new(
            "IntervalMinutes",
            $IntervalMinutes,
            "Количество минут для ожидания округлённого времени должно быть 1 или больше."
        )
    }

    if ($IntervalMinutes -gt $MaximumIntervalMinutes) {
        throw [System.ArgumentOutOfRangeException]::new(
            "IntervalMinutes",
            $IntervalMinutes,
            "Количество минут для ожидания округлённого времени не должно превышать 1 сутки ($MaximumIntervalMinutes минут)."
        )
    }

    $CurrentTime = [datetime]::Now
    [datetime]$TargetTime = $CurrentTime.AddMinutes($IntervalMinutes)
    $TargetTimeRounded = [datetime]::new(
        $TargetTime.Year,
        $TargetTime.Month,
        $TargetTime.Day,
        $TargetTime.Hour,
        $TargetTime.Minute,
        0
    )
    [timespan]$TimeSpanToWait = $TargetTimeRounded.Subtract($CurrentTime)
    Start-Sleep -Seconds $TimeSpanToWait.TotalSeconds
}
