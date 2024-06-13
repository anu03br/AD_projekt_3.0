#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Autor: Amar Vejapi
# Datum: 11.06.2024
# Version: 1.0
# Bemerkungen:
# Skript-Nr: 2a
# Funktion des Skripts: Sicherheitstechnisch wichtige Informationen der AD-Accounts täglich (Zeitpunkt frei wählbar) protokollieren (ein Logfile für alle AD-Accounts), wie:
#                       - Passwortalter
#                       - Datum der letzten Anmeldung
#                       - Anzahl der Logins
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Lade die Konfigurationsdatei
. ".\config.ps1"

function protokoll_user {
    try {
        # Get the log file path from the configuration
        $LogfilePath = $config.LogFileUser

        # Format the current date and time as yyyy:MM:dd HH:mm:ss
        $timestamp = Get-Date -Format "yyyy:MM:dd HH:mm:ss"

        # Create the log file name in the desired format "users@[timestamp].log"
        $LogfileName = "users@$timestamp.log" -replace ":", "-" -replace " ", "_"

        # Write the current date and time to the log file
        "Datum: $(Get-Date -Format "dd.MM.yyyy HH:mm:ss")" | Out-File -FilePath "$LogfilePath$LogfileName"

        # Retrieve the distinguished name (DN) for the specified OU
        $ouDN = (Get-ADOrganizationalUnit -Filter {Name -eq "BZTF"}).DistinguishedName

        # Get user information from the specified OU and append it to the log file
        Get-ADUser -Filter * -SearchBase $ouDN -Properties PasswordLastSet, LastLogonDate, BadLogonCount |
            Select-Object SamAccountName, PasswordLastSet, LastLogonDate, BadLogonCount |
            Add-Content -Path "$LogfilePath$LogfileName"

        # Inform the user of the successful log file creation
        Write-Host "Ein Logfile wurde erfolgreich erstellt." -ForegroundColor Green
    } catch {
        # Inform the user of the failure to create the log file
        Write-Host "Ein Logfile wurde NICHT erstellt, aus jeglichen Gründen." -ForegroundColor Red
    }
}

function Zeitpunkt_Aenderung {
    Unregister-ScheduledTask -TaskName "MeineTäglicheAufgabe"
    # Hier kannst du den Zeitpunkt für das Logfile ändern
    # Implementiere deine Logik, um die gewünschte Zeit zu setzen
    $gewuenschteZeit = Read-Host "Gib die gewünschte Uhrzeit im Format HH:mm:ss ein"

    # Erstelle eine Aktion, die deine Funktion "protokoll_user" ausführt
    $Action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument "C:\tmp\shipping_build\2a_Protokoll-User.ps1 -protokoll_user"

    # Erstelle einen Trigger, der die Aufgabe täglich zur ausgewählten Zeit ausführt
    $Trigger = New-ScheduledTaskTrigger -Daily -At $gewuenschteZeit

    # Setze die geplante Aufgabe mit dem gewünschten Namen
    Register-ScheduledTask -TaskName "MeineTäglicheAufgabe" -Action $Action -Trigger $Trigger
}

# Hauptfunktion mit Menü
function Logfile-Erstellung {

    $Continue = $true

    while ($Continue) {

        Write-Host "-----------------------------------------------------"
        Write-Host "Willkommen im Untermenü 2a"
        Write-Host "Hier können Logfiles erstellt werden`n"
        Write-Host "1. Logfile erstellen"
        Write-Host "2. Zeitpunkt für Logfile ändern"
        Write-Host "3. Zurück ins Hauptmenü`n"

        # Benutzer wählt eine Option
        $Wahl = Read-Host "Bitte wählen Sie eine Option (1-3)`n"

        switch ($Wahl) {
            # Nutzer importieren
            1 {
                protokoll_user
            }
            # Zeitpunkt für Logfile ändern
            2 {
                Zeitpunkt_Aenderung
            }
            # Zurück ins Hauptmenü gehen
            3 {
                Write-Host "Zurück ins Hauptmenü"
                $Continue = $false
            }
            Default {
                Write-Host "Ungültige Wahl. Bitte wählen Sie eine gültige Option (1-3).`n" -ForegroundColor Red
            }
        }
    }
}

Logfile-Erstellung