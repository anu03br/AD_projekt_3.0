#--------------------------------------------------------------------------------
# Autor: Amar Vejapi
# Funktion des Skripts: Bulk Funktion zum erstellen von AD usern aus einer CSV Liste
# Datum: 21.05.2024
# Version: 0.6
# Changelog
# 17.05.24 V0.5 Skript Erstellt
# 21.05.24 V0.6 
#--------------------------------------------------------------------------------

function Funktion-1a {
    # CSV-Datei importieren
    $csvData = Import-Csv ".\schueler-klein.csv" -Delimiter ";"

    foreach ($user in $csvData) {
        $existingUser = Get-ADUser -Filter {SamAccountName -eq $user.SamAccountName} -ErrorAction SilentlyContinue
        if ($existingUser) {
            # Benutzerdaten aktualisieren (optional)
        } else {
            New-ADUser -GivenName $user.Vorname `
                       -Surname $user.Nachname `
                       -Name "$($user.Vorname) $($user.Nachname)" `
                       -SamAccountName $user.Benutzername `
                       -Path "OU=BZTF,DC=bztf,DC=local" `
                       -Enabled $True `
                       -AccountPassword (ConvertTo-SecureString "bztf.001" -AsPlainText -Force) `
                       -ChangePasswordAtLogon $False
        }
    }

    # Alle nicht mehr in der CSV-Datei vorhandenen Benutzer deaktivieren
    $csvUserNames = $csvData | ForEach-Object { $_.SamAccountName }
    # DO NOT RUN THIS COMMAND IT WILL DISABLE THE ADMIN ACCOUNT WICH CANNOT BE REVERSED
    #Get-ADUser -Filter * | Where-Object { $_.SamAccountName -notin $csvData.SamAccountName } | Disable-ADAccount
}

Funktion-1a