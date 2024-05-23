#2b
#Für einzelne AD-Accounts:
#  - Konto entsperren
#  - Konto aktivieren
#  - Passwort neu setzen

function Funktion-2b {

    $Benutzer = Read-Host "Wer sollte hier benutzt werden (SamAccountName)?"
    
    # Konto entsperren
    function KontoEntsperren {
        
    }

    # Konto/Konten aktivieren, falls es/sie deaktiviert ist/sind
    function KontoAktivieren {
        Enable-ADAccount -Identity "$Benutzer"
    }

    # Neues Passwort erstellen (Standartpasswort)
    function PWneu {
        $NewPassword = "bztf.001"

        # Passwort zurücksetzen
        Set-ADAccountPassword -Identity "$Benutzer" -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)

        # Passwortänderung erzwingen
        Set-ADUser -Identity "$Benutzer" -ChangePasswordAtLogon $True
    }

    $frage2b = Read-Host "Welche Funktion wollen Sie betätigen? Konto entsperren [1], Konto aktivieren [2] oder Passwort neusetzen [3]"
    if ($frage2b = "1") {
        KontoEntsperren
    }
    elseif ($frage2b = "2") {
        KontoAktivieren
    }
    elseif ($frage2b = "3") {
        PWneu
    }
    else {
        "Fehler"
    }
}

Funktion-2b