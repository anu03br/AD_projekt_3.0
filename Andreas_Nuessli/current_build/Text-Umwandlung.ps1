function TextUmwandeln {

    param (
        [string]$csvpath
    )

    # config file mit relativen pfad laden
    . ".\config.ps1"
    
    # Pfad zu der neuen CSV datei
    $newfile = "$PSScriptRoot\Schueler-Umlaut.csv"

    # leist die CSV im übergebenen Pfad aus und ersetzt alle instanzen von umlauten
    #schreibt den inhalt in ein neues CSV unter dem pfad $newfile gespeichert
    (Get-Content $csvpath) |
        ForEach-Object {
            $_ -replace 'ä', 'ae' `
               -replace 'ö', 'oe' `
               -replace 'ü', 'ue'
        } | Set-Content $newfile

    Write-Host "Umlaute wurden ersetzt und die Datei wurde unter $newfile gespeichert."

}

TextUmwandeln -csvpath = $PSScriptRoot\