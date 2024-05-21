#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: Bulk Funktion zum erstellen von gruppen aus einer CSV Liste
# Datum: 17.05.2024
# Version: 0.6
# Changelog
# 17.05.24 V0.5 Skript Erstellt
# 17.05.24 V0.6 Created sub function Create-ADGroup to be used in Bulk-CreateAdGroup
# 17.05.24 Added OUCheck as separate funtion 
#--------------------------------------------------------------------------------

# Import Active Directory Module
try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to import Active Directory module. Ensure it is installed and available."
    return
}

# Load the configuration file from the same directory as the script
. "$PSScriptRoot\config.ps1"

# Access configuration settings
$CsvFilePath = $config.SchuelerCsv
# $OUPath = $config.OUPath
$OUPath = "OU=BZTF,DC=bztf,DC=local"
#$OUPath = "CN=Users,DC=bztf,DC=local"

#notes # enable deletion of OU
#Set-ADOrganizationalUnit -Identity "OU=BZTF,DC=bztf,DC=local" -ProtectedFromAccidentalDeletion $false

# Function to create an AD group
function Create-ADGroup($GroupName) {

    # Check if group already exists
    $existingGroup = Get-ADGroup -Filter {Name -eq $GroupName} -ErrorAction SilentlyContinue

    # Skip group if it exists
    if ($existingGroup) {
        Write-Output "Group '$GroupName' already exists. Skipping creation.`n"
        return
    } 
    else {
        # Debug output
        Write-Output "Creating group: '$GroupName'"

        # create the group
        try {
            New-ADGroup -Name "$GroupName" `
                        -SamAccountName $GroupName `
                        -GroupCategory Security `
                        -GroupScope Global `
                        -DisplayName "$GroupName" `
                        -Path $OUPath `
                        -Description "Schueler der Gruppe $GroupName"
            Write-Output "Group '$GroupName' created successfully.`n"
        }
        catch {
            Write-Error "An error occurred while creating group '$GroupName'"
            Write-Error $_
        }
    }   
}

# Function to bulk create AD groups from the CSV provided
function Bulk-CreateADGroup {

    #run OUCheck to check existance of BZTF OU
    .\OUCheck 

    # Import the CSV file
    $groups = Import-Csv -Path $CsvFilePath -Delimiter ';'

    # Iterate over groups and create them
    foreach ($group in $groups) {
        $Klasse = $group.Klasse
        $Klasse2 = $group.Klasse2

        # Create groups for both Klasse and Klasse2
        if ($Klasse) {
            Create-ADGroup -GroupName $Klasse
        }
        if ($Klasse2) {
            Create-ADGroup -GroupName $Klasse2
        }
    }
}

# Call the function to create groups from CSV
Bulk-CreateADGroup
