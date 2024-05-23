function TextUmwandeln {
    # Pfade zu den Dateien
    $importfile = Read-Host "Geben Sie den Pfad zur Eingabe-Datei ein"

    # Umlaute ersetzen
    (Get-Content $importfile) |
        ForEach-Object {
            $_ -replace '�', 'ae' `
               -replace '�', 'oe' `
               -replace '�', 'ue'
        } | Set-Content $importfile

    Write-Host "Umlaute wurden ersetzt und die Datei wurde unter $importfile gespeichert."

}

TextUmwandeln