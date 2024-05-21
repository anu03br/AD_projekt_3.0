#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: Abgleichen der aktiven Userbase mit einem CSV. User welche nicht auf der Liste sind werden inaktiviert
# der Zeitpunkt der inaktivierung wird in der variable ($DisableDate) gespeichert, welche (extensionAttribute3) entspricht
# Datum: 16.05.2024
# Version: 0.5
# Changelog
# 16.05.24 V0.5 Skript Erstellt
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

# Define the path for the CSV log file
$LogfilePath = "C:\Path\To\Your\Users.csv" # this could be something like "$PSScriptRoot\logfiles\logfilename"

# Function to compare userbase to a csv and disable any user not in the csv
function Check-Users {
    
    # Get the current date and format to string
    $currentDate = Get-Date -Format "yyyy-MM-dd"

    # Import the CSV file and get the list of current users
    $currentUsers = Import-Csv -Path $CsvFilePath -Delimiter ';' | Select-Object -ExpandProperty SamAccountName 

    # Get all users from Active Directory
    $allADUsers = Get-ADUser -Filter * -Properties SamAccountName, Enabled, extensionAttribute1

    # Disable users not in the CSV and set the disable date
    foreach ($user in $allADUsers) {
        # If the current user is no longer in the CSV
        if ($currentUsers -notcontains $user.SamAccountName) {
            # Check if the user is already disabled (we don't want to set the date then)
            if ($user.Enabled) {
                try {
                    # Disable the user
                    Disable-ADAccount -Identity $user.SamAccountName
                    # Set the disable date in extensionAttribute1
                    Set-ADUser -Identity $user.SamAccountName -Replace @{extensionAttribute1 = $currentDate}
                } catch {
                    Write-Error "Failed to disable user $($user.SamAccountName) and set disable date."
                    Write-Error $_
                }
            }
        }
    }
}

# Function call
Check-Users
