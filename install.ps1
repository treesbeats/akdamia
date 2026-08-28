# akdamia One-Line Installer for Windows PowerShell
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1

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
    Write-Host "✗ Docker not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Docker Desktop:" -ForegroundColor Yellow
    Write-Host "https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    Write-Host ""
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

# Load environment variables
if (-not (Test-Path ".env")) {
    Write-Host "📝 Creating .env file..." -ForegroundColor Cyan
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
    } else {
        Add-Content ".env" "SECRET_KEY=django-insecure-change-this-in-production"
    }
}

Write-Host "🐳 Starting Docker containers..." -ForegroundColor Cyan
docker-compose -f Dockerfile-compose.yml up -d

Write-Host ""
Write-Host "⏳ Waiting for services to be healthy..." -ForegroundColor Cyan

# Wait for web service to be healthy
$maxAttempts = 60
$attempt = 0
$healthy = $false

while ($attempt -lt $maxAttempts) {
    try {
        $response = docker-compose -f Dockerfile-compose.yml exec -T web curl -f http://localhost:8000/admin/ 2>$null
        if ($response) {
            Write-Host "✓ Web service is healthy" -ForegroundColor Green
            $healthy = $true
            break
        }
    } catch {
        # Silently continue
    }
    
    Write-Host "   Waiting for web service... ($($attempt+1)/$maxAttempts)" -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    $attempt++
}

if (-not $healthy) {
    Write-Host "✗ Web service failed to start" -ForegroundColor Red
    Write-Host "Logs:" -ForegroundColor Yellow
    docker-compose -f Dockerfile-compose.yml logs web | Select-Object -Last 20
    Read-Host "Press Enter to exit"
    exit 1
}

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
Write-Host "📋 To view logs: docker-compose -f Dockerfile-compose.yml logs -f web" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to continue"
