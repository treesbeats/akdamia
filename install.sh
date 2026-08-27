#!/bin/bash
# akdamia One-Line Installer
# Usage: bash install.sh
# Downloads akdamia and launches the web app in seconds

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                        ║${NC}"
echo -e "${BLUE}║            🎓 akdamia - Installing Now...             ║${NC}"
echo -e "${BLUE}║                                                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker not found. Installing Docker Desktop...${NC}"
    echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
    echo "Then run: bash install.sh"
    exit 1
fi

echo -e "${GREEN}✓ Docker found${NC}"

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker Compose not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker Compose found${NC}"
echo ""

# Clone repo if not in one
if [ ! -f "Dockerfile-compose.yml" ]; then
    echo -e "${BLUE}📥 Cloning akdamia repository...${NC}"
    git clone https://github.com/treesbeats/akdamia.git
    cd akdamia
    git checkout treesbeats-web-app-readme
fi

echo -e "${BLUE}🐳 Starting Docker containers...${NC}"
docker-compose -f Dockerfile-compose.yml up -d

echo ""
echo -e "${BLUE}⏳ Waiting for services to start...${NC}"
sleep 10

echo -e "${BLUE}🔧 Running database migrations...${NC}"
docker-compose exec -T web python manage.py migrate

echo -e "${BLUE}📚 Loading sample data...${NC}"
docker-compose exec -T web python manage.py load_sample

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
echo ""
