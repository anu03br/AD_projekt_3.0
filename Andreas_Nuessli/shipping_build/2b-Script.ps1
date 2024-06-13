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
# ChangeLog
# anu - redid input messages, integrated Write-Log into 2b
#-------------------------------------------------

# funktion Write-Log importieren
. "$PSScriptRoot\Write-Log.ps1"  
# config file mit relativen pfad laden
. ".\config.ps1"

function Funktion-2b {

    # Function to get a valid user
    function Get-ValidUser {
        
        do {
            $Benutzername = Read-Host "Bitte geben Sie den SamAccountNamen des zu bearbeitenden Benutzers ein`nBeispiel(leif.sterchi)"
            $existingUser = Get-ADUser -Filter "SamAccountName -eq '$Benutzername'" -ErrorAction SilentlyContinue

            if (-not $existingUser) {
                $message = "Der Benutzer '$Benutzername' wurde nicht gefunden. Bitte versuchen Sie es erneut."
                Write-Log -message $message -logFilePath $config.LogFileActivities
                Write-Host $message -ForegroundColor Red
            }
        } until ($existingUser)

        return $Benutzername
    }

    # Konto entsperren: Nach vielen Anmeldeversuchen wird der Account gesperrt, deshalb wird er hier nun entsperrt.
    function KontoEntsperren {
        try {
            Unlock-ADAccount -Identity $Benutzer

            $message = "Das Konto '$Benutzer' wurde erfolgreich entsperrt."
            Write-Log -message $message -logFilePath $config.LogFileActivities
            Write-Host $message -ForegroundColor Blue
        } catch {
            $errorMessage =  "Fehler beim Entsperren des Kontos '$Benutzer': $_"
            Write-Log -message $errorMessage -logFilePath $config.LogFileActivities
        }
    }


    # Konto aktivieren: Bei einem deaktivierten Konto kann man sich nicht mehr einloggen
    function KontoAktivieren {
        try {
            Enable-ADAccount -Identity $Benutzer

            $message = "Das Konto '$Benutzer' wurde erfolgreich aktiviert."
            Write-Log -message $message -logFilePath $config.LogFileActivities
            Write-Host $message -ForegroundColor Blue
        } catch {
            $errorMessage = "Fehler beim Aktivieren des Kontos '$Benutzer': $_"
            Write-Log -message $errorMessage -logFilePath $config.LogFileActivities
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

            $message = "Das Passwort des Kontos '$Benutzer' wurde erfolgreich erstellt."
            Write-Log -message $message -logFilePath $config.LogFileActivities
            Write-Host $message -ForegroundColor Blue

        } catch {
            $errorMessage = "Fehler beim ändern des Passworts des Kontos '$Benutzer': $_"
            Write-Log -message $errorMessage -logFilePath $config.LogFileActivities
        }
    }
    # Benutzernamen Abfragen
    $Benutzer = Get-ValidUser
    $continue = $true
    while ($continue) {
    
        Write-Host "Bitte wählen Sie:`n"
        Write-Host "1. Das Konto des gewählten Benutzers entsperren"
        Write-Host "2. Das Konto des gewählten Benutzers aktivieren"
        Write-Host "3. Für den gewählten Benutzer ein neues Passwort erstellen"
        Write-Host "4. Einen anderen Benutzer auswählen"
        Write-Host "5. Zurück ins Hauptmenü`n"

        $frage2b = Read-Host "Bitte wählen Sie eine Option (1-5)`n"
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
            #neuen benutzernamen Abfragen
            $Benutzer = Get-ValidUser
        }
        elseif ($frage2b -eq "5") {
            # Geht zurück ins Hauptmenü
            $Continue = $false
        }
        else {
            Write-Host "Ungültige Wahl. Bitte wählen Sie eine gültige Option (1-5).`n" -ForegroundColor Red
        }
        
    }    
}
Funktion-2b