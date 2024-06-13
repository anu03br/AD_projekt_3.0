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
# this is all kinds of fucked
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
        # should be users@ datetime yyyy:mm:dd: hh:mm:ss
        $LogfileName = "$LogfilePath$NextLogFileNumber.log"

        # ... und die Daten darin speichern
        "Datum: $(Get-Date -Format "dd.MM.yyyy_HH:mm:ss")" | Out-File -FilePath $LogfileName
        # name -eq "bztf" sould rather point to config.ou
        $ouDN = (Get-ADOrganizationalUnit -Filter {Name -eq "BZTF"}).DistinguishedName
        Get-ADUser -Filter * -SearchBase $ouDN -Properties PasswordLastSet, LastLogonDate, BadLogonCount |
            Select-Object SamAccountName, PasswordLastSet, LastLogonDate, BadLogonCount |
            Add-Content -Path $LogfileName
        
        Write-Host "Ein Logfile wurde erfolgreich erstellt."
    } catch {
        # here is should give more info
        Write-Host "Ein Logfile wurde NICHT erstellt, aus jeglichen Gründen"
    }
    #this sleeps the whole console - find a better way
    #Start-Sleep -Seconds 86400  # Warte 24 Stunden = 86400 Sekunden
    Write-Host " hier passieren Sachen" -ForegroundColor Red
    return
}