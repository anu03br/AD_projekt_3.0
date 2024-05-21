#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: Bulk Funktion zum importieren von Usern aus einer CSV Liste
# Datum: 16.05.2024
# Version: 0.5
# Changelog
# 16.05.24 V0.5 Skript Erstellt
# 17.05.24 v0.6 Skript läuft ohne fehler
# klasse und klasse 2 werden noch nicht hinzugefügt
# namen mit sonderzeichen (ä,ü,ö) werden im AD nicht korrkt angezeigt, evtl konvertieren
#--------------------------------------------------------------------------------


# Import Active Directory Module
try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to import Active Directory module. Ensure it is installed and available."
    return
}

# Load the configuration file from the same directory as the script
. ".\config.ps1"

# Access configuration settings
$CsvFilePath = $config.SchuelerCsv
$InitPassword = $config.InitPw
$OUPath = $config.OUPath
$OULernende = $config.OULernende
$OUKlasse = $config.OUKlasse
$LogFileUser = $config.LogFileUser
$LogFileGroup = $config.LogFileGroup
$ClassFolder = $config.ClassFolder
$Klasse = $config.Klasse
$Klasse1 = $config.Klasse2
$DisableDate =  $config.DisableDate

# function to bulk import users from the CSV provided
function Bulk-Import {
    
    # Import the CSV file
    $users = Import-Csv -Path $CsvFilePath -Delimiter ';'

    # Convert password to secure string
    $securePassword = ConvertTo-SecureString $InitPassword -AsPlainText -Force

    # Iterate over users and create them
    foreach ($user in $users) {
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
        

        # Check if user already exists
        $existingUser = Get-ADUser -Filter {SamAccountName -eq $SamAccountName} -ErrorAction SilentlyContinue

        #skip user if exists
        if ($existingUser) {
            Write-Output "User '$SamAccountName' already exists. Skipping creation.`n"
            continue
        }
        else {
            # Debug output
            Write-Output "Creating user: '$Name'"
            Write-Output "Given Name: '$GivenName'"
            Write-Output "Surname: '$Surname'"
            Write-Output "SamAccountName: '$SamAccountName'"
            Write-Output "UserPrincipalName: '$UserPrincipalName'"
            Write-Output "OUPath: '$OUPath'"
            Write-Output "Enabled: '$Enabled'`n" 
        }

        # Create user
        try {
            New-ADUser -Name $Name `
                       -GivenName $GivenName `
                       -Surname $Surname `
                       -SamAccountName $SamAccountName `
                       -UserPrincipalName $UserPrincipalName `
                       -Path $OUPath `
                       -AccountPassword $securePassword `
                       -Enabled $Enabled

            Write-Output "User '$SamAccountName' created successfully.`n"
        }
        catch {
            Write-Error "An error occurred while creating user '$SamAccountName'"
            Write-Error $_
        }

        # add user to Klasse
        try {
            # Search for a group with the same name as Klasse (e.g., INF25A)
            $groupExists = Get-ADGroup -Filter {Name -eq $Klasse} -ErrorAction Stop
            
            if ($groupExists) {
                try {
                    Add-ADGroupMember -Identity $Klasse -Members $SamAccountName
                    Write-Output "User '$SamAccountName' added to group '$Klasse' successfully.`n"
                }
                catch {
                    Write-Error "An error occurred while adding user '$SamAccountName' to group '$Klasse'"
                    Write-Error $_
                }
            }
        }
        catch {
            Write-Error "Group '$Klasse' does not exist. User '$SamAccountName' was not added to the group."
            Write-Error $_
        }
    }   
}

# Call the function to create users from CSV
Bulk-Import


