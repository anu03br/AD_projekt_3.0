#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: Abfrage welche Benutzer länger als ($DaysThreshold) Tage inaktiv waren. Diese werden gelöscht
# Wird kein Übergabeparameter mitgegeben, dann wird der Standard verwendet ($DaysThreshold = 7) 
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

# Function to delete AD users that have been disabled. number of day is a param, 7 is default
function Remove-DisabledADUsers {
    param (
        [int]$DaysThreshold = 7
    )

    # Get the current date
    $currentDate = Get-Date

    # Get all users from Active Directory
    $allADUsers = Get-ADUser -Filter * -Properties SamAccountName, Enabled, extensionAttribute1

    foreach ($user in $allADUsers) {
        # Check if the user is disabled
        if (-not $user.Enabled) {
            # Get the disable date
            $disableDate = [datetime]::ParseExact($user.extensionAttribute1, "yyyy-MM-dd", $null) -ErrorAction SilentlyContinue

            # Check if the disable date is valid and the user has been disabled for more than the threshold
            if ($disableDate -ne $null -and ($currentDate - $disableDate).Days -gt $DaysThreshold) {
                try {
                    # Delete the user
                    Remove-ADUser -Identity $user.SamAccountName -Confirm:$false
                } catch {
                    Write-Error "Failed to remove user $($user.SamAccountName)."
                    Write-Error $_
                }
            }
        }
    }  
}

# Call the function without specifying DaysThreshold (will use default value of 7)
Remove-DisabledADUsers 
