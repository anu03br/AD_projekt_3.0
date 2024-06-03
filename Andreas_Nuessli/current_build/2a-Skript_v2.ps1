#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Autor: Amar Vejapi
# Datum: 03.06.2024
# Version: 1.0
# Bemerkungen: 
# Skript-Nr: 2a
# Funktion des Skripts: Sicherheitstechnisch wichtige Informationen der AD-Accounts täglich (Zeitpunkt frei wählbar) protokollieren (ein Logfile für alle AD-Accounts), wie:
#                       - Passwortalter
#                       - Datum der letzten Anmeldung
#                       - Anzahl der Logins
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

. ".\Config.ps1"

while ($true) {
    try {
        $LogfilePath = $config.LogFileUser

        # nächste verfügbare Nummer herausfinden
        $NextLogFileNumber = 1
        while (Test-Path "$LogfilePath$NextLogFileNumber.log") {
            $NextLogFileNumber++
        }
    
        # Logfile erstellen ...
        $LogfileName = "$LogfilePath$NextLogFileNumber.log"

        # ... und die Daten darin speichern
        "Datum: $(Get-Date -Format "dd.MM.yyyy_HH:mm:ss")" | Out-File -FilePath $LogfileName

        $ouDN = (Get-ADOrganizationalUnit -Filter {Name -eq "BZTF"}).DistinguishedName
        Get-ADUser -Filter * -SearchBase $ouDN -Properties PasswordLastSet, LastLogonDate, BadLogonCount |
            Select-Object SamAccountName, PasswordLastSet, LastLogonDate, BadLogonCount |
            Add-Content -Path $LogfileName
        
        Write-Host "Ein Logfile wurde erfolgreich erstellt."
    } catch {
        Write-Host "Ein Logfile wurde NICHT erstellt, aus jeglichen Gründen"
    }
    Start-Sleep -Seconds 86400  # Warte 24 Stunden = 86400 Sekunden
}