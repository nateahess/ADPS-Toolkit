<#

PASSWORD GENERATOR 

#> 

function Generate-Password { 

    $length = 10 
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    $password = -join ((1..$length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)]}

    return $password

}

Write-Host " "
Write-Host "PASSWORD GENERATOR"
Write-Host " "

$password = Generate-Password
Write-Host " "
Write-Host "Password: $password" -ForegroundColor Green
Write-Host " "

pause 