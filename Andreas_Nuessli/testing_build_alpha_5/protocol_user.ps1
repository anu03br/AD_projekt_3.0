#--------------------------------------------------------------------------------
# Autor: Amar Vejapi
# Funktion des Skripts: Bulk Funktion zum importieren von Usern aus einer CSV Liste
# Datum: 16.05.2024
# Version: 1.0
# Changelog
# 11.06.24 v1.0 skript ausgelaget von 2a-Protokoll-User.ps1
#--------------------------------------------------------------------------------
function protokoll_user {
    try {
        $LogfilePath = $config.LogFileUser

        #aktuelle zeit in variable speichern
        $timestamp = Get-Date -Format "yyyy:MM:dd HH:mm:ss"

        # Logfile erstellen ...
        # Sollte users@ datetime yyyy:MM:dd: HH:mm:ss sein
        $LogfileName = "users@$timestamp.log" -replace ":", "-" -replace " ", "_"

        # ... und die Daten darin speichern
        "Datum: $(Get-Date -Format "dd.MM.yyyy HH:mm:ss")" | Out-File -FilePath "$LogfilePath$LogfileName"
        # name -eq "bztf" sollte eher auf config.ou verweisen
        $ouDN = (Get-ADOrganizationalUnit -Filter {Name -eq "BZTF"}).DistinguishedName
        Get-ADUser -Filter * -SearchBase $ouDN -Properties PasswordLastSet, LastLogonDate, BadLogonCount |
            Select-Object SamAccountName, PasswordLastSet, LastLogonDate, BadLogonCount |
            Add-Content -Path "$LogfilePath$LogfileName" -ErrorAction Stop

        $message = "Ein Logfile wurde erfolgreich erstellt."
        Write-Log -message $message -logFilePath $config.LogFileActivities
        Write-Host $message -ForegroundColor Green
    } catch {
        # Hier sollte mehr Info angezeigt werden
        $errorMessage =  "Beim erstellen des logfiles ist ein Fehler aufgetreten.`n$_"
        Write-Log -message $errorMessage -logFilePath $config.LogFileActivities
        Write-Host $errorMessage -ForegroundColor Red # delete this line before shipping

    }
}
protokoll_user