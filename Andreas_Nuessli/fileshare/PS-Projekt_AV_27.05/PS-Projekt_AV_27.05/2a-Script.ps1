#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Autor: Amar Vejapi
# Datum: 21.05.2024
# Version: 1.0
# Bemerkungen: 
# Skript-Nr: 2a
# Funktion des Skripts: Sicherheitstechnisch wichtige Informationen der AD-Accounts täglich (Zeitpunkt frei wählbar) protokollieren (ein Logfile für alle AD-Accounts), wie:
#                       - Passwortalter
#                       - Datum der letzten Anmeldung
#                       - Anzahl der Logins
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Funktion-2a {
    try {
        $LogfilePath = "C:\tmp\users.log"

        # nächste verfügbare Nummer herausfinden
        $NextLogFileNumber = 1
        while (Test-Path "$LogfilePath$NextLogFileNumber.log") {
            $NextLogFileNumber++
        }
    
        #Logfile erstellen ...
        $LogfileName = "$LogfilePath$NextLogFileNumber.log"

        #... und die Daten darin speichern
        $ouDN = (Get-ADOrganizationalUnit -Filter {Name -eq "BZTF"}).DistinguishedName
        Get-ADUser -Filter * -SearchBase $ouDN -Properties PasswordLastSet, LastLogonDate, BadLogonCount |
            Select-Object SamAccountName, PasswordLastSet, LastLogonDate, BadLogonCount |
            Export-Csv -Path $LogfileName -NoTypeInformation
        Write-Host "Ein Logfile wurde erfolgreich erstellt."
    } catch {
        Write-Host "Ein Logfile wurde NICHT erstellt, aus jeglichen Gründen"
    }
}

Funktion-2a