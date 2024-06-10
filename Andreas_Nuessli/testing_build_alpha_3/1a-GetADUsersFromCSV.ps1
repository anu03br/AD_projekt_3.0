#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: Bulk Funktion zum importieren von Usern aus einer CSV Liste
# Datum: 16.05.2024
# Version: 1.0
# Changelog
# 16.05.24 V0.5 Skript Erstellt
# 27.05.24 v0.6 -Path variable so gesetzt,dass sie die config cvariablen 'OULernende' und 'OUPath' zum krorrekten -path zusammensetzt
# 27.05.24 v0.7 Unterfunktion erstellt, welche die AD Nutzer welche nicht mehr im CSV sind deaktiviert. Alle Write-Hosts und Comments auf Deutsch geschrieben
# 28.05.24 v0.8 Beim erstellen des ADUsers wird die Klasse in -Company und die Klasse2 in -Department Gespeichert. Diese Können bei den Benutzereigenschaften im Reiter Organisation eingesehen werden
# 28.05.24 v0.8.1 name der unterfunktion in Clear-OldUsers umbenannt
# 03.06.24 v0.8.5 Funktion zum Ersetzen von Umlauten wurde integriert. Skript ist bereit für Testing
# 03.06.24 v0.8.6 Name der Datei in "1a-GetADUsersFromCSV.ps1 umbenannt"
# 05.06.24 v0.9 Funktion AddToGroup in Hauptfunktion Get-ADUsersFromCSV integriert. AddToGroup überprüft nun auch, ob ein Gruppenname leer ist.
# 05.06.24 v0.9.1  IF $user.Benutzername length -gt 20 truncate to 20 chars
# 10.06.2024 v0.9.2 Benutzenamen werden nun direkt in $users angepasst. diese variable wird in allen subfunktionen genutzt.
# 10.06.2024 v1.0 Write-Log funktion geschrieben und ausgelagert. Write-Log funktioniert in 1a.
#--------------------------------------------------------------------------------
#Erstellen/*Deaktivieren der AD-Accounts für alle Lernenden des BZT Frauenfeld gemäss CSV File

# funktion textumwandlung importieren
. "$PSScriptRoot\UmlauteErsetzen.ps1"
# funktion Write-Log importieren
. "$PSScriptRoot\Write-Log.ps1"  
# config file mit relativen pfad laden
. ".\config.ps1"

#funktion, welche die User mit der CSV vergleicht und alle Benutzer deaktiviert welche Im CSV Nicht mehr vorhanden sind
function Clear-OldUsers {

    param (
        [array]$csv
    )

    # Alle Benutzernamen aus dem CSV lesen
    $csvUserNames = $csv | ForEach-Object { $_.Benutzername } -ErrorAction Stop

    # Gibt eine liste mit den SamAccountNames aller ADUser in "Lernende" aus
    $adUsers = Get-ADUser -Filter * -SearchBase "OU=$($config.OULernende),$($config.OUPath)" | Select-Object -ExpandProperty SamAccountName

    # Zähler für disaelte User initialisieren
    $disabledUserCount = 0

    # Loope durch alle Benutzer und überprüfe , ob sie noch im Csv sind
    foreach ($user in $adUsers) {
        # wenn sie nicht mehr im CSV sind
        if ($user -notin $csvUserNames) {
            try {
                # deaktiviere diesen User
                Disable-ADAccount -Identity $user
                
                $message = "Der Benutzer '$user' wurde disabled"
                Write-Log -message $message -logFilePath $config.LogFileActivities
                Write-Host $message
                $disabledUserCount++
            }
            catch {
                 $errorMessage = "Beim Deaktivieren des Benutzers '$user' ist ein Fehler aufgetreten.`n$_"
                Write-Log -message $errorMessage -logFilePath $config.LogFileActivities
                Write-Host $errorMessage
            }
            
        }
    }
     # Am schluss gib die Totale anzahl deaktivierter User aus (so sehen wir auch wenn kein User deaktiviert wird)
     $message = "Anzahl deaktivierter User: $disabledUserCount`n"
     Write-Host $message -ForegroundColor Blue
     Write-Log -message $message -logFilePath $config.LogFileActivities
}

function AddToGroup {
    # GroupName (Klasse) und SAM (User.SAMAccountName) übergeben
    param (
        [string]$GroupName,
        [string]$SAM
    )
    # Überprüfe, ob eine Gruppe leer oder ' ' ist (wenn keine Klasse im CSV vorhanden ist)
    if ([string]::IsNullOrWhiteSpace($GroupName)) {
        $message = "Die Gruppe '$GroupName' ist leer oder nicht vorhanden, überspringe."
        Write-Log -message $message -logFilePath $config.LogFileActivities
        return
    }
    # Überprüfen, ob die Gruppe existiert
    $existingGroup = Get-ADGroup -Filter {Name -eq $GroupName} -ErrorAction SilentlyContinue

    if ($existingGroup) {
        try {
            # wenn Gruppe existiert, füge den benutzer hinzu
            Add-ADGroupMember -Identity $GroupName -Members $SAM -ErrorAction Stop
            $message = "Der Benutzer '$SAM' wurde zur Gruppe '$GroupName' hinzugefügt."
            # Write-Host $message
            Write-Log -message $message -logFilePath $config.LogFileActivities
        }
        catch {
            $errorMessage = "Beim Hinzufügen des Benutzers '$SAM' zur Gruppe '$GroupName' ist ein Fehler aufgetreten.`n$_"
            Write-Log -message $errorMessage -logFilePath $config.LogFileActivities
        }
    }
    else {
        $message =  "Die Gruppe '$GroupName' existiert nicht, überspringe."
        Write-Log -message $message -logFilePath $config.LogFileActivities
    }
}

# Funktion um neue ADUser zu erstellen (nur wenn nicht vorhanden)
function Add-UsersFromCsv {

    param (
            [array]$csv
        )

    $successfulUser = 0
    $errorCounter = 0
    $skippedUser = 0

    foreach ($user in $csv) {

        # den benutzernamen des users zwischenspeichern
        $Benutzername = $user.Benutzername


        # überprüfe, ob der Benutzer bereits im AD existiert
        $existingUser = Get-ADUser -Filter "SamAccountName -eq '$Benutzername'" -ErrorAction SilentlyContinue
        if ($existingUser) {
            $message = "Der Benutzer '$Benutzername' existiert bereits. Erstellung wird übersprungen.`n"
            Write-Log -message $message -logFilePath $config.LogFileActivities
            $skippedUser ++
            continue
        } else {
           
            # wenn der User noch nicht existiert erstelle einen Neuen Account
            # "@bztf.local" und BZTF Frauenfeld in config varfiablen auslagern $Config.domain = "Bztf.local"
            try {
                New-ADUser -GivenName $user.Vorname `
                           -Surname $user.Name `
                           -Name "$($user.Vorname) $($user.Name)" `
                           -DisplayName "$($user.Vorname) $($user.Name)" `
                           -SamAccountName $Benutzername `
                           -UserPrincipalName "$($Benutzername)@$($config.Domain)" `
                           -Path "OU=$($config.OULernende),$($config.OUPath)" `
                           -Enabled $True `
                           -AccountPassword (ConvertTo-SecureString $config.InitPW -AsPlainText -Force) `
                           -ChangePasswordAtLogon $False `
                           -Title $config.Organisation `
                           -Company $user.Klasse `
                           -Department $user.Klasse2

                $message = "Der Benutzer '$Benutzername' wurde erfolgreich erstellt.`n"
                Write-Log -message $message -logFilePath $config.LogFileActivities
                $successfulUser++
            }
            catch {
                $errorCounter++
                $errorMessage =  "Beim erstellen des Benutzers '$Benutzername)' ist ein Fehler aufgetreten.`n$_"
                Write-Log -message $errorMessage -logFilePath $config.LogFileActivities
            }

            # if any groupname is "" this fails
            try {
                AddToGroup -GroupName "$($user.Klasse)" -SAM "$($Benutzername)"
                AddToGroup -GroupName "$($user.Klasse2)" -SAM "$($Benutzername)"  
            }
            catch {
                $errorCounter++
                $errorMessage = "Fehler beim Hinzufügen des Benutzers '$Benutzername' zu den Gruppen.`n$_"
                Write-Log -message $errorMessage -logFilePath $config.LogFileActivities
            }
            
        }
    }
    $message = "$($successfulUser) Benutzer wurden erstellt, $($skippedUser) erstellungen übersprungen, $($errorCounter) Fehler."
    Write-Host $message -ForegroundColor Blue
    Write-Log -message $message -logFilePath $config.LogFileActivities
}

# Hauptfunktion mit Menue
function Import-ADUsersFromCSV {
    # Funktion UmlauteErsetzen aufrufen (CSV vorbereiten für import)
    UmlauteErsetzen -csvpath $Config.SchuelerCsv

    # Das CSV ohne Umlaute wird importiert
    $csvData = Import-Csv -Path $config.SchuelerCsv -Delimiter ';'

    # Durch Bnutzer loopen
    foreach ($user in $csvData) {
        
        # Benutzernamen abfragen und wenn nötig auf 20 Zeichen reduzieren
        if ($user.Benutzername.Length -gt 19) {
            $user.Benutzername = $user.Benutzername.Substring(0, 19)
        }
    }

    $Continue = $true

    while ($Continue) {

        Write-Host "-----------------------------------------------------"
        Write-Host "Willkommen im Untermenü 1a"
        Write-Host "Hier können Sie AD Benutzer mit dem CSV abgleichen`n"
        Write-Host "1. Nutzer importieren aus CSV"
        Write-Host "2. Nicht auf CSV vorhandene Nutzer löschen"
        Write-Host "3. Zurück ins Hauptmenü`n"

        # User wählt 
        $Wahl = Read-Host "Bitte wählen Sie eine Option (1-3)`n"

        switch ($Wahl) {
            # Nutzer Importieren
            1 {
                Add-UsersFromCsv -csv $csvData
            }
            # Alte Nutzer deaktivieren
            2 {
                Clear-OldUsers -csv $csvData
            }
            #zurück ins Hauptmenü gehen
            3 {
                Write-Host "Zurück ins Hauptmenü"
                $Continue = $false
            }
            Default {
                Write-Host "Ungültige Wahl. Bitte wählen Sie eine gültige Option (1-3).`n" -ForegroundColor Red
            }
        }
    }
}
Import-ADUsersFromCSV