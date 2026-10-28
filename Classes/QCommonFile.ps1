class QCommonFile {
    static [void] AddLogContentJSONL([string]$Message, [string]$LogFile) {
        Add-LogContentJSONL -Message $Message -LogFile $LogFile
    }

    static [void] AddLogContentJSONL([string]$Message, [string]$LogFile, [System.Object]$Object) {
        Add-LogContentJSONL -Message $Message -LogFile $LogFile -Object $Object
    }
}
