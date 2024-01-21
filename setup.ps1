$ErrorActionPreference="Stop"
Set-ExecutionPolicy Bypass -Scope Process -Force

iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install dotnet-sdk -y
choco install git.install -y