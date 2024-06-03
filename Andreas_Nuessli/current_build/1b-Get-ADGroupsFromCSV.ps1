#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: Erstellen/*Löschen der dazugehörigen AD-Gruppen pro Klasse
# Datum: 16.05.2024
# Version: 0.5
# Changelog
# 16.05.24 V0.5 Skript Erstellt
# 28.05.24 v0.6 Funktion zur erstellung von Neuen Gruppen erweitert
# 28.05.24 v0.7 unterfunktion Find-Klasse hinzugefügt
# 28.05.24 v0.8 erstellen der klasse in eigene unterfunktion New-Klasse ausgelagert
# 28.05.24 v0.9 Funktion restrukturiert mit menüführung und schlanker gemacht
#--------------------------------------------------------------------------------

# config file mit relativen pfad laden
. ".\config.ps1"

# funktion zum deaktivieren ater klassen
function Clear-Oldgroups {

    param (
        [array]$csvKlassen
    )

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
                Write-Host "Es sind noch Benutzer in der Gruppe. Nur Gruppen ohne Mitglieder werden gelöscht"
            }
            else {

                try {
                    # lösche diese Gruppe
                    Remove-ADGroup -Identity $group -Confirm:$false

                    
                    Write-Host "Die Gruppe '$group' wurde gelöscht"
                    $deletedGruopCount++
                }
                catch {
                    Write-Error "Beim Deaktivieren der Gruppe '$group' ist ein Fehler aufgetreten."
                    Write-Error $_
                }
            }  
        }
    }
    # Am schluss gib die Totale anzahl gelöschter Gruppen aus (so sehen wir auch wenn keine Gruppe gelöscht wird)
    Write-Host "Anzahl deaktivierter Gruppen: $deletedGroupCount`n"
}

function Add-KlassenFromCsv{

    #gruppennamen als parameter weitergeben
    param (
        [array]$csvKlassen
    )

    # loope durch gruppen. Jede Gruppe ist eine klasse [PKB24A]
    foreach ($group in $csvKlassen) {
  
        # Überprüfe ob Klasse leer ist
        if ([string]::IsNullOrWhiteSpace($group)) {
            Write-Host "Klasse ist leer"
            continue
        } 
        else {
            # gibt es diese Gruppe schon?
            $existingGroup = Get-ADGroup -Filter "Name -eq '$group'" -ErrorAction SilentlyContinue

            #Wenn Rückgabeparameter 1 ist
            if ($existingGroup) {
                Write-Output "Die Gruppe '$group' existiert bereits. Erstellung wird übersprungen.`n"
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
            
                    Write-Output "Die Klasse '$group' wurde erfolgreich erstellt.`n"
                }
                catch {
                    Write-Error "Beim erstellen der Gruppe '$klassenName' ist ein Fehler aufgetreten."
                    Write-Error $_
                }
            }
        }
    }
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
                Write-Host "Ungültige Wahl. Bitte wählen Sie eine gültige Option (1-3).`n"
            }
        }
    }       
}
Get-ADGroupsFromCSV