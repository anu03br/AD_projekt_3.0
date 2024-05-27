. ".\Configfile.ps1"

function Test {
    # CSV-Datei importieren
    $csvData = Import-Csv $config.SchuelerCsv -Delimiter ";"

    foreach ($user in $csvData) {
        # Wenn der Benutzer bereits existiert, überspringen
        $existingUser = Get-ADUser -Filter {SamAccountName -eq $user.SamAccountName} -ErrorAction SilentlyContinue
        Write-Host "Gut so 1"
        $password = $config.InitPw | ConvertTo-SecureString -AsPlainText -Force
        # Neuen AD-Benutzer erstellen
        New-ADUser -GivenName $user.Vorname `
                    -Surname $user.Nachname `
                    -Name "$($user.Vorname) $($user.Nachname)" `
                    -SamAccountName $user.Benutzername `
                    -Path $config.OUPath `
                    -Enabled $True `
                    -AccountPassword $password `
                    -ChangePasswordAtLogon $False
    }
    Write-Host "Gut so 2"

    # Alle nicht mehr in der CSV-Datei vorhandenen Benutzer deaktivieren
    Get-ADUser -SearchBase $config.OUPath -Filter * | ForEach-Object {
        $samAccountName = $_.SamAccountName
        if (-not (Import-Csv $config.SchuelerCsv | Where-Object { $_.SamAccountName -eq $samAccountName })) {
            Set-ADUser -Identity $samAccountName -Enabled $false
            Write-Host "Benutzer $samAccountName wurde deaktiviert."
        }
    }
}

Test