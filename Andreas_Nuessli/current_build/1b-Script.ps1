#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: Bulk Funktion zum erstellen von Gruppen aus einer CSV Liste
# Datum: 16.05.2024
# Version: 0.5
# Changelog
# 16.05.24 V0.5 Skript Erstellt
# 28.05.24 v0.6 
#--------------------------------------------------------------------------------
#Erstellen/*Löschen der dazugehörigen AD-Gruppen pro Klasse
#*Deaktivieren oder Löschen ⇒ sobald ein AD-Account beim nächsten Import nicht mehr im CSV File aufgeführt wird.

# config file mit relativen pfad laden
. ".\config.ps1"

# Unterfunktion überprüfe ob es diese gruppe schon gibt
function Find-Klasse {
    param (
        [string]$klassenName
    )
    #überprüfe ob es diese gruppe schon gibt
    $existingGroup = Get-ADGroup -Filter "Name -eq '$klassenName'" -ErrorAction SilentlyContinue
    return $existingGroup
}

# Unterfunktion zum erstellen einer Klasse
function New-Klasse {

    param (
        [string]$klassenName
    )
    try {
        # erstelle eine neue ADGruppe
        New-ADGroup -Name "Klasse $klassenName" ` 
                    -SamAccountName "$klassenName" ` 
                    -GroupCategory Security ` 
                    -GroupScope DomainLocal ` 
                    -DisplayName "$klassenName" ` 
                    -Path "OU=$($config.OUKlasse),$($config.OUPath)" ` 
                    -Description "Schüler der Klasse $klassenName"
        
        Write-Output "die Klasse '$klassenName' wurde erfolgreich erstellt.`n"
    }
    catch {
        Write-Error "Beim erstellen der Gruppe '$klassenName' ist ein Fehler aufgetreten."
        Write-Error $_
    }
}

function Funktion-1b {

    # CSV-Datei importieren
    $csvData = Import-Csv -Path $Config.SchuelerCsv -Delimiter ';'

    # Alle Gruppennamen (Klasse und Klasse2) aus dem CSV lesen
    $csvGroupNames = $csvData | ForEach-Object { $_.Klasse, $_.Klasse2 }  -ErrorAction Stop

    # loope durch gruppen
    foreach ($group in $csvGroupNames) {
        ## Klasse 1

        # Überprüfe ob Klasse leer ist
        if ([string]::IsNullOrWhiteSpace($group.Klasse)) {
            Write-Host "Klasse ist leer"
            continue
        } 
        else {
            # funktion Find-Klasse ausführen (Übergabeparameter $klassenName)
            $existingGroup = Find-Klasse -klassenName  $group.Klasse

            #Wenn Rückgabeparameter 1 ist
            if ($existingGroup) {
                Write-Output "Die Gruppe '$($group.Klasse)' existiert bereits. Erstellung wird übersprungen.`n"
                continue
            # wenn rückgabeparameter 0 ist
            } 
            else {
                # Funktion New-Klasse ausführen (Übergabeparameter $klassenName)
                New-Klasse -klassenName  $group.Klasse
            }
        }

        ## Klasse 2
        # Überprüfe ob Klasse leer ist
        if ([string]::IsNullOrWhiteSpace($group.Klasse2)) {
            Write-Host "Klasse2 ist leer"
            continue
        } 
        else {
            # funktion Find-Klasse ausführen (Übergabeparameter $klassenName)
            $existingGroup = Find-Klasse -klassenName  $group.Klasse2

            #Wenn Rückgabeparameter 1 ist
            if ($existingGroup) {
                Write-Output "Die Gruppe '$($group.Klasse2)' existiert bereits. Erstellung wird übersprungen.`n"
                continue
            # wenn rückgabeparameter 0 ist
            } 
            else {
                # Funktion New-Klasse ausführen (Übergabeparameter $klassenName)
                New-Klasse -klassenName  $group.Klasse2
            }
        }

    }

}

Funktion-1b