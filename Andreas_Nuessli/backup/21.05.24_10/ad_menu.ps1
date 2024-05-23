#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: Bulk Funktion zum erstellen von gruppen aus einer CSV Liste
# Datum: 21.05.2024
# Version: 0.5
# Changelog
# 17.05.24 V0.5 Skript Erstellt
# 21.05.24 Aufgrund Datenverlust Skript neu erstellt
#--------------------------------------------------------------------------------
Write-Host "Willkommen im AD Verwaltungsprogramm"
Write-Host "(C) 2024 Amar Vejapi & Andreas Nüssli"
Write-Host "----------------------------------------"
$Continue = $true

while ($Continue) {
    Write-Host "Bitte wählen Sie:`n"
    Write-Host "1. 1a Benutzer mit CSV abgleichen"
    Write-Host "2. 1b Gruppen mit CSV Abgleichen"
    Write-Host "3. 2a Logfile generieren"
    Write-Host "4. 2b AD accounts managen"
    Write-Host "5. 2c ÜBersicht über AD Accounts"
    Write-Host "6. Beenden`n"
    
    # Take choice 
    $Choice = Read-Host "Bitte wählen Sie eine Option (1-6)`n"
    
    switch ($Choice) {
        # run ADUser creation script
        1 {
            Write-Host "1a" 
            .\1a-Script.ps1
        }
        # create new group
        2 {
            Write-Host "1b"
            .\1b-Script.ps1 
        }
        # Create new user
        3 {
            Write-Host "2a" 
            .\2a-Script.ps1
        }
        # Reset password    
        4 {
            Write-Host "2b"
            .\2b-Script.ps1
        }
        5 {
            Write-Host "2c"
            .\2c-Script.ps1
            
        }
        6 {
            Write-Host "Beenden..."
            $Continue = $false
        }
        Default {
            Write-Host "Ungültige Wahl. Bitte wählen Sie eine gültige Option (1-5).`n"
        }
    }   
}
