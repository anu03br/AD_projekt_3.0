# delete before Shipping
New-ADUser  -GivenName "Andreas" `
            -Surname "Nuessli" `
            -Name "Andreas Nuessli" `
            -DisplayName "Andreas Nuessli" `
            -SamAccountName "andreas.nuessli" `
            -UserPrincipalName "andreas.nuessli@BZTF:local" `
            -Path  "OU=Lernende,OU=BZTF,DC=BZTF,DC=local" `
            -Enabled $True `
            -AccountPassword (ConvertTo-SecureString "bztf.001" -AsPlainText -Force) `
            -ChangePasswordAtLogon $False 
