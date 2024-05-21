#2a
#Sicherheitstechnisch wichtige Informationen der AD-Accounts täglich (Zeitpunkt frei wählbar) protokollieren (ein Logfile für alle AD-Accounts), wie:
#  - Passwortalter
#  - Datum der letzten Anmeldung
#  - Anzahl der Logins

function Funktion-2a {
    # Pfad
    $LogfilePath = "C:\tmp\users.log\Logfile"

    # nächste verfügbare Nummer herausfinden
    $NextLogFileNumber = 1
    while (Test-Path "$LogfilePath$NextLogFileNumber.csv") {
        $NextLogFileNumber++
    }

    #Logfile erstellen und ...
    $LogfileName = "$LogfilePath$NextLogFileNumber.csv"

    #... die Daten darin speichern
    Get-ADUser -Filter * -Properties PasswordLastSet, LastLogonDate, BadLogonCount |
        Select-Object SamAccountName, PasswordLastSet, LastLogonDate, BadLogonCount |
        Export-Csv -Path $LogfileName -NoTypeInformation

}

Funktion-2a