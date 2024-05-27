#--------------------------------------------------------------
# Autor: Amar Vejapi
# Datum: 21.05.2024
# Version: 1.0
# Bemerkungen: 
# Skript-Nr: 2c
# Funktion des Skripts: Übersicht über alle AD-Benutzer:
#                       - für welche kein Passwort gesetzt ist
#                       - Passwort läuft nie ab
#                       - deaktivierte/gesperrte AD-Benutzer
#--------------------------------------------------------------

function Funktion-2c {
    # Benutzer ohne Passwort herausfinden
    function NoPW {
        try {
            Get-ADUser -Filter {PasswordNotRequired -eq $True} | Select-Object SamAccountName
        } catch {
            Write-Host "Es wurden keine Konten mit keinem Passwort gefunden"
        }
    }

    # Deaktivierte Benutzerkonten anschauen
    function fuerimmerPW {
        try {
            

            Write-Host "Das Konto '$Benutzer' wurde erfolgreich entsperrt."
        } catch {
            Write-Host "Es wurden keine Konten mit keinem Passwort gefunden"
        }
    }

    # Gesperrte Benutzerkonten anschauen
    function nverfuegbareKonten {
        try {
            Search-ADAccount -LockedOut | Select-Object SamAccountName
            Get-ADUser -Filter {Enabled -eq $False} | Select-Object SamAccountName

            Write-Host "Das Konto '$Benutzer' wurde erfolgreich entsperrt."
        } catch {
            Write-Host "Fehler beim Entsperren des Kontos '$Benutzer': $_"
        }
    }

        $frage2c = Read-Host "Welche Funktion wollen Sie betätigen? Benutzer mit keine Passwörter [1], Benutzer mit nicht-ablaufbarem Passwort ansehen [2] oder deaktivierte/gesperrte Konten ansehen [3]"
    if ($frage2c = "1") {
        NoPW
    }
    elseif ($frage2c = "2") {
        fuerimmerPW
    }
    elseif ($frage2c = "3") {
        nverfuegbareKonten
    }
    else {
        "Fehler"
    }
}

Funktion-2c