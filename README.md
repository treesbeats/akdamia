# akdamia — Open-source Academic Citations Platform

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.11%2B-blue.svg)
![Django](https://img.shields.io/badge/django-4.2%2B-darkgreen.svg)

> Search and index academic citations in seconds. Beautiful, fast, open-source.

## 🚀 Quick Start

**One-liner install (Docker required):**

### macOS/Linux
```bash
bash <(curl -s https://raw.githubusercontent.com/treesbeats/akdamia/treesbeats-web-app-readme/install.sh)
```

### Windows PowerShell
```powershell
powershell -ExecutionPolicy Bypass -Command "& {iwr https://raw.githubusercontent.com/treesbeats/akdamia/treesbeats-web-app-readme/install.ps1 | iex}"
```

### Windows Command Prompt
```cmd
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/treesbeats/akdamia/treesbeats-web-app-readme/install.ps1 -OutFile install.ps1; powershell -ExecutionPolicy Bypass -File install.ps1"
```

**What it does automatically:**
- ✓ Checks Docker installation
- ✓ Clones the repository  
- ✓ Starts PostgreSQL, Elasticsearch, Django, Nginx
- ✓ Runs database migrations
- ✓ Loads sample citations
- ✓ Opens web app at http://localhost:8000

**Requirements:** Docker Desktop (free) — everything else is automated

## ✨ Features

- **Full-text search** with Elasticsearch + Django ORM fallback
- **Beautiful web UI** with responsive design and real-time search
- **PostgreSQL backend** for reliable, relational data
- **Django REST API** for programmatic access
- **500+ sample citations** ready to search
- **Production-ready** with Gunicorn, environment config, security headers
- **Docker Compose** for zero-config local development and deployment

## 📋 Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| Python | 3.11+ | Backend language |
| Django | 4.2+ | Web framework |
| PostgreSQL | 14+ | Primary database |
| Elasticsearch | 7.17+ | Full-text search |
| Nginx | Latest | Reverse proxy & static files |
| Frontend | HTML5/CSS3/JS | No build step required |

## 🎯 API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/` | GET | Home page with search UI |
| `/api/search/?q=<query>` | GET | Search citations |
| `/api/advanced-search/` | POST | Advanced search with filters |
| `/admin/` | GET | Django admin panel |

### Example API Request
```bash
curl "http://localhost:8000/api/search/?q=Einstein&limit=10"
```

## 📁 Project Structure

```
akdamia/
├── akdamia/              # Project configuration
│   ├── settings.py       # Django settings (db, middleware, logging)
│   ├── urls.py           # URL routing
│   └── wsgi.py           # WSGI application
├── search/               # Search application
│   ├── models.py         # Citation, Author, Journal models
│   ├── views.py          # API endpoints and search logic
│   ├── management/       # Django management commands
│   │   └── commands/
│   │       └── load_sample.py  # Load sample citation data
├── templates/            # HTML templates
│   └── search/
│       └── base.html     # Search UI
├── Dockerfile            # Container image definition
├── Dockerfile-compose.yml # Multi-container setup
├── entrypoint.sh         # Container initialization script
└── manage.py             # Django CLI tool
```

## 🏃 Running Locally

### With Docker (Recommended)
```bash
# Clone
git clone https://github.com/treesbeats/akdamia.git
cd akdamia

# Start all services
docker-compose -f Dockerfile-compose.yml up -d

# View logs
docker-compose -f Dockerfile-compose.yml logs -f web

# Stop services
docker-compose -f Dockerfile-compose.yml down
```

### With Local Python (Requires PostgreSQL + Elasticsearch)
```bash
# Setup
git clone https://github.com/treesbeats/akdamia.git
cd akdamia
python -m venv .venv
source .venv/bin/activate  # or .\.venv\Scripts\Activate.ps1 on Windows
pip install -r akdamia_requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your database credentials

# Run
python manage.py migrate
python manage.py createsuperuser
python manage.py load_sample
python manage.py runserver
```

## 🔧 Configuration

Environment variables (in `.env`):
```
DEBUG=False
SECRET_KEY=your-secret-key-here
DB_ENGINE=django.db.backends.postgresql
DB_NAME=akdamia
DB_USER=postgres
DB_PASSWORD=postgres
DB_HOST=localhost
DB_PORT=5432
ELASTICSEARCH_HOST=localhost:9200
ALLOWED_HOSTS=localhost,127.0.0.1
LOAD_SAMPLE_DATA=false
```

## 🧪 Testing the App

Once running:
1. **Web UI:** http://localhost:8000
2. **Admin panel:** http://localhost:8000/admin
3. **Search API:** http://localhost:8000/api/search/?q=einstein
4. **Advanced search:** POST to `/api/advanced-search/` with JSON body:
   ```json
   {
     "query": "relativity",
     "year_from": 1900,
     "year_to": 1950
   }
   ```

## 📚 Sample Data

The app includes 500+ academic citations by default. Search terms to try:
- Einstein
- Darwin
- Curie
- Newton
- Quantum

## 🚢 Deployment

See `DEPLOYMENT_GUIDE.md` for production setup on:
- Heroku (PaaS)
- AWS (EC2, ECS, App Runner)
- Google Cloud Platform (Cloud Run, Compute Engine)
- DigitalOcean
- Local Docker

## 📝 License

MIT License — see LICENSE.txt for details

## 💡 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-thing`)
3. Commit changes (`git commit -m "Add amazing thing"`)
4. Push to branch (`git push origin feature/amazing-thing`)
5. Open a Pull Request

## 🤝 Support

Having issues?
- Check the [Issues](https://github.com/treesbeats/akdamia/issues) page
- Review [INSTALL.md](INSTALL.md) for detailed setup instructions
- View container logs: `docker-compose logs -f`

## ⚡ Performance Notes

- **Search:** Uses Elasticsearch for sub-100ms queries on 100k+ citations
- **Fallback:** Django ORM search works if Elasticsearch unavailable
- **Caching:** Django cache framework (configurable backend)
- **Static files:** Served by Nginx for production deployments

---

Built with ❤️ for academic researchers.
