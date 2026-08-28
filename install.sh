#!/bin/bash
# akdamia One-Line Installer for macOS/Linux
# Usage: bash install.sh
# Downloads akdamia and launches the web app

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                        ║${NC}"
echo -e "${BLUE}║            🎓 akdamia - Installing Now...             ║${NC}"
echo -e "${BLUE}║                                                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker not found${NC}"
    echo -e "${YELLOW}Please install Docker Desktop from: https://www.docker.com/products/docker-desktop${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker found${NC}"

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}✗ Docker Compose not found${NC}"
    echo -e "${YELLOW}Please install Docker Compose${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose found${NC}"
echo ""

# Clone repo if not already in one
if [ ! -f "Dockerfile-compose.yml" ]; then
    echo -e "${BLUE}📥 Cloning akdamia repository...${NC}"
    git clone https://github.com/treesbeats/akdamia.git
    cd akdamia
    git checkout treesbeats-web-app-readme
fi

# Load environment variables
if [ ! -f ".env" ]; then
    echo -e "${BLUE}📝 Creating .env file...${NC}"
    cp .env.example .env 2>/dev/null || echo "SECRET_KEY=django-insecure-change-this-in-production" > .env
fi

echo -e "${BLUE}🐳 Starting Docker containers...${NC}"
docker-compose -f Dockerfile-compose.yml up -d

# Wait for services to be healthy
echo ""
echo -e "${BLUE}⏳ Waiting for services to be healthy...${NC}"

# Wait for web service to be healthy
max_attempts=60
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if docker-compose -f Dockerfile-compose.yml exec -T web curl -f http://localhost:8000/admin/ > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Web service is healthy${NC}"
        break
    fi
    echo "   Waiting for web service... ($((attempt+1))/$max_attempts)"
    sleep 2
    attempt=$((attempt+1))
done

if [ $attempt -eq $max_attempts ]; then
    echo -e "${RED}✗ Web service failed to start${NC}"
    echo "Logs:"
    docker-compose -f Dockerfile-compose.yml logs web | tail -20
    exit 1
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}║          ✅ akdamia is now running!                   ║${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}🌐 Web App:${NC}    http://localhost:8000"
echo -e "${GREEN}📊 Admin:${NC}      http://localhost:8000/admin"
echo -e "${GREEN}🔍 API:${NC}        http://localhost:8000/api/search/?q=test"
echo ""
echo -e "${BLUE}Try searching for:${NC} Einstein, Darwin, Curie, Newton"
echo ""
echo -e "${YELLOW}To stop:${NC} docker-compose -f Dockerfile-compose.yml down"
echo -e "${YELLOW}To view logs:${NC} docker-compose -f Dockerfile-compose.yml logs -f web"
echo ""
