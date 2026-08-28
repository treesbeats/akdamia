# Installation Guide

## Prerequisites

- **Docker Desktop** (recommended) — [Download](https://www.docker.com/products/docker-desktop)
- **Git** — [Download](https://git-scm.com)

## Quick Start (One-Liner)

### macOS/Linux
\\\ash
bash <(curl -s https://raw.githubusercontent.com/treesbeats/akdamia/treesbeats-web-app-readme/install.sh)
\\\

### Windows PowerShell
\\\powershell
powershell -ExecutionPolicy Bypass -Command "& {iwr https://raw.githubusercontent.com/treesbeats/akdamia/treesbeats-web-app-readme/install.ps1 | iex}"
\\\

### Windows Command Prompt
\\\cmd
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/treesbeats/akdamia/treesbeats-web-app-readme/install.ps1 -OutFile install.ps1; powershell -ExecutionPolicy Bypass -File install.ps1"
\\\

**Time to ready:** 2-5 minutes | **Requirements:** Docker Desktop only

---

## Docker Compose Setup (Manual)

\\\ash
# Clone and setup
git clone https://github.com/treesbeats/akdamia.git
cd akdamia
git checkout treesbeats-web-app-readme

# Start services
docker-compose -f Dockerfile-compose.yml up -d

# Watch for readiness
docker-compose -f Dockerfile-compose.yml logs -f web
\\\

Open http://localhost:8000

---

## Local Python Setup (Development)

\\\ash
# Prerequisites: Python 3.11+, PostgreSQL, Elasticsearch

# Setup
git clone https://github.com/treesbeats/akdamia.git
cd akdamia
python -m venv .venv
source .venv/bin/activate
pip install -r akdamia_requirements.txt

# Configure
cp .env.example .env

# Database
python manage.py migrate
python manage.py createsuperuser
python manage.py load_sample

# Run
python manage.py runserver
\\\

---

## Verify Installation

- **Web UI:** http://localhost:8000
- **Admin:** http://localhost:8000/admin
- **API:** http://localhost:8000/api/search/?q=test
- **Logs:** \docker-compose logs -f web\

---

## Common Issues

| Issue | Solution |
|-------|----------|
| Port 8000 in use | Change port in docker-compose.yml |
| Services not starting | Run \docker-compose logs web\ to debug |
| Database not ready | Wait 10-15 seconds and refresh |
| Static files missing | Run \python manage.py collectstatic --noinput\ |

---

For production deployment, see [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
