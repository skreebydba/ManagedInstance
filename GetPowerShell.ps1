Install-Module PowerShellGet -Force -RequiredVersion 1.6.5
Install-Module -Name AzureRM -AllowClobber -Force
Install-Module -Name AzureRM.Sql -AllowPrerelease -Force

Import-PackageProvider -Name PowerShellGet -Force -RequiredVersion 1.6.5

Get-AzureRmSqlManagedInstance  
New-AzureRmSqlManagedInstance  
Remove-AzureRmSqlManagedInstance  
Set-AzureRmSqlManagedInstance  
Update-AzureRmSqlManagedInstance  
Get-AzureRmSqlManagedDatabase  
New-AzureRmSqlManagedDatabase  
Remove-AzureRmSqlManagedDatabase  
Restore-AzureRmSqlManagedDatabase  

Install-Module -Name AzureRM.Sql -RequiredVersion 4.5.0-preview -AllowPrerelease
