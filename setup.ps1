$ErrorActionPreference="Stop"
./dotnet_install.ps1

Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install git.install -y