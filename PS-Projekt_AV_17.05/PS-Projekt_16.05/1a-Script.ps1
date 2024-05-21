#1a
#Erstellen/*Deaktivieren der AD-Accounts für alle Lernenden des BZT Frauenfeld gemäss CSV File

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
    Get-ADUser -Filter * | Where-Object { $_.SamAccountName -notin $csvData.SamAccountName } | Disable-ADAccount
}

Funktion-1a