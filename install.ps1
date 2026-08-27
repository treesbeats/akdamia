# akdamia One-Line Installer for Windows PowerShell
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1
# Downloads akdamia and launches the web app in seconds

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                        ║" -ForegroundColor Cyan
Write-Host "║            🎓 akdamia - Installing Now...             ║" -ForegroundColor Cyan
Write-Host "║                                                        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is installed
try {
    docker --version | Out-Null
    Write-Host "✓ Docker found" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Docker not found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please install Docker Desktop:" -ForegroundColor Yellow
    Write-Host "https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Then run this script again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if Docker Compose is installed
try {
    docker-compose --version | Out-Null
    Write-Host "✓ Docker Compose found" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker Compose not found" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Check if in repo
if (-not (Test-Path "Dockerfile-compose.yml")) {
    Write-Host "📥 Cloning akdamia repository..." -ForegroundColor Cyan
    git clone https://github.com/treesbeats/akdamia.git
    Set-Location akdamia
    git checkout treesbeats-web-app-readme
}

Write-Host "🐳 Starting Docker containers..." -ForegroundColor Cyan
docker-compose -f Dockerfile-compose.yml up -d

Write-Host ""
Write-Host "⏳ Waiting for services to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

Write-Host "🔧 Running database migrations..." -ForegroundColor Cyan
docker-compose exec -T web python manage.py migrate

Write-Host "📚 Loading sample data..." -ForegroundColor Cyan
docker-compose exec -T web python manage.py load_sample

Clear-Host

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                        ║" -ForegroundColor Green
Write-Host "║          ✅ akdamia is now running!                   ║" -ForegroundColor Green
Write-Host "║                                                        ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Web App:    http://localhost:8000" -ForegroundColor Green
Write-Host "📊 Admin:      http://localhost:8000/admin" -ForegroundColor Green
Write-Host "🔍 API:        http://localhost:8000/api/search/?q=test" -ForegroundColor Green
Write-Host ""
Write-Host "Try searching for: Einstein, Darwin, Curie, Newton" -ForegroundColor Cyan
Write-Host ""
Write-Host "⏹️  To stop: docker-compose -f Dockerfile-compose.yml down" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to continue"
