#---------------------------------------------------------------------------------------------------------------------
# Autor: Amar Vejapi
# Datum: 21.05.2024
# Version: 1.0
# Bemerkungen: 
# Funktion des Skripts: Umlaute von einem Text entfernen
#---------------------------------------------------------------------------------------------------------------------

function TextUmwandeln {
    try {
        # Pfade zu den Dateien
        $importfile = Read-Host "Geben Sie den Pfad zur Eingabe-Datei ein"

        # Umlaute ersetzen
        (Get-Content $importfile) |
            ForEach-Object {
                $_ -replace 'ä', 'ae' `
                   -replace 'ö', 'oe' `
                   -replace 'ü', 'ue'
            } | Set-Content $importfile
        Write-Host "Umlaute wurden ersetzt und die Datei wurde unter $importfile gespeichert."
    } catch {
        Write-Host "Das Ersetzen von Umlauten wurde NICHT gemacht, aus jeglichen Gründen."
    }

}

TextUmwandeln