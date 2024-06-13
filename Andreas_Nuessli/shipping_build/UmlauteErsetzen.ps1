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
# 05.06.24 v0.9 Mehr Sonderseichen in die Liste aufgenommen (uà,é,è)
#--------------------------------------------------------------------------------
# skript does not convert ë to e
# Marugg;Joël;joel.marugg;PMG25A; possible encoding error?

# config file mit relativen pfad laden
. ".\config.ps1"
function UmlauteErsetzen {


    param (
        [string]$csvpath 
    )

    try {
        # Pfad zu der neuen CSV Datei
        $newfile = $Config.SchuelerCsv

        Write-Host "Lesen der CSV-Datei vom Pfad: $csvpath"
        

        # Lesen der CSV und Ersetzen der Umlaute
        $content = Get-Content $csvpath -Encoding latin1 -ErrorAction Stop
        Write-Host "CSV-Datei erfolgreich gelesen."

        try {
            $newContent = $content | ForEach-Object {
            $_  -replace 'Ã–', 'Oe' `
                -replace 'ä', 'ae' `
                -replace 'Ä', 'Ae' `
                -replace 'ö', 'oe' `
                -replace 'Ö', 'Oe' `
                -replace 'ü', 'ue' `
                -replace 'Ü', 'Ue' `
                -replace 'à', 'a' `
                -replace 'À', 'A' `
                -replace 'é', 'e' `
                -replace 'É', 'E' `
                -replace 'è', 'e' `
                -replace 'È', 'E' `
                -replace 'ë', 'e' `
                -replace 'Ë', 'E'
            }
            Write-Host "Umlaute erfolgreich ersetzt."
        }
        catch{
            Write-Error "Beim ersetzen der Umlaute ist ein Fehler aufgetreten."
            Write-Error $_
        }
        
        Write-Host "Neue Datei wird erstellt unter: $newfile"

        # Schreiben des neuen Inhalts in die neue Datei
        Set-Content -Path $newfile -Value $newContent -Encoding latin1 -ErrorAction Stop
        Write-Host "Umlaute wurden ersetzt und die Datei wurde unter $newfile gespeichert."
    } catch {
        Write-Host "Ein Fehler ist aufgetreten: $_"
    }
}
# Aufruf der Funktion
UmlauteErsetzen -csvpath $Config.SchuelerCsv

