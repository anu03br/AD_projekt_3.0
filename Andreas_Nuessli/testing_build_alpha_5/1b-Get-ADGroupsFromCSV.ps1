#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: Erstellen/*Löschen der dazugehörigen AD-Gruppen pro Klasse
# Datum: 10.06.24
# Version: 1.0
# Changelog
# 16.05.24 V0.5 Skript Erstellt
# 28.05.24 v0.6 Funktion zur erstellung von Neuen Gruppen erweitert
# 28.05.24 v0.7 unterfunktion Find-Klasse hinzugefügt
# 28.05.24 v0.8 erstellen der klasse in eigene unterfunktion New-Klasse ausgelagert
# 28.05.24 v0.9 Funktion restrukturiert mit menüführung und schlanker gemacht
# 10.06.24 v1.0 write-Log funktion integriert
#--------------------------------------------------------------------------------

# funktion Write-Log importieren
. "$PSScriptRoot\Write-Log.ps1" 
# config file mit relativen pfad laden
. ".\config.ps1"

# funktion zum deaktivieren ater klassen
function Clear-Oldgroups {

    param (
        [array]$csvKlassen
    )
    Write-Host " Funktion wird ausgeführt. bitte warten Sie..."
    # Alle Gruppennamen (Klasse und Klasse2) aus dem CSV lesen und in ein Array packen [PKB24A, BM1_TE24A, DRO25A,  PKB25A, BM1_TE25A]
    $csvKlassenNamen = $csvData | ForEach-Object { $_.Klasse, $_.Klasse2 }  -ErrorAction Stop

    # Gibt eine liste mit den SamAccountNames aller Gruppen in "Klassengruppen" aus
    $adGroups = Get-ADGroup -Filter * -SearchBase "OU=$($config.OUKlasse),$($config.OUPath)" | Select-Object -ExpandProperty SamAccountName

    # Zähler für gelöschte Gruppen initialisieren
    $deletedGroupCount = 0

    # Loope durch alle Gruppen und überprüfe , ob sie noch im Csv sind
    foreach ($group in $adGroups) {
        # wenn sie nicht mehr im CSV sind
        if ($group -notin $csvKlassenNamen) {

            # Frage ab, wie viele benutzer in der gruppe sind
            $benutzerZahl =  Get-ADGroupMember -Identity $group | Measure-Object | Select-Object -ExpandProperty Count

            if ($benutzerZahl -gt 0) {
                $message =  "Es sind noch Benutzer in der Gruppe. Nur Gruppen ohne Mitglieder werden gelöscht"
                Write-Log -message $message -logFilePath $config.LogFileActivities
            }
            else {

                try {
                    # lösche diese Gruppe
                    Remove-ADGroup -Identity $group -Confirm:$false

                    
                    $message =  "Die Gruppe '$group' wurde gelöscht"
                    Write-Log -message $message -logFilePath $config.LogFileActivities
                    $deletedGruopCount++
                }
                catch {
                    $errorMessage =  "Beim Deaktivieren der Gruppe '$group' ist ein Fehler aufgetreten.`n$_"
                    Write-Log -message $errorMessage -logFilePath $config.LogFileActivities
                }
            }  
        }
    }
    # Am schluss gib die Totale anzahl gelöschter Gruppen aus (so sehen wir auch wenn keine Gruppe gelöscht wird)
    $message = "Anzahl deaktivierter Gruppen: $deletedGroupCount`n"
    Write-Log -message $message -logFilePath $config.LogFileActivities
    Write-Host $message -ForegroundColor Blue
}

function Add-KlassenFromCsv{

    #gruppennamen als parameter weitergeben
    param (
        [array]$csvKlassen
    )
    $successfulGroup = 0
    $errorCounter = 0
    $skippedGroup = 0
    Write-Host " Funktion wird ausgeführt. bitte warten Sie..."

    # loope durch gruppen. Jede Gruppe ist eine klasse [PKB24A]
    foreach ($group in $csvKlassen) {
  
        # Überprüfe ob Klasse leer ist
        if ([string]::IsNullOrWhiteSpace($group)) {
            $message = "Klasse ist leer"
            Write-Log -message $message -logFilePath $config.LogFileActivities
            continue
        } 
        else {
            # gibt es diese Gruppe schon?
            $existingGroup = Get-ADGroup -Filter "Name -eq '$group'" -ErrorAction SilentlyContinue

            #Wenn Rückgabeparameter 1 ist
            if ($existingGroup) {
                $message = "Die Gruppe '$group' existiert bereits. Erstellung wird übersprungen.`n"
                Write-Log -message $message -logFilePath $config.LogFileActivities
                $skippedGroup++
                continue 
            }
            # wenn rückgabeparameter 0 ist 
            else {
                # Neue Gruppe Erstellen
                try {     
                    New-ADGroup -Name "$group" `
                                -SamAccountName "$group" `
                                -GroupScope Global `
                                -GroupCategory Security `
                                -Path "OU=$($config.OUKlasse),$($config.OUPath)" `
                                -Description "Schüler der Klasse $$group"
            
                    $message = "Die Klasse '$group' wurde erfolgreich erstellt.`n"
                    Write-Log -message $message -logFilePath $config.LogFileActivities
                    $successfulGroup++
                }
                catch {
                    errorMessage = "Beim erstellen der Gruppe '$klassenName' ist ein Fehler aufgetreten.`n$_"
                    Write-Log -message $errorMessage -logFilePath $config.LogFileActivities
                    $errorCounter++
                }
            }
        }
    }
    $message = "$($successfulGroup) Gruppen wurden erstellt, $($skippedGroup) erstellungen übersprungen, $($errorCounter) Fehler."
    Write-Log -message $message -logFilePath $config.LogFileActivities
    Write-Host $message -ForegroundColor Blue
}

function Get-ADGroupsFromCSV {

    # CSV-Datei importieren
    $csvData = Import-Csv -Path $Config.SchuelerCsv -Delimiter ';'

    # Alle Gruppennamen (Klasse und Klasse2) aus dem CSV lesen und in ein Array packen [PKB24A, BM1_TE24A, DRO25A,  PKB25A, BM1_TE25A]
    $csvKlassenNamen = $csvData | ForEach-Object { $_.Klasse, $_.Klasse2 }  -ErrorAction Stop

    $Continue = $true

    while ($Continue) {

        Write-Host "-----------------------------------------------------"
        Write-Host "Willkommen im Untermenü 1b"
        Write-Host "Hier können Sie AD Gruppen verwalten`n"
        Write-Host "1. Gruppen Erstellen"
        Write-Host "2. Gruppen Löschen"
        Write-Host "3. Zurück ins Hauptmenü`n"

        # User wählt 
        $Wahl = Read-Host "Bitte wählen Sie eine Option (1-3)`n"

        switch ($Wahl) {
            # Neue Gruppen erstellen
            1 {
                Add-KlassenFromCsv -csvKlassen $csvKlassenNamen
            }
            # Alte Gruppen löschen
            2 {
                Clear-Oldgroups -csvKlassen $csvKlassenNamen
            }
            #zurück ins Hauptmenü gehen
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
Get-ADGroupsFromCSV