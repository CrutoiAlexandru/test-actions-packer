$ErrorActionPreference = "Stop"

New-Item -Path C:\App -ItemType Directory -Force

git clone https://github.com/CrutoiAlexandru/test-actions-dotnet C:\App
 
cd C:\App

dotnet build