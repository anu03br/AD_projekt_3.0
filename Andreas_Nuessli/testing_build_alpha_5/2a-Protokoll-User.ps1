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

# funktion Write-Log importieren
. "$PSScriptRoot\Write-Log.ps1"  
# Lade die Konfigurationsdatei
. ".\config.ps1"
# function import
. "$PSScriptRoot\protocol_user.ps1"

function Zeitpunkt_Aenderung {

    # this block will throw an error is no task was previously scheduled but it doesn't matter
    try {
       # der Aktuelle Task wird gelöscht
        Unregister-ScheduledTask -TaskName "MeineTäglicheAufgabe" -ErrorAction Continue
    }
    catch {
        $errorMessage = "Bein unscheduling passierte ein Fehler.`n$_"
        Write-Log -message $errorMessage -logFilePath $config.LogFileActivities
        Write-Host $errorMessage -ForegroundColor Red # delete this line before shipping
    }
    
    # Abfrage der gewünschten Uhrzeit
    $gewuenschteZeit = Read-Host "Gib die gewünschte Uhrzeit ein (z.B. 12:45)"

    # $gewuenschteZeit in ein DateTime Objekt umwandeln
    $scheduleTime = [datetime]::ParseExact($gewuenschteZeit, "HH:mm", $null)

    try {
        # Erstelle eine Aktion, die deine Funktion "protokoll_user" ausführt
        $Action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument "-Command `"cd 'C:\temp\AD_Projekt_ave_anu'; .\protocol_user.ps1`"" # this is a workarount let's hope it works

        # Erstelle einen Trigger, der die Aufgabe täglich zur ausgewählten Zeit ausführt
        $Trigger = New-ScheduledTaskTrigger -Daily -At $scheduleTime

        # Setze die geplante Aufgabe mit dem gewünschten Namen
        Register-ScheduledTask -TaskName "MeineTäglicheAufgabe" -Action $Action -Trigger $Trigger # Out-File -FilePath $config.LogFileActivities -Append

        $message = "Der Neue Task wurde erfolgreich um $gewuenschteZeit geplant."
        Write-Log -message $message -logFilePath $config.LogFileActivities
        Write-Host $message -ForegroundColor Green
    }
    catch {
        $errorMessage = "Bein erstellen des neuen Tasks passierte ein Fehler.`n$_"
        Write-Log -message $errorMessage -logFilePath $config.LogFileActivities
        Write-Host $errorMessage -ForegroundColor Red # delete this line before shipping
    }
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