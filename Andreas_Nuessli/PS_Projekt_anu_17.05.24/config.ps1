#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: Konfigurationen, z.B. Pfade bereitstellen
# Datum: 16.05.2024
# Version: 0.5
# Changelog
# 16.05.24 V0.5 First test with template
#--------------------------------------------------------------------------------

# HashTable der Variable $config mit den Keys und Values.
$config = @{
    SchuelerCsv  = ".\\schueler-kurz.csv" # changed to short CSV with just 10 names for testing
    InitPw       = "bztf.001"
    OUPath       = "OU=BZTF,DC=bztf,DC=local"
    OULernende   = "Lernende"
    OUKlasse     = "Klassengruppen"
    LogFileUser  = ".\\users.log"
    LogFileGroup = ".\\groups.log"
    ClassFolder  = ".\\Klassen"
    # Renamed extensionAttribute
    Klasse          = "extensionAttribute1"  # Custom attribute name $Klasse
    Klasse2         = "extensionAttribute2"  # Custom attribute name $Klasse2
    DisableDate     = "extensionAttribute3"  # Custom attribute name $disableDate
}

# Created date: Donnerstag 16.05.24
