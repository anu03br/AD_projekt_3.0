#----------------------------
# Autor: Amar Vejapi
# Datum: 21.05.2024
# Version: 1.0
# Bemerkungen: 
# Funktion des Skripts: Menu
#----------------------------

$frage = Read-Host "Welche Funktion wollen Sie ausführen? [1a], [1b], [2a], [2b], [2c] oder einen Text von Umlauten befreien [Text]"
if ($frage -eq "1a") {
    Funktion-1a
}
elseif ($frage -eq "1b") {
    Funktion-1b
}
elseif ($frage -eq "2a") {
    Funktion-2a
}
elseif ($frage -eq "2b") {
    Funktion-2b
}
elseif ($frage -eq "2c") {
    Funktion-2c
}
elseif ($frage -eq "Text") {
    TextUmwandeln
}
else {
    "Fehler"
}