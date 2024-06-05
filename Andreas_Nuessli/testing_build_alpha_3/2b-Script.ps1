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

    $Benutzer = Read-Host "Bitte geben Sie den SamAccountNamen des zu bearbeitenden Benutzers ein`nBeispiel(leif.sterchi)"
    $continue = $true

    while ($continue) {
        
        Write-Host "Bitte wählen Sie:`n"
        Write-Host "1. Das Konto des gewählten Benutzers entsperren"
        Write-Host "2. Das Konto des gewählten Benutzers aktivieren"
        Write-Host "3. Für den gewählten Benutzer ein neues Passwort erstellen"
        Write-Host "4. Einen anderen Benutzer auswählen"
        Write-Host "5. Zurück ins Hauptmenü`n"

        $frage2b = Read-Host "Bitte wählen Sie eine Option (1-4)`n"
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
            $Benutzer = Read-Host "Bitte geben Sie den SamAccountNamen des anderen Benutzers ein`nBeispiel(leif.sterchi)"
        }
        elseif ($frage2b -eq "5") {
            # Geht zurück ins Hauptmenü
            $Continue = $false
        }
        else {
            "Fehler"
        }
    }    
}

Funktion-2b