#---------------------------------------------------------------------------------------------------------------------
# Autor: Amar Vejapi
# Datum: 21.05.2024
# Version: 1.0
# Bemerkungen: 
# Skript-Nr: 1a
# Funktion des Skripts: Erstellen/*Deaktivieren der AD-Accounts für alle Lernenden des BZT Frauenfeld gemäss CSV File
#---------------------------------------------------------------------------------------------------------------------

function Funktion-1a {
    # CSV-Datei importieren
    $csvData = Import-Csv ".\schueler-klein.csv" -Delimiter ";"

    foreach ($user in $csvData) {
        # Wenn der user schon existiert, dann nichts
        $existingUser = Get-ADUser -Filter {SamAccountName -eq $user.SamAccountName} -ErrorAction SilentlyContinue

        # Neuen AD-User erstellens
        New-ADUser -GivenName $user.Vorname `
                    -Surname $user.Nachname `
                    -Name "$($user.Vorname) $($user.Nachname)" `
                    -SamAccountName $user.Benutzername `
                    -Path "OU=BZTF,DC=bztf,DC=local" `
                    -Enabled $True `
                    -AccountPassword (ConvertTo-SecureString "bztf.001" -AsPlainText -Force) `
                    -ChangePasswordAtLogon $False
    }

    # Alle nicht mehr in der CSV-Datei vorhandenen Benutzer deaktivieren
    $csvUserNames = $csvData | ForEach-Object {$_.SamAccountName} -ErrorAction SilentlyContinue
    $ouDN = (Get-ADOrganizationalUnit -Filter {Name -eq "BZTF"}).DistinguishedName
    Get-ADUser -Filter {SamAccountName -in $csvUserNames} -SearchBase $ouDN | Disable-ADAccount
}

Funktion-1a