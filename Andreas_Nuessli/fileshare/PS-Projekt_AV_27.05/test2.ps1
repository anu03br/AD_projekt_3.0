. ".\Configfile.ps1"

function Test2 {
    # Pfade und Dateinamen anpassen
    $csvPath = "C:\tmp\PS-Projekt_AV_21.05\schueler-klein.csv"
    $ouPath = "OU=BZTF,DC=bztf,DC=local"

    # Passwort für die Benutzer festlegen
    $password = "bztf.001" | ConvertTo-SecureString -AsPlainText -Force

    # Benutzer aus der CSV-Datei importieren und anlegen
    Import-Csv $csvPath | ForEach-Object {
        $samAccountName = $_.SamAccountName
        $givenName = $_.GivenName
        $surname = $_.Surname

        # Prüfen, ob der Benutzer bereits existiert
        if (Get-ADUser -Filter {SamAccountName -eq $samAccountName}) {
            Write-Host "Benutzer $samAccountName existiert bereits."
        } else {
            # Benutzer anlegen
            New-ADUser -Name "$givenName.$surname" `
                -SamAccountName $samAccountName `
                -GivenName $givenName `
                -Surname $surname `
                -Path $ouPath `
                -Enabled $true `
                -AccountPassword $password `
                -ChangePasswordAtLogon $true
            Write-Host "Benutzer $samAccountName wurde erfolgreich angelegt."
        }
    }

    # Deaktiviere Benutzer, die nicht mehr in der CSV-Datei vorkommen
    $existingUsers = Get-ADUser -SearchBase $ouPath -Filter *
    $csvUsers = Import-Csv $csvPath
    foreach ($user in $existingUsers) {
        if (-not ($csvUsers | Where-Object { $_.SamAccountName -eq $user.SamAccountName })) {
            Set-ADUser -Identity $user.SamAccountName -Enabled $false
            Write-Host "Benutzer $($user.SamAccountName) wurde deaktiviert."
        }
    }
}

Test2