#Frage

$frage = Read-Host "Welche Funktion wollen Sie ausführen? [1a], [1b], [2a], [2b] oder [2c]"
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
else {
    "Fehler"
}