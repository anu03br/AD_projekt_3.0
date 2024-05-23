#1b
#Erstellen/*Löschen der dazugehörigen AD-Gruppen pro Klasse
#*Deaktivieren oder Löschen ⇒ sobald ein AD-Account beim nächsten Import nicht mehr im CSV File aufgeführt wird.

function Funktion-1b {
    # Erstellen von AD-Gruppen
    New-ADGroup -Name "Klassengruppen" -GroupScope Global -Path "OU=BZTF,DC=bztf,DC=local"

    # Löschen von AD-Gruppen
    #Remove-ADGroup -Identity "Klassengruppe" -Confirm:$false

}

Funktion-1b