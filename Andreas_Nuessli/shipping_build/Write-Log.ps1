#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: eine Nachricht mit Zeitstempel versehen und in das angegebene Logfile schreiben
# Datum: 10.06.2024
# Version: 1.0
# Changelog
# 10.06.2024 v1.0 Write-Log funktion geschrieben und ausgelagert. Write-Log funktioniert in 1a.
#--------------------------------------------------------------------------------

# Funktion, welche eine Message ins Logfile schreibt

# config file mit relativen pfad laden
. ".\config.ps1"
function Write-Log {
    param (
        [string]$message,
        [string]$logFilePath
    )

    # Die aktuelle Zeit vor die Message einfügen
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp`n$message"

    # Schreibe die message in das logfine under $logFilePath
    Add-Content -Path $logFilePath -Value "$logEntry"
}
Write-Log -logFilePath $config.LogFileActivities