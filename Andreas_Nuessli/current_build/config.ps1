﻿#--------------------------------------------------------------------------------
# Autor: Amar Vejapi, Andreas Nüssli
# Funktion des Skripts: Ganzes Skript
# Funktion des Skripts: Konfigurationen, z.B. Pfade bereitstellen
# Datum: 15.05.2024
# Version: 0.5
# Changelog
# 15.05.24 V0.5 config file erstellt
# 21.05.24 V0.6 Umbenennung config file von "Projekt Skript zu "config.ps1"
# 21.05.24 V0.6 Variablen LogFileUser, LogFileGroup, ClassFolder mit relativen statt absoluten pfaden versehen
#--------------------------------------------------------------------------------

# HashTable der Variable $config mit den Keys und Values.
$config = @{
    SchuelerCsv  = ".\schueler-klein.csv"
    #testpath for Text-Umwandlung
    Test1      = ".\schueler-klein.csv"
    Test2      = ".\schueler2.csv"
    InitPw       = "bztf.001"
    OUPath       = "OU=BZTF,DC=bztf,DC=local"
    OULernende   = "Lernende"
    OUKlasse     = "Klassengruppen"
    LogFileUser  = ".\logfiles\users\users.log"
    LogFileGroup = ".\logfiles\groups\groups.log"
    ClassFolder  = ".\\Klassen"
    Domain       = "bztf.local"
    # organization should be position 
    Organisation = "BZTF Frauenfeld"

    # Klasse wird gespeichert unter $User.company
    # Klasse2 wird gespeichert unter $User.Department    
}