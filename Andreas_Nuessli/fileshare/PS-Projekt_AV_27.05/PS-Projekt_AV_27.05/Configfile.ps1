#--------------------------------------------------------------------------------
# Autor: Patrick Schmitt
# Funktion des Skripts: Konfigurationen, z.B. Pfade bereitstellen
# Datum: 07.01.2023
# Version: 1.0
# Bemerkungen:
#--------------------------------------------------------------------------------

# HashTable der Variable $config mit den Keys und Values.
$config = @{
    SchuelerCsv  = "C:\tmp\PS-Projekt_AV_21.05\schueler-klein.csv"
    InitPw       = "bztf.001"
    OUPath       = "OU=BZTF,DC=bztf,DC=local"
    OULernende   = "OU=Lernende,OU=BZTF,DC=bztf,DC=local"
    OUKlasse     = "OU=Klassengruppen,OU=BZTF,DC=bztf,DC=local"
    LogFileUser  = "C:\tmp\users.log"
    LogFileGroup = "C:\tmp\groups.log"
    ClassFolder  = "C:\BZTF\Klassen"
}