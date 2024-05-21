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

        # User properties
        $Name = "$($user.Vorname) $($user.Name)"
        $GivenName = $user.Vorname
        $Surname = $user.Name
        $SamAccountName = $user.Benutzername
        $UserPrincipalName = "$SamAccountName@bztf.local" # username@domain.local
        #$OUPath = "CN=Users,DC=bztf,DC=local"  # this is not needed because we get OUPAth from config
        $Klasse = $user.Klasse
        $Klasse2 = $user.Klasse2
        $Enabled = $true

        $existingUser = Get-ADUser -Filter {SamAccountName -eq $user.Benutzername} -ErrorAction SilentlyContinue
        if ($existingUser) {
            Write-Output "User '$SamAccountName' already exists. Skipping creation.`n"
            continue
        } else {

            # Debug output
            Write-Output "Creating user: '$Name'"
            Write-Output "Given Name: '$GivenName'"
            Write-Output "Surname: '$Surname'"
            Write-Output "SamAccountName: '$SamAccountName'"
            Write-Output "UserPrincipalName: '$UserPrincipalName'"
            Write-Output "OUPath: '$OUPath'"
            Write-Output "Enabled: '$Enabled'`n"

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

                Write-Output "User '$SamAccountName' created successfully.`n"
            }
            catch {
                Write-Error "An error occurred while creating user '$SamAccountName'"
                Write-Error $_
            }

            
        }
    }

    # Alle nicht mehr in der CSV-Datei vorhandenen Benutzer deaktivieren
    #$csvUserNames = $csvData | ForEach-Object {$_.SamAccountName} -ErrorAction SilentlyContinue
    #$ouDN = (Get-ADOrganizationalUnit -Filter {Name -eq "BZTF"}).DistinguishedName
    #Get-ADUser -Filter {SamAccountName -in $csvUserNames} -SearchBase $ouDN | Disable-ADAccount
}

Funktion-1a