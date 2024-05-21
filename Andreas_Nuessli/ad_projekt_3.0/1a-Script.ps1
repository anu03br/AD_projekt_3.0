#--------------------------------------------------------------------------------
# Autor: Amar Vejapi
# Funktion des Skripts: Bulk Funktion zum importieren von Usern aus einer CSV Liste
# Datum: 16.05.2024
# Version: 0.5
# Changelog
# 16.05.24 V0.5 Skript Erstellt
# 21.05.24 v0.6 
# löschfunktion disabled ALLE Accounts auch admin
# klasse und klasse 2 werden noch nicht hinzugefügt
# namen mit sonderzeichen (ä,ü,ö) werden im AD nicht korrkt angezeigt, evtl konvertieren
#--------------------------------------------------------------------------------
#Erstellen/*Deaktivieren der AD-Accounts für alle Lernenden des BZT Frauenfeld gemäss CSV File


# config file mit relativen pfad laden
. ".\config.ps1"

function Funktion-1a {
    # CSV-Datei importieren
    $csvData = Import-Csv -Path $config.SchuelerCsv -Delimiter ';'

    foreach ($user in $csvData) {


        $existingUser = Get-ADUser -Filter "SamAccountName -eq '$($user.Benutzername)'" -ErrorAction SilentlyContinue
        if ($existingUser) {
            Write-Output "User '$($user.Benutzername)' already exists. Skipping creation.`n"
            continue
        } else {


            try {
                New-ADUser -GivenName $user.Vorname `
                        -Surname $user.Nachname `
                        -Name "$($user.Vorname) $($user.Nachname)" `
                        -SamAccountName $user.Benutzername `
                        -UserPrincipalName "$($user.Benutzername)@bztf.local" `
                        -Path $config.OUPath `
                        -Enabled $True `
                        -AccountPassword (ConvertTo-SecureString $config.InitPW -AsPlainText -Force) `
                        -ChangePasswordAtLogon $False

                Write-Output "User '$($user.Benutzername)' created successfully.`n"
            }
            catch {
                Write-Error "An error occurred while creating user '$($user.Benutzername)'"
                Write-Error $_
            }

            
        }
    }

    # debugging
    try {
        $csvUserNames = $csvData | ForEach-Object {$_.SamAccountName} -ErrorAction Stop  
    }
    catch {
        Write-Error "An error occurred while ghetting csvUserNames'"
        Write-Error $_
    }
    try {
        $ouDN = (Get-ADOrganizationalUnit -Filter {Name -eq "BZTF"}).DistinguishedName
    }
    catch {
        Write-Error "An error occurred while creating user '$($user.Benutzername)'"
        Write-Error $_
    }

    # Alle nicht mehr in der CSV-Datei vorhandenen Benutzer deaktivieren
    #$csvUserNames = $csvData | ForEach-Object {$_.SamAccountName} -ErrorAction Stop 
    #$ouDN = (Get-ADOrganizationalUnit -Filter {Name -eq "BZTF"}).DistinguishedName
    #Get-ADUser -Filter {SamAccountName -in $csvUserNames} -SearchBase $config.OUPath | Disable-ADAccount
}

Funktion-1a