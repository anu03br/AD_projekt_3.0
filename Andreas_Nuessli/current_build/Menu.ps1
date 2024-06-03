#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: Hauptmenue inputgeführt
# Datum: 23.05.2024
# Version: 0.5
# Changelog
# 23.05.24 V0.5 Skript Erstellt
# 23.05.24 V0.5 switch case erstellt, write host hinzugefügt
#--------------------------------------------------------------------------------
Write-Host "Willkommen im AD Verwaltungsprogramm"
Write-Host "(c) 2024 Amar Vejapi & Andreas Nüssli"
Write-Host "Powered by FensterKraftMuschel 7.0"
$Continue = $true

while ($Continue) {
    Write-Host "Bitte wählen Sie:`n"
    Write-Host "1. 1a"
    Write-Host "2. 1b"
    Write-Host "3. 2a"
    Write-Host "4. 2b"
    Write-Host "5. 2c - Übersicht über AD Benutzer"
    Write-Host "6. Beenden`n"
    
    # Take choice 
    $Choice = Read-Host "Bitte wählen Sie eine Option (1-6)`n"
    
    switch ($Choice) {
        # 1a
        1 {
            Write-Host "CSV abgleich User wird gestartet..`n"

        }
        # 1b
        2 {
            Write-Host "CSV abgleich Gruppen wird gestartet..`n"

        }
        # 2a
        3 {
            Write-Host "Logfile erstellung wird gestartet..`n"

        }
        # 2b   
        4 {
            Write-Host "AD Benutzer verwaltung wird gestartet..`n"
            .\2b-Script.ps1
        }
        # 2c - Übersicht über AD Benutzer
        5 {
            Write-Host "Übersicht wird gestartet..`n"
            .\ADUserManagement.ps1
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
