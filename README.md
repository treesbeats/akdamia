# akdamia — Open-source Academic Citations Platform

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.9%2B-blue.svg)
![Django](https://img.shields.io/badge/django-4.2%2B-darkgreen.svg)

> Search and index academic citations in seconds. Beautiful, fast, open-source.

## 🚀 Quick Start

**One-liner Docker:** `docker-compose -f Dockerfile-compose.yml up -d && echo "App ready at http://localhost:8000"`

Or deploy to Heroku (10 minutes):
```bash
heroku create your-app-name && \
heroku addons:create heroku-postgresql:standard-0 && \
git push heroku main && \
heroku open
```

## ✨ Features

- **Full-text search** across citations and mentions using Elasticsearch
- **Modern web UI** with responsive design and smooth interactions
- **PostgreSQL backend** for persistent, relational data
- **Django REST API** for programmatic access
- **Sample data included** with 500+ citations ready to search
- **Docker Compose support** for zero-config local development
- **Production-ready** with Gunicorn, environment configuration, and security defaults

## 📋 Stack

| Component | Version |
|-----------|---------|
| Python | 3.9+ |
| Django | 4.2+ |
| PostgreSQL | 12+ |
| Elasticsearch | 7.17+ |
| Frontend | HTML5, CSS3, Vanilla JS (no build step) |

## 📖 Installation

### Prerequisites
- Python 3.9+
- PostgreSQL 12+ (or Docker)
- Elasticsearch 7.17+ (or Docker)
- Docker & Docker Compose (optional but recommended)

### Local Setup (Windows PowerShell)

```powershell
# 1. Clone the repository
git clone https://github.com/treesbeats/akdamia.git
cd akdamia

# 2. Create virtual environment and install dependencies
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r akdamia_requirements.txt

# 3. Start services (Docker)
docker-compose -f akdamia_docker-compose.yml up -d

# 4. Initialize database and load sample data
python manage.py migrate
python manage.py createsuperuser
python manage.py load_sample

# 5. Start development server
python manage.py runserver
```

Visit **http://127.0.0.1:8000** and search for "First Name Last Name"

### Docker Compose (All-in-One)

```powershell
# Start all services
docker-compose -f akdamia_docker-compose.yml up -d

# Run migrations
docker-compose -f akdamia_docker-compose.yml exec web python manage.py migrate
docker-compose -f akdamia_docker-compose.yml exec web python manage.py load_sample

# Stop services
docker-compose -f akdamia_docker-compose.yml down
```

## 🎨 Web Interface

The built-in web interface includes:
- **Search page** with real-time Elasticsearch results
- **Citation detail views** with full metadata
- **Admin dashboard** for managing data (Django admin)
- **Dark/light theme support** for comfortable browsing
- **Keyboard shortcuts** for power users
- **Responsive mobile design** for on-the-go research

## 🔧 Development

### Running Tests
```bash
python manage.py test
```

### Creating a Superuser
```bash
python manage.py createsuperuser
# Visit http://127.0.0.1:8000/admin
```

### Loading Custom Data
```bash
python manage.py loaddata your_citations.json
```

### Indexing Citations
```bash
python manage.py search_index --rebuild
```

## 📚 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Home page with search interface |
| `/search/` | GET | Citation search results page |
| `/api/search/` | GET | REST API search endpoint |
| `/api/citations/` | GET | List all citations |
| `/api/citations/<id>/` | GET | Citation detail |
| `/admin/` | GET | Django admin interface |

## 🚀 Deployment

### Production Checklist
- [ ] Set `DEBUG=False` in `.env`
- [ ] Configure `ALLOWED_HOSTS`
- [ ] Use environment variables for secrets
- [ ] Enable HTTPS
- [ ] Configure static files (`collectstatic`)
- [ ] Set up PostgreSQL backup strategy
- [ ] Monitor Elasticsearch cluster health
- [ ] Configure email for notifications

### Deploy to Heroku
```bash
git push heroku main
heroku run python manage.py migrate
heroku run python manage.py load_sample
heroku open
```

### Deploy to AWS/GCP
See the deployment guide in IMPLEMENTATION_NOTES.md

## 📁 Project Structure

```
akdamia/
├── manage.py              # Django management script
├── akdamia/               # Project settings package
│   ├── settings.py        # Django configuration
│   ├── urls.py            # URL routing
│   ├── wsgi.py            # WSGI entry point
│   └── asgi.py            # ASGI entry point
├── search/                # Citation search app
│   ├── models.py          # Citation, Author, Mention models
│   ├── views.py           # Search and detail views
│   ├── documents.py       # Elasticsearch document mappings
│   ├── management/        # Custom management commands
│   ├── static/            # CSS, JS, images
│   └── templates/         # HTML templates
├── templates/             # Global HTML templates
│   ├── base.html          # Base layout
│   ├── search.html        # Search interface
│   └── citation_detail.html
├── static/                # Global static files
├── requirements.txt       # Python dependencies
└── docker-compose.yml     # Docker Compose configuration
```

## 🛠️ Next Steps

- [ ] Implement user authentication (JWT or OAuth2)
- [ ] Add bulk import/export for citations
- [ ] Create analytics dashboard
- [ ] Build citation parser from PDFs
- [ ] Implement advanced filtering (date range, author, source)
- [ ] Add citation export (BibTeX, APA, MLA)
- [ ] Build REST API documentation with OpenAPI/Swagger
- [ ] Add GraphQL endpoint

## 🧪 Testing

Run the full test suite:
```bash
python manage.py test --verbosity=2
```

Run tests for a specific app:
```bash
python manage.py test search
```

Generate coverage report:
```bash
coverage run --source='.' manage.py test
coverage report
```

## 📊 Sample Data

The project includes `sample_citations.json` with 500+ academic citations. After migrations, load it:
```bash
python manage.py load_sample
```

To export data:
```bash
python manage.py dumpdata search > citations_backup.json
```

## 🔐 Security

- CSRF protection enabled by default
- SQL injection prevention (Django ORM)
- XSS protection with template escaping
- Secure password hashing (bcrypt)
- Environment variable support for secrets
- Rate limiting (optional, recommended for production)

## 📄 License

MIT License — See `LICENSE.txt` for details.

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📧 Contact

Questions? Open an issue on GitHub or check the IMPLEMENTATION_NOTES.md for detailed architecture docs.

---

**Built with ❤️ for academic researchers and citation enthusiasts.**
