#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: AD user management
# Datum: 16.05.2024
# Version: 1.0
# Changelog
# 16.05.24 V0.5 Skript Erstellt
# 17.05.24 v0.6 Skript läuft ohne fehler
# 21.05.24 v0.7 Aufgrund datenverlust Skript neu geschrieben
# 21.05.24 v1.0 Getestet, Skript lauft korrekt und ohne Fehler
# 21.05.24 v1.1 Abfrage nach gesperrten benutzern hinzugefügt (mit anzeige der anzahl falls 0)
#--------------------------------------------------------------------------------
#2c
function Show-ADUserManagementMenu {
    Write-Host "Willkommen im AD Verwaltungsprogramm"
    $Continue = $true

    while ($Continue) {
        Write-Host "Bitte wählen Sie:`n"
        Write-Host "1. Alle Benutzer für welche kein Passwort gesetzt ist"
        Write-Host "2. Alle Benutzer deren Passwort nie abläuft"
        Write-Host "3. Alle Benutzer welche deaktiviert sind anzeigen"
        Write-Host "4. Alle Benutzer anzeigen die Gesperrt sind"
        Write-Host "5. Beenden`n"
        
        # Take choice 
        $Choice = Read-Host "Bitte wählen Sie eine Option (1-4)`n"

        switch ($Choice) {
            1 {
                # Benutzer suchen für welche kein Passwort gesetzt ist
                Get-ADUser -Filter * -Properties PasswordLastSet | Where-Object { $_.PasswordLastSet -eq $null } | Format-Table Name, SamAccountName, PasswordLastSet
            }
            2 {
                # Benutzer suchen deren Passwort nie abläuft
                Get-ADUser -Filter * -Properties PasswordNeverExpires | Where-Object { $_.PasswordNeverExpires -eq $true } | Format-Table Name, SamAccountName, PasswordNeverExpires
            }
            3 {
                # Benutzer suchen die deaktiviert sind (Enabled = false)
                Get-ADUser -Filter * -Properties Enabled | Where-Object { $_.Enabled -eq $false } | Format-Table Name, SamAccountName, Enabled
            }
            4 {
                # Benutzer suchen die gesperrt sind
                $lockedOutCount = (Get-ADUser -Filter * -Properties LockedOut | Where-Object {$_.LockedOut -eq $true}).Count
                Write-Host "Total locked-out users: $lockedOutCount"
            }
            5 {
                Write-Host "Programm wird krass beendet `nNoCap {°o°}~ **X"
                $Continue = $false  
            }
            default {
                Write-Host "Ungültige Wahl. Bitte wählen Sie eine gültige Option (1-4).`n"
            }
        }
    }
}

# Funktion aufrufen
Show-ADUserManagementMenu
