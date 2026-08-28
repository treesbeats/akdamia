@echo off
REM akdamia One-Line Installer for Windows
REM Usage: install.bat

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
    echo ✗ Docker not found
    echo.
    echo Please install Docker Desktop:
    echo https://www.docker.com/products/docker-desktop
    echo.
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

REM Create .env if it doesn't exist
if not exist ".env" (
    echo 📝 Creating .env file...
    if exist ".env.example" (
        copy .env.example .env
    ) else (
        echo SECRET_KEY=django-insecure-change-this-in-production > .env
    )
)

echo 🐳 Starting Docker containers...
docker-compose -f Dockerfile-compose.yml up -d

echo.
echo ⏳ Waiting for services to be healthy...

setlocal enabledelayedexpansion
set "maxAttempts=60"
set "attempt=0"

:wait_loop
if !attempt! geq !maxAttempts! (
    echo.
    echo ✗ Web service failed to start
    docker-compose -f Dockerfile-compose.yml logs web | findstr /V "^$"
    pause
    exit /b 1
)

docker-compose -f Dockerfile-compose.yml exec -T web curl -f http://localhost:8000/admin/ >nul 2>&1
if errorlevel 1 (
    echo    Waiting for web service... (!attempt!of !maxAttempts!)
    timeout /t 2 /nobreak >nul
    set /A attempt=!attempt!+1
    goto wait_loop
)

echo ✓ Web service is healthy

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
echo 📋 To view logs: docker-compose -f Dockerfile-compose.yml logs -f web
echo.
pause
