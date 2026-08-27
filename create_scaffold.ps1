# PowerShell scaffold script for akdamia
# Runs locally to create a Django project skeleton and install requirements

param()

Write-Host "Creating Python venv..."
python -m venv .venv
.\.venv\Scripts\Activate.ps1
Write-Host "Upgrading pip and installing requirements..."
python -m pip install --upgrade pip
if (Test-Path akdamia) {
  Write-Host "akdamia folder already exists — aborting to avoid overwrite." -ForegroundColor Yellow
  exit 1
}

Copy-Item -Path .\akdamia_requirements.txt -Destination requirements.txt -Force
pip install -r requirements.txt

Write-Host "Starting Django project 'akdamia'..."
django-admin startproject akdamia .\akdamia
cd akdamia
python manage.py startapp search
cd ..

Write-Host "Created project and 'search' app. Please add 'search' to INSTALLED_APPS and configure Postgres/Elasticsearch settings as needed."
Write-Host "See README for next steps."

