Write-Host "Willkommen im AD Verwaltungsprogramm"
$Continue = $true

while ($Continue) {
    Write-Host "Bitte wählen Sie:`n"
    Write-Host "1. Import neuer User via CSV"
    Write-Host "2. Neue AD Gruppe Erstellen"
    Write-Host "3. neuer User erstellen"
    Write-Host "4. Passwort zurücksetzen"
    Write-Host "5. Beenden`n"
    
    # Take choice 
    $Choice = Read-Host "Bitte wählen Sie eine Option (1-5)`n"
    
    switch ($Choice) {
        # run ADUser creation script
        1 {
            Write-Host "Import neuer User via CSV gewählt"
            if (Test-Path .\Import-ADUser.ps1) {
                Write-Host "Calling Import-ADUser.ps1...`n"
                .\Import-ADUser.ps1
            } else {
                Write-Host "Das Skript Import-ADUser.ps1 wurde nicht gefunden.`n"
            }
        }
        # create new group
        2 {
            Write-Host "Neue AD Gruppe Erstellen gewählt`n"
            if (Test-Path .\Create-NewGroup.ps1) {
                Write-Host "Calling Create-NewGroup.ps1...`n"
                .\Create-NewGroup.ps1
            } else {
                Write-Host "Das Skript Create-NewGroup.ps1 wurde nicht gefunden.`n"
            }
        }
        # Create new user
        3 {
            Write-Host "Neuer User erstellen gewählt`n"
            if (Test-Path .\Create-NewADUser.ps1) {
                Write-Host "Calling Create-NewADUser.ps1...`n"
                .\Create-NewADUser.ps1
            } else {
                Write-Host "Das Skript Create-NewADUser.ps1 wurde nicht gefunden.`n"
            }
        }
        # Reset password    
        4 {
            Write-Host "Passwort zurücksetzen gewählt`n"
            if (Test-Path .\Reset-Password.ps1) {
                Write-Host "Calling Reset-Password.ps1...`n"
                .\Reset-Password.ps1
            } else {
                Write-Host "Das Skript Reset-Password.ps1 wurde nicht gefunden.`n"
            }
        }
        5 {
            Write-Host "Beenden..."
            $Continue = $false
        }
        Default {
            Write-Host "Ungültige Wahl. Bitte wählen Sie eine gültige Option (1-5).`n"
        }
    }   
}
