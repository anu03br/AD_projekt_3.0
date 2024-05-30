#--------------------------------------------------------------------------------
# Autor: Amar Vejapi
# Funktion des Skripts: Ganzes Skript, AD-User verwalten
# Datum: 21.05.2024
# Version: 1.0
# Bemerkungen/Infos: 
# - Die Funktionen 1a, 2a, 2b und TextUmwandeln sind von Amar Vejapi erstellt worden.
# - Die Funktionen 1b und 2c sind von Andreas Nüssli erstellt worden.
# - Das Aussehen vom ganzen Skript wurde von Amar und Andreas zusammen erstellt.
# - Das Korrigieren hat ausschliesslich Andreas gemacht.
#--------------------------------------------------------------------------------
Write-Host "Willkommen im AD Verwaltungsprogramm"
Write-Host "(c) 2024 Amar Vejapi & Andreas Nüssli"
Write-Host "Powered by FensterKraftMuschel 7.0"

. ".\Configfile.ps1"

# 1a-Skript
function Funktion-1a {
    # CSV-Datei importieren
    $csvData = Import-Csv $config.SchuelerCsv -Delimiter ";"

    foreach ($user in $csvData) {
        # Wenn der Benutzer bereits existiert, überspringen
        $existingUser = Get-ADUser -Filter {SamAccountName -eq $user.SamAccountName} -ErrorAction SilentlyContinue

        $password = $config.InitPw | ConvertTo-SecureString -AsPlainText -Force
        # Neuen AD-Benutzer erstellen
        New-ADUser -GivenName $user.Vorname `
                    -Surname $user.Nachname `
                    -Name "$($user.Vorname) $($user.Nachname)" `
                    -SamAccountName $user.Benutzername `
                    -Path $config.OULernende `
                    -Enabled $True `
                    -AccountPassword $password `
                    -ChangePasswordAtLogon $False
    }

    # Alle nicht mehr in der CSV-Datei vorhandenen Benutzer deaktivieren
    $csvUserNames = $csvData | ForEach-Object {$_.SamAccountName} -ErrorAction SilentlyContinue
    $ouDN = (Get-ADOrganizationalUnit -Filter {Name -eq "Lernende"}).DistinguishedName
    Get-ADUser -Filter {SamAccountName -in $csvUserNames} -SearchBase $ouDN | Disable-ADAccount
}


# 1b-Skript



# 2a-Skript
function Funktion-2a {
    try {
        $LogfilePath = $config.LogFileUser

        # nächste verfügbare Nummer herausfinden
        $NextLogFileNumber = 1
        while (Test-Path "$LogfilePath$NextLogFileNumber.log") {
            $NextLogFileNumber++
        }
    
        #Logfile erstellen ...
        $LogfileName = "$LogfilePath$NextLogFileNumber.log"

        #... und die Daten darin speichern
        $ouDN = (Get-ADOrganizationalUnit -Filter {Name -eq "Lernende"}).DistinguishedName
        Get-ADUser -Filter * -SearchBase $ouDN -Properties PasswordLastSet, LastLogonDate, BadLogonCount |
            Select-Object SamAccountName, PasswordLastSet, LastLogonDate, BadLogonCount |
            Export-Csv -Path $LogfileName -NoTypeInformation
        Write-Host "Ein Logfile wurde erfolgreich erstellt."
    } catch {
        Write-Host "Ein Logfile wurde NICHT erstellt, aus jeglichen Gründen"
    }
}


# 2b-Skript
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


    $frage2b = Read-Host "Welche Funktion wollen Sie betätigen? Konto entsperren [1], Konto aktivieren [2] oder Passwort neusetzen [3]"
    if ($frage2b -eq "1") {
        KontoEntsperren
    }
    elseif ($frage2b -eq "2") {
        KontoAktivieren
    }
    elseif ($frage2b -eq "3") {
        PWneu
    }
    else {
        "Fehler"
    }
}


# 2c-Skript



# Textumwandlung
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

# Menu
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