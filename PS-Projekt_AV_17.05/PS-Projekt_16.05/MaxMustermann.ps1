New-ADUser -GivenName "Max" `
           -Surname "Mustermann" `
           -Name "Max Mustermann" `
           -SamAccountName "mmustermann" `
           -Path "OU=BZTF,DC=bztf,DC=local" `
           -Enabled $True `
           -AccountPassword (ConvertTo-SecureString "bztf.001" -AsPlainText -Force) `
           -ChangePasswordAtLogon $False