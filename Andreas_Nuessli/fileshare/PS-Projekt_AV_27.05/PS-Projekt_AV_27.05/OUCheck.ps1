#--------------------------------------------------------------------------------
# Autor: Andreas Nüssli
# Funktion des Skripts: Fragt ab, ob die OU "BZTF" existiert. wenn sie nicht existier, wird sie erstellt
# Datum: 17.05.2024
# Version: 1.0
# Changelog
# 17.05.24 V0.5 Skript Erstellt und getestet
#--------------------------------------------------------------------------------
    
    # Function to check if OU BZTF exists
    function OUCheck {
        try {
            $BZTFExists = Get-ADOrganizationalUnit -Filter {Name -eq "BZTF"} -SearchBase "DC=bztf,DC=local" -ErrorAction Stop

            if (-not $BZTFExists) {
                # Create the OU if it does not exist
                New-ADOrganizationalUnit -Name "BZTF" -Path "DC=bztf,DC=local" -ProtectedFromAccidentalDeletion $false #this works correctly
                Write-Host "`mOU 'BZTF' created successfully."
                Write-Host "-------------------------------------------------------`n"
            } 
            else {
                Write-Host "`nOU 'BZTF' already exists."
                Write-Host "-------------------------------------------------------`n"
            }
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            # Handle the case where the OU does not exist
            New-ADOrganizationalUnit -Name "BZTF" -Path "DC=bztf,DC=local"
            Write-Host "OU 'BZTF' created successfully."
            return
        }
        catch {
            # Handle any other exceptions
            Write-Host "An error occurred: $_"
            return
        }    
    }

    # call the function
    OUCheck
    