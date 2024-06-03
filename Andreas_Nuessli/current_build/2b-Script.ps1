#-------------------------------------------------
# Autor: Amar Vejapi
# Datum: 21.05.2024
# Version: 1.0
# Bemerkungen: 
# Skript-Nr: 2b
# Funktion des Skripts: Für einzelne AD-Accounts:
#                       - Konto entsperren
#                       - Konto aktivieren
#                       - Passwort neu setzen
#-------------------------------------------------

function Funktion-2b {

    $Benutzer = Read-Host "Wer sollte hier benutzt werden (SamAccountName)?"
    
    # Konto entsperren: Nach vielen Anmeldeversuchen wird der Account gesperrt, deshalb wird er hier nun entsperrt.
    function KontoEntsperren {
        try {
            Unlock-ADAccount -Identity $Benutzer

            Write-Host "Das Konto '$Benutzer' wurde erfolgreich entsperrt."
        } catch {
            Write-Host "Fehler beim Entsperren des Kontos '$Benutzer': $_"
        }
    }


    # Konto aktivieren: Bei einem deaktivierten Konto kann man sich nicht mehr einloggen
    function KontoAktivieren {
        try {
            Enable-ADAccount -Identity $Benutzer

            Write-Host "Das Konto '$Benutzer' wurde erfolgreich aktiviert."
        } catch {
            Write-Host "Fehler beim Aktivieren des Kontos '$Benutzer': $_"
        }
    }


    # Neues Passwort erstellen (Standartpasswort)
    function PWneu {
        try {
            $NewPassword = Read-Host "Wählen Sie Ihr neues Passwort"

            # Passwort zurücksetzen
            Set-ADAccountPassword -Identity $Benutzer -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)

            # Passwortänderung erzwingen
            Set-ADUser -Identity $Benutzer -ChangePasswordAtLogon $False

            Write-Host "Das Passwort des Kontos '$Benutzer' wurde erfolgreich erstellt."
        } catch {
            Write-Host "Fehler beim ändern des Passworts des Kontos '$Benutzer': $_"
        }
    }


    $frage2b = Read-Host "Welche Funktion wollen Sie betätigen? Konto entsperren [1], Konto aktivieren [2],  Passwort neusetzen [3], Zurück ins Hauptmenü [4]"
    if ($frage2b -eq "1") {
        KontoEntsperren
    }
    elseif ($frage2b -eq "2") {
        KontoAktivieren
    }
    elseif ($frage2b -eq "3") {
        PWneu
    }
    elseif ($frage2b -eq "4") {
        # Geht zurück ins Hauptmenü
        return
    }
    else {
        "Fehler"
    }
}

Funktion-2b