#--------------------------------------------------------------------------------
# Autor: Amar Vejapi, Andreas Nüssli
# Funktion des Skripts: CSV einlese, Umlaute ersetzten und ein korrigiertes CSV ausgeben
# Datum: 29.05.2024
# Version: 0.6
# Changelog
# 15.05.24 V0.5 Skript erstellt
# 29.05.24 V0.6 Debugging und einfügen eines params
# 31.05.24 V0.7 Übergabeparameter und  $newfile zeigen nun auf config VCariablen
# 03.06.24 v0.8 Encoding als latin1 definiert, Funktion kann in anderem Skript aufgerufen werden. Ready for testing.
#--------------------------------------------------------------------------------
# if $newfile = -csvpath '.\schueler-klein1.csv' and ".\schueler-klein2.csv" it works correctly
# function works with $newfile = $Config.Test2 AND DebugUmwandeln -csvpath $Config.Test1
# when calling the script from 1a it doesn't work "The term 'DebugUmwandeln' is not recognized as a name of a cmdlet,"

# config file mit relativen pfad laden
. ".\config.ps1"
function UmlauteErsetzen {


    param (
        [string]$csvpath 
    )

    try {
        # Pfad zu der neuen CSV Datei
        $newfile = $Config.Test2

        Write-Host "Lesen der CSV-Datei vom Pfad: $csvpath"
        

        # Lesen der CSV und Ersetzen der Umlaute
        $content = Get-Content $csvpath -Encoding UTF8 -ErrorAction Stop
        Write-Host "CSV-Datei erfolgreich gelesen."

        try {
            $newContent = $content | ForEach-Object {
            $_ -replace 'ä', 'ae' `
               -replace 'ö', 'oe' `
               -replace 'ü', 'ue'
            }
            Write-Host "Umlaute erfolgreich ersetzt."
        }
        catch{
            Write-Error "Beim ersetzen der Umlaute ist ein Fehler aufgetreten."
            Write-Error $_
        }
        
        Write-Host "Neue Datei wird erstellt unter: $newfile"

        # Schreiben des neuen Inhalts in die neue Datei
        Set-Content -Path $newfile -Value $newContent -Encoding UTF8 -ErrorAction Stop
        Write-Host "Umlaute wurden ersetzt und die Datei wurde unter $newfile gespeichert."
    } catch {
        Write-Host "Ein Fehler ist aufgetreten: $_"
    }
}
# Aufruf der Funktion
UmlauteErsetzen -csvpath $Config.Test1

