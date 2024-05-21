# Import Active Directory Module
try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to import Active Directory module. Ensure it is installed and available."
    return
}

# Reset password function
function Reset-Password {

    $Password = 'Sonne-123$'

    #input desited user SAN
    $Username = Read-Host "Input SamAccountName (shorthand) of the User"

    # Retrieve the user object from Active Directory
    $User = Get-ADUser -Filter {SamAccountName -eq $Username}

    if ($User) {
        Write Host "User Found"
        try {
            # Reset the password
            Set-ADAccountPassword -Identity $User -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)

            # Enable the account in case it is disabled
            Enable-ADAccount -Identity $User

            # Force the user to change the password at next logon
            Set-ADUser -Identity $User -ChangePasswordAtLogon $true

            Write-Host "Password reset successfully for user '$Username'. The new password is '$Password'"
        }
        catch {
            Write-Error "An error occurred while resetting the password of user '$Username'"
            Write-Error $_
        }
    } else {
        Write-Error "User '$Username' not found"
    }
}

# Call the function to reset a user's password
Reset-Password
