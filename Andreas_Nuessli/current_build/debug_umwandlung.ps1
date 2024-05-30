function DebugUmwandeln {

    param (
        [string]$csvpath 
    )

    try {
        # Pfad zu der neuen CSV Datei
        $newfile = "$PSScriptRoot\Schueler-test.csv"

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
DebugUmwandeln -csvpath $config.SchuelerCsv
