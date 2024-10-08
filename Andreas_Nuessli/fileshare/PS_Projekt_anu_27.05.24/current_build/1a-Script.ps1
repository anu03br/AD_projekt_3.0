﻿#--------------------------------------------------------------------------------
# Autor: Amar Vejapi
# Funktion des Skripts: Bulk Funktion zum importieren von Usern aus einer CSV Liste
# Datum: 16.05.2024
# Version: 0.5
# Changelog
# 16.05.24 V0.5 Skript Erstellt
# 27.05.24 v0.6 -Path variable so gesetzt,dass sie die config cvariablen 'OULernende' und 'OUPath' zum krorrekten -path zusammensetzt
# 27.05.24 v0.7 Unterfunktion erstellt, welche die AD Nutzer welche nicht mehr im CSV sind deaktiviert. Alle Write-Hosts und Comments auf Deutsch geschrieben
# löschfunktion disabled ALLE Accounts auch admin
# klasse und klasse 2 werden noch nicht hinzugefügt . we have no extensionattibutes to work with either find another wayy or make a skript to create them so teach can use them
# namen mit sonderzeichen (ä,ü,ö) werden im AD nicht korrkt angezeigt, evtl konvertieren
#--------------------------------------------------------------------------------
#Erstellen/*Deaktivieren der AD-Accounts für alle Lernenden des BZT Frauenfeld gemäss CSV File


# config file mit relativen pfad laden
. ".\config.ps1"

#funktion, welche die User mit der CSV vergleicht und alle Benutzer deaktiviert welche Im CSV Nicht mehr vorhanden sind
function Funktion-1a.5 {


    # CSV-Datei importieren
    $csvData = Import-Csv -Path $Config.SchuelerCsv -Delimiter ';'

    # Alle Benutzernamen aus dem CSV lesen
    $csvUserNames = $csvData | ForEach-Object { $_.Benutzername } -ErrorAction Stop

    # Gibt eine liste mit den SamAccountNames alles ADUser in "Lernende" aus
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
     # Am schluss gib die Totale anzahl deaktivierter User aus (so sehen wir auch wenn keon User deaktiviert wird)
     Write-Host "Anzahl deaktivierter User: $disabledUserCount"
}

#Funktion welche alle in einer CSV Liste enthaltenen Nutzer Als Aduser erstellt
function Funktion-1a {
    # CSV-Datei importieren
    $csvData = Import-Csv -Path $config.SchuelerCsv -Delimiter ';'


    foreach ($user in $csvData) {

        # überprüfe, ob der Benutzer bereits im AD existiert
        $existingUser = Get-ADUser -Filter "SamAccountName -eq '$($user.Benutzername)'" -ErrorAction SilentlyContinue
        if ($existingUser) {
            Write-Output "Der Benutzer '$($user.Benutzername)' existiert bereits. Erstellung wird übersprungen.`n"
            continue
        } else {

            # wenn der User noch nicht existiert erstelle einen Neuen Account
            try {
                New-ADUser -GivenName $user.Vorname `
                        -Surname $user.Nachname `
                        -Name "$($user.Vorname) $($user.Nachname)" `
                        -SamAccountName $user.Benutzername `
                        -UserPrincipalName "$($user.Benutzername)@bztf.local" `
                        -Path "OU=$($config.OULernende),$($config.OUPath)" `
                        -Enabled $True `
                        -AccountPassword (ConvertTo-SecureString $config.InitPW -AsPlainText -Force) `
                        -ChangePasswordAtLogon $False

                Write-Output "Der Benutzer '$($user.Benutzername)' wurde erfolgreich erstellt.`n"
            }
            catch {
                Write-Error "Beim erstellen des Benutzers '$($user.Benutzername)' ist ein Fehler aufgetreten."
                Write-Error $_
            }

            try {
                # set extension attributes
                Set-ADUser -Identity $user.Benutzername `
                -Add @{
                    extensionAttribute1 = $user.Klasse                    
                    extensionAttribute2 = $user.Klasse2
                }
                Write-Host "Der Benutzer '$($user.Benutzername)' hat Klasse $user.Klasse"
                Write-Host "Der Benutzer '$($user.Benutzername)' hat Klasse2 $user.Klasse2"
            }
            catch {
                Write-Error "Beim aufzeichnend der Klassen des Benutzers '$($user.Benutzername)' ist ein Fehler aufgetreten."
                Write-Error $_
            }

        }
    }
    Funktion-1a.5
}

Funktion-1a

Get-ADUser -Identity 'jan.geisser' -Properties *