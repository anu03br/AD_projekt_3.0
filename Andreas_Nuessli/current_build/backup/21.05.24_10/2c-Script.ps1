#--------------------------------------------------------------------------------
# Autor: Amar Vejapi
# Funktion des Skripts: Übersicht über alle AD Benutzer
# Datum: 21.05.2024
# Version: 0.6
# Changelog
# 17.05.24 V0.5 Skript Erstellt
# 21.05.24 V0.6 
#--------------------------------------------------------------------------------
#Übersicht über alle AD-Benutzer:
#  - für welche kein Passwort gesetzt ist
#  - Passwort läuft nie ab
#  - deaktivierte/gesperrte AD-Benutzer

function Funktion-2c {
    # Benutzer ohne Passwort herausfinden
    function NoPW {
        Get-ADUser -Filter {PasswordNotRequired -eq $True} | Select-Object SamAccountName
    }

    # Deaktivierte Benutzerkonten anschauen
    function deaktivierteKonten {
        Get-ADUser -Filter {Enabled -eq $False} | Select-Object SamAccountName
    }

    # Gesperrte Benutzerkonten anschauen
    function gesperrteKonten {
        Search-ADAccount -LockedOut | Select-Object SamAccountName
    }

        $frage2c = Read-Host "Welche Funktion wollen Sie betätigen? Benutzer mit keine Passwörter [1], deaktivierte Konten ansehen [2] oder gesperrte Konten ansehen [3]"
    if ($frage2c = "1") {
        NoPW
    }
    elseif ($frage2c = "2") {
        deaktivierteKonten
    }
    elseif ($frage2c = "3") {
        gesperrteKonten
    }
    else {
        "Fehler"
    }
}

Funktion-2c