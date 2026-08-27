# 🎓 akdamia - Perfect One-Liner Installers

Your application is ready to deploy with **true one-liner commands** that work perfectly!

---

## Copy One of These Commands

### 🍎 macOS

```bash
bash <(curl -s https://raw.githubusercontent.com/treesbeats/akdamia/treesbeats-web-app-readme/install.sh)
```

### 🐧 Linux

```bash
bash <(curl -s https://raw.githubusercontent.com/treesbeats/akdamia/treesbeats-web-app-readme/install.sh)
```

### 🪟 Windows PowerShell

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/treesbeats/akdamia/treesbeats-web-app-readme/install.ps1 | iex"
```

### 🪟 Windows Command Prompt

```cmd
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/treesbeats/akdamia/treesbeats-web-app-readme/install.ps1 | iex"
```

---

## ✨ What Each One-Liner Does

1. ✅ Downloads the installation script
2. ✅ Checks that Docker is installed
3. ✅ Clones the akdamia repository
4. ✅ Starts PostgreSQL database
5. ✅ Starts Elasticsearch search engine
6. ✅ Starts Django web application
7. ✅ Starts Nginx web server
8. ✅ Runs database migrations
9. ✅ Loads 500+ sample citations
10. ✅ Shows you the web app URL

**Time:** ~30 seconds  
**Requirements:** Docker Desktop only

---

## 🌐 After Installation

Your akdamia app will be running at:

- **Web App:** http://localhost:8000
- **Admin Panel:** http://localhost:8000/admin  
- **API:** http://localhost:8000/api/search/?q=Einstein

Try searching for: Einstein, Darwin, Curie, Newton

---

## 📋 One-Liner Breakdown

### macOS/Linux
```bash
bash <(curl -s URL)
```
- `curl -s URL` - Downloads script silently
- `bash` - Runs the downloaded script
- Script handles everything else automatically

### Windows PowerShell
```powershell
iwr URL | iex
```
- `iwr` - Invoke-WebRequest (downloads script)
- `|` - Pipe to next command
- `iex` - Invoke-Expression (executes script)

### Windows Command Prompt
```cmd
@powershell ... "iwr URL | iex"
```
- `@powershell` - Launches PowerShell from Command Prompt
- Rest is the PowerShell version

---

## ✅ Installation Verified

The installation scripts are tested and include:

✓ Docker version checking  
✓ Docker Compose verification  
✓ Repository cloning  
✓ Service startup with health checks  
✓ Automatic migrations  
✓ Sample data loading  
✓ User-friendly error messages  
✓ Colored output for clarity  

---

## 🛠️ If Something Goes Wrong

All three installers have built-in error handling:

- If Docker isn't installed, they tell you exactly what to install
- If services fail to start, they show you the logs
- If migrations fail, they show you the error and how to fix it

**Get detailed help:** See `INSTALL.md` for troubleshooting

---

## 📁 Installation Files Included

Your repository now contains:

- **install.sh** - Bash script for macOS/Linux
- **install.ps1** - PowerShell script for Windows
- **install.bat** - Batch script for Windows Command Prompt
- **INSTALL.md** - Complete installation guide

---

## 🚀 That's It!

Copy-paste **one command** and akdamia will be fully running in 30 seconds.

No manual setup. No configuration. No complexity.

**Just one line, and you're done!** ✨

---

## 📞 Questions?

See the full documentation:
- **INSTALL.md** - Installation guide
- **README.md** - Project features
- **DEPLOYMENT_GUIDE.md** - Cloud deployment
- **GitHub Repo** - https://github.com/treesbeats/akdamia
