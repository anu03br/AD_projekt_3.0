﻿#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: Bulk Funktion zum importieren von Usern aus einer CSV Liste
# Datum: 16.05.2024
# Version: 0.5
# Changelog
# 16.05.24 V0.5 Skript Erstellt
# 27.05.24 v0.6 -Path variable so gesetzt,dass sie die config cvariablen 'OULernende' und 'OUPath' zum krorrekten -path zusammensetzt
# 27.05.24 v0.7 Unterfunktion erstellt, welche die AD Nutzer welche nicht mehr im CSV sind deaktiviert. Alle Write-Hosts und Comments auf Deutsch geschrieben
# 28.05.24 v0.8 Beim erstellen des ADUsers wird die Klasse in -Company und die Klasse2 in -Department Gespeichert. Diese Können bei den Benutzereigenschaften im Reiter Organisation eingesehen werden
# 28.05.24 v0.8.1 name der unterfunktion in Clear-OldUsers umbenannt
# 03.06.24 v0.8.5 Funktion zum Ersetzen von Umlauten wurde integriert. Skript ist bereit für Testing
# 03.06.24 v0.8.6 Name der Datei in "1a-GetADUsersFromCSV.ps1 umbenannt"
# I still need to do the ad aduser to groups function
# conflict with existing user that doesn't exist
#--------------------------------------------------------------------------------
#Erstellen/*Deaktivieren der AD-Accounts für alle Lernenden des BZT Frauenfeld gemäss CSV File

# funktion textumwandlung importieren
. "$PSScriptRoot\UmlauteErsetzen.ps1" 
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
                
                Write-Host "Der Benutzer '$user' wurde disabled"
                $disabledUserCount++
            }
            catch {
                Write-Error "Beim Deaktivieren des Benutzers '$user' ist ein Fehler aufgetreten."
                Write-Error $_
            }
            
        }
    }
     # Am schluss gib die Totale anzahl deaktivierter User aus (so sehen wir auch wenn kein User deaktiviert wird)
     Write-Host "Anzahl deaktivierter User: $disabledUserCount`n"
}

function AddToGroup {
    # GroupName (Klasse) und SAM (User.SAMAccountName) übergeben
    param (
        [string]$GroupName,
        [string]$SAM
    )
    # Überprüfen, ob die Gruppe existiert
    $existingGroup = Get-ADGroup -Filter {Name -eq $GroupName} -ErrorAction SilentlyContinue

    if ($existingGroup) {
        try {
            # wenn Gruppe existiert, füge den benutzer hinzu
            Add-ADGroupMember -Identity $GroupName -Members $SAM -ErrorAction Stop
            Write-Host "Der Benutzer '$SAM' wurde zur Gruppe '$GroupName' hinzugefügt."
        }
        catch {
            Write-Error "Beim Hinzufügen des Benutzers '$SAM' zur Gruppe '$GroupName' ist ein Fehler aufgetreten."
            Write-Error $_
        }
    }
    else {
        Write-Host "Die Gruppe '$GroupName' existiert nicht, überspringe."
    }
}



# Funktion um neue ADUser zu erstellen (nur wenn nicht vorhanden)
function Add-UsersFromCsv {

    param (
            [array]$csv
        )

    foreach ($user in $csv) {

        # überprüfe, ob der Benutzer bereits im AD existiert
        $existingUser = Get-ADUser -Filter "SamAccountName -eq '$($user.Benutzername)'" -ErrorAction SilentlyContinue
        if ($existingUser) {
            Write-Output "Der Benutzer '$($user.Benutzername)' existiert bereits. Erstellung wird übersprungen.`n"
            continue
        } else {

            # wenn der User noch nicht existiert erstelle einen Neuen Account
            # "@bztf.local" und BZTF Frauenfeld in config varfiablen auslagern $Config.domain = "Bztf.local"
            try {
                New-ADUser -GivenName $user.Vorname `
                           -Surname $user.Name `
                           -Name "$($user.Vorname) $($user.Name)" `
                           -DisplayName "$($user.Vorname) $($user.Name)" `
                           -SamAccountName $user.Benutzername `
                           -UserPrincipalName "$($user.Benutzername)@$($config.Domain)" `
                           -Path "OU=$($config.OULernende),$($config.OUPath)" `
                           -Enabled $True `
                           -AccountPassword (ConvertTo-SecureString $config.InitPW -AsPlainText -Force) `
                           -ChangePasswordAtLogon $False `
                           -Title $config.Organisation `
                           -Company $user.Klasse `
                           -Department $user.Klasse2

                Write-Output "Der Benutzer '$($user.Benutzername)' wurde erfolgreich erstellt.`n"
            }
            catch {
                Write-Error "Beim erstellen des Benutzers '$($user.Benutzername)' ist ein Fehler aufgetreten."
                Write-Error $_
            }
            # if any groupname is "" this fails
            AddToGroup -GroupName "$($user.Klasse)" -SAM "$($user.Benutzername)"
            AddToGroup -GroupName "$($user.Klasse2)" -SAM "$($user.Benutzername)"
        }
    }
}

#Funktion welche alle in einer CSV Liste enthaltenen Nutzer Als Aduser erstellt
function Get-ADUsersFromCSV {

    # Funktion UmlauteErsetzen aufrufen (CSV vorbereiten für import)
    UmlauteErsetzen -csvpath $Config.Test1

    #for testing of debug_umwandlung we use new filepath test2 = schueler-klein2
    $csvData = Import-Csv -Path $config.Test2 -Delimiter ';'

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
            # Neue Gruppen erstellen
            1 {
                Add-UsersFromCsv -csv $csvData
            }
            # Alte Gruppen löschen
            2 {
                Clear-OldUsers -csv $csvData
            }
            #zurück ins Hauptmenü gehen
            3 {
                Write-Host "Zurück ins Hauptmenü"
                $Continue = $false
            }
            Default {
                Write-Host "Ungültige Wahl. Bitte wählen Sie eine gültige Option (1-3).`n"
            }
        }
    }
}
Get-ADUsersFromCSV