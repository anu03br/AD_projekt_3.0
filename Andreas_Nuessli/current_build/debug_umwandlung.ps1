#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: CSV einlese, Umlaute ersetzten und ein korrigiertes CSV ausgeben
# Datum: 29.05.2024
# Version: 0.6
# Changelog
# 15.05.24 V0.5 Skript erstellt
# 29.05.24 V0.6 Debugging und einfügen eines params
# 31.05.24 V0.7 Übergabeparameter und  $newfile zeigen nun auf config VCariablen
#
#--------------------------------------------------------------------------------
# if $newfile = -csvpath '.\schueler-klein1.csv' and ".\schueler-klein2.csv" it works correctly

# config file mit relativen pfad laden
. ".\config.ps1"
function DebugUmwandeln {


    param (
        [string]$csvpath 
    )

    try {
        # Pfad zu der neuen CSV Datei
        $newfile = $Config.Test2

        Write-Host "Lesen der CSV-Datei vom Pfad: $csvpath"
        Write-Host "Neue Datei wird erstellt unter: $newfile"

        # Lesen der CSV und Ersetzen der Umlaute
        $content = Get-Content $csvpath -ErrorAction Stop
        Write-Host "CSV-Datei erfolgreich gelesen."

        $newContent = $content | ForEach-Object {
            $_ -replace 'ä', 'ae' `
               -replace 'ö', 'oe' `
               -replace 'ü', 'ue'
        }

        Write-Host "Umlaute erfolgreich ersetzt."

        # Schreiben des neuen Inhalts in die neue Datei
        Set-Content -Path $newfile -Value $newContent -ErrorAction Stop
        Write-Host "Umlaute wurden ersetzt und die Datei wurde unter $newfile gespeichert."
    } catch {
        Write-Host "Ein Fehler ist aufgetreten: $_"
    }
}
# config file mit relativen pfad laden
. ".\config.ps1"

# Beispielaufruf der Funktion
DebugUmwandeln -csvpath $Config.Test1
