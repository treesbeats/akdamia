@echo off
REM akdamia One-Line Installer for Windows
REM Usage: install.bat
REM Downloads akdamia and launches the web app in seconds

setlocal enabledelayedexpansion

cls
echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║                                                        ║
echo ║            🎓 akdamia - Installing Now...             ║
echo ║                                                        ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo ⚠️  Docker not found!
    echo.
    echo Please install Docker Desktop:
    echo https://www.docker.com/products/docker-desktop
    echo.
    echo Then run this script again.
    pause
    exit /b 1
)

echo ✓ Docker found
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ✗ Docker Compose not found
    pause
    exit /b 1
)

echo ✓ Docker Compose found
echo.

REM Check if in repo
if not exist "Dockerfile-compose.yml" (
    echo 📥 Cloning akdamia repository...
    git clone https://github.com/treesbeats/akdamia.git
    cd akdamia
    git checkout treesbeats-web-app-readme
)

echo 🐳 Starting Docker containers...
docker-compose -f Dockerfile-compose.yml up -d

echo.
echo ⏳ Waiting for services to start...
timeout /t 10 /nobreak

echo 🔧 Running database migrations...
docker-compose exec -T web python manage.py migrate

echo 📚 Loading sample data...
docker-compose exec -T web python manage.py load_sample

cls
echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║                                                        ║
echo ║          ✅ akdamia is now running!                   ║
echo ║                                                        ║
echo ╚════════════════════════════════════════════════════════╝
echo.
echo 🌐 Web App:    http://localhost:8000
echo 📊 Admin:      http://localhost:8000/admin
echo 🔍 API:        http://localhost:8000/api/search/?q=test
echo.
echo Try searching for: Einstein, Darwin, Curie, Newton
echo.
echo ⏹️  To stop: docker-compose -f Dockerfile-compose.yml down
echo.
pause
