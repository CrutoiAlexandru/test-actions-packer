$ErrorActionPreference="Stop"
Set-ExecutionPolicy Bypass -Scope Process -Force

.\dotnet_install.ps1

iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install git.install -y