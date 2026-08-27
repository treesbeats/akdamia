# 🎓 akdamia - One-Liner Installation Guide

Install and run akdamia in seconds with a single command. Pick your operating system:

---

## 🍎 macOS

**Copy and paste:**
```bash
bash <(curl -s https://raw.githubusercontent.com/treesbeats/akdamia/treesbeats-web-app-readme/install.sh)
```

**That's it!** Your app will be live at http://localhost:8000 in ~30 seconds.

---

## 🐧 Linux

**Copy and paste:**
```bash
bash <(curl -s https://raw.githubusercontent.com/treesbeats/akdamia/treesbeats-web-app-readme/install.sh)
```

**That's it!** Your app will be live at http://localhost:8000 in ~30 seconds.

---

## 🪟 Windows

### Option 1: PowerShell (Recommended)

**Copy and paste into PowerShell:**
```powershell
powershell -ExecutionPolicy Bypass -Command "& {iwr https://raw.githubusercontent.com/treesbeats/akdamia/treesbeats-web-app-readme/install.ps1 | iex}"
```

**That's it!** Your app will be live at http://localhost:8000 in ~30 seconds.

### Option 2: Command Prompt

**Copy and paste into Command Prompt:**
```cmd
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/treesbeats/akdamia/treesbeats-web-app-readme/install.ps1 -OutFile install.ps1; powershell -ExecutionPolicy Bypass -File install.ps1"
```

**That's it!** Your app will be live at http://localhost:8000 in ~30 seconds.

---

## ✅ What the Installer Does

The one-liner script automatically:

1. **Checks Prerequisites**
   - ✓ Verifies Docker is installed
   - ✓ Verifies Docker Compose is installed

2. **Sets Up Application**
   - ✓ Clones the akdamia repository
   - ✓ Checks out the production branch

3. **Launches Services**
   - ✓ Starts PostgreSQL database
   - ✓ Starts Elasticsearch search engine
   - ✓ Starts Django web application
   - ✓ Starts Nginx reverse proxy

4. **Initializes Database**
   - ✓ Runs all migrations
   - ✓ Loads 500+ sample citations
   - ✓ Sets up search indexes

5. **Displays URLs**
   - ✓ Shows web app URL
   - ✓ Shows admin panel URL
   - ✓ Shows API test URL

---

## 🌐 After Installation

Your akdamia installation is ready to use:

### Web App
**http://localhost:8000**
- Beautiful search interface
- Search 500+ academic citations
- Try: "Einstein", "Darwin", "Curie"

### Admin Panel
**http://localhost:8000/admin**
- Username: `admin`
- Password: (will be shown after install)
- Manage citations, authors, journals

### REST API
**http://localhost:8000/api/search/?q=term**
- Programmatic access to search
- JSON responses
- Full pagination support

---

## 📋 Requirements

**Before running the installer, you need:**

1. **Docker Desktop** (includes Docker and Docker Compose)
   - **macOS:** https://docs.docker.com/desktop/install/mac-install/
   - **Windows:** https://docs.docker.com/desktop/install/windows-install/
   - **Linux:** https://docs.docker.com/desktop/install/linux-install/

2. **Git** (for cloning the repository)
   - Likely already installed, but: https://git-scm.com/downloads

**That's all you need!** Python, PostgreSQL, Elasticsearch, etc. are all included in Docker.

---

## 🆘 Troubleshooting

### "Docker not found"
- Install Docker Desktop: https://www.docker.com/products/docker-desktop
- Restart your computer after installation
- Try again

### "Port 8000 already in use"
```bash
# Option 1: Stop other services
docker-compose -f Dockerfile-compose.yml down

# Option 2: Use a different port (in Dockerfile-compose.yml)
# Change "8000:8000" to "8001:8000"
```

### "Containers won't start"
```bash
# Check logs
docker-compose logs

# Restart everything
docker-compose down
docker-compose -f Dockerfile-compose.yml up -d
```

### "Database migrations failed"
```bash
# Run manually
docker-compose exec web python manage.py migrate

# Check status
docker-compose exec web python manage.py migrate --check
```

### "Search not working"
```bash
# Rebuild search index
docker-compose exec web python manage.py search_index --rebuild
```

---

## 🛑 Stopping akdamia

When you're done, stop all services:

```bash
docker-compose -f Dockerfile-compose.yml down
```

This stops PostgreSQL, Elasticsearch, Django, and Nginx but preserves your data.

---

## 🔄 Restarting akdamia

To start it again later:

```bash
docker-compose -f Dockerfile-compose.yml up -d
```

Your data and settings are preserved.

---

## 🗑️ Uninstalling akdamia

To completely remove akdamia:

```bash
# Stop all services
docker-compose -f Dockerfile-compose.yml down -v

# Remove the directory (optional)
cd ..
rm -rf akdamia
```

---

## 📚 Next Steps

1. **Explore the Web App**
   - Visit http://localhost:8000
   - Try searching for citations
   - Check out the admin panel

2. **Read the Documentation**
   - See README.md for features
   - See DEPLOYMENT_GUIDE.md for cloud deployment
   - See DEVELOPMENT_GUIDE.md for development setup

3. **Test the API**
   - Try: `curl http://localhost:8000/api/search/?q=Einstein`
   - See README.md for full API docs

4. **Deploy to Production**
   - See DEPLOYMENT_QUICKSTART.md for cloud options
   - Heroku: 5 commands, 10 minutes
   - AWS: 30 minutes
   - GCP: 20 minutes

---

## ✨ Features Included

- ✅ Full-text search across 500+ citations
- ✅ Beautiful, responsive web interface
- ✅ REST API with pagination
- ✅ Admin panel for content management
- ✅ Production-ready security
- ✅ Rate limiting and logging
- ✅ Zero-downtime deployment ready

---

## 📞 Need Help?

- **README.md** - Project features and overview
- **DEPLOYMENT_GUIDE.md** - Cloud deployment options
- **DEVELOPMENT_GUIDE.md** - Development setup
- **GitHub Issues** - Report problems

---

**That's it! Your akdamia installation is complete!** 🚀

The app is production-ready and can be deployed to Heroku, AWS, GCP, or any Docker-capable platform.
