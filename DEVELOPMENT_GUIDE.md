# DEVELOPMENT_GUIDE.md

## 🚀 Complete Development Guide for akdamia

This guide walks you through setting up akdamia for local development and production deployment.

## Table of Contents

1. [Local Development Setup](#local-development-setup)
2. [Project Structure](#project-structure)
3. [Database & Search](#database--search)
4. [API Documentation](#api-documentation)
5. [Deployment](#deployment)
6. [Troubleshooting](#troubleshooting)

## Local Development Setup

### Step 1: Prerequisites

- Python 3.9+
- PostgreSQL 12+
- Elasticsearch 7.17+
- Docker & Docker Compose (recommended)
- Git

### Step 2: Clone and Setup

```bash
# Clone the repository
git clone https://github.com/treesbeats/akdamia.git
cd akdamia

# Create virtual environment
python -m venv .venv

# Activate (Windows PowerShell)
.\.venv\Scripts\Activate.ps1

# Activate (macOS/Linux)
source .venv/bin/activate

# Install dependencies
pip install -r akdamia_requirements.txt
```

### Step 3: Environment Configuration

```bash
# Copy example .env file
cp .env.example .env

# Edit .env with your settings
# Important: 
#   - Change SECRET_KEY to a secure value
#   - Set DATABASE credentials
#   - Set ELASTICSEARCH_HOST if not localhost
```

### Step 4: Database Setup

```bash
# Start PostgreSQL (using Docker)
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=akdamia \
  -p 5432:5432 \
  postgres:14

# Or use existing PostgreSQL installation
# Ensure you create database: CREATE DATABASE akdamia;
```

### Step 5: Elasticsearch Setup

```bash
# Start Elasticsearch (using Docker)
docker run -d \
  --name elasticsearch \
  -e discovery.type=single-node \
  -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
  -p 9200:9200 \
  docker.elastic.co/elasticsearch/elasticsearch:7.17.0
```

### Step 6: Django Initialization

```bash
# Run migrations
python manage.py migrate

# Create superuser (admin account)
python manage.py createsuperuser

# Load sample data
python manage.py load_sample

# Create search index
python manage.py search_index --rebuild
```

### Step 7: Start Development Server

```bash
# Run development server
python manage.py runserver

# Visit http://127.0.0.1:8000/
```

---

## Project Structure

```
akdamia/
│
├── akdamia/                    # Django project settings
│   ├── settings.py             # Configuration
│   ├── urls.py                 # URL routing
│   ├── wsgi.py                 # WSGI for deployment
│   └── asgi.py                 # ASGI for async
│
├── search/                     # Main search application
│   ├── models.py               # Database models
│   ├── views.py                # View functions
│   ├── serializers.py          # API serializers
│   ├── documents.py            # Elasticsearch mappings
│   ├── admin.py                # Django admin config
│   ├── management/
│   │   └── commands/
│   │       └── load_sample.py  # Load sample citations
│   ├── static/                 # CSS, JS, images
│   │   ├── css/
│   │   └── js/
│   └── templates/
│       ├── base.html           # Main search interface
│       ├── citation_detail.html # Citation detail page
│       └── admin/              # Admin templates
│
├── templates/                  # Global templates
├── static/                     # Global static files
│
├── sample_citations.json       # Sample data (500+ citations)
├── akdamia_docker-compose.yml # Docker Compose config
├── akdamia_requirements.txt    # Python dependencies
├── .env.example               # Environment variables template
├── .gitignore                 # Git ignore patterns
└── manage.py                  # Django management script
```

---

## Database & Search

### Models

#### Citation Model
```python
class Citation(models.Model):
    title = models.CharField(max_length=500)
    abstract = models.TextField(blank=True)
    authors = models.ManyToManyField(Author)
    year = models.IntegerField(null=True, blank=True)
    journal = models.ForeignKey(Journal, on_delete=models.SET_NULL, null=True)
    doi = models.CharField(max_length=100, unique=True, blank=True)
    url = models.URLField(blank=True)
    keywords = models.TextField(blank=True)  # Semicolon-separated
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

#### Author Model
```python
class Author(models.Model):
    name = models.CharField(max_length=200, unique=True)
    slug = models.SlugField(unique=True)
    bio = models.TextField(blank=True)
    orcid = models.CharField(max_length=50, blank=True)
```

#### Journal Model
```python
class Journal(models.Model):
    name = models.CharField(max_length=300, unique=True)
    slug = models.SlugField(unique=True)
    issn = models.CharField(max_length=20, blank=True)
    url = models.URLField(blank=True)
```

### Elasticsearch Indexing

The application uses django-elasticsearch-dsl for full-text search:

```python
# Index citation
from search.documents import CitationDocument

# Rebuild index
python manage.py search_index --rebuild

# Index new citations
python manage.py search_index --models search.Citation
```

---

## API Documentation

### Search Endpoint

**GET** `/api/search/`

Search for citations with query string.

**Query Parameters:**
- `q` (required): Search query
- `page` (optional): Page number (default: 1)
- `limit` (optional): Results per page (default: 20)

**Example Request:**
```bash
curl "http://localhost:8000/api/search/?q=machine+learning&page=1&limit=20"
```

**Example Response:**
```json
{
  "results": [
    {
      "id": "123",
      "title": "Deep Learning Fundamentals",
      "authors": "Yann LeCun; Yoshua Bengio",
      "year": 2015,
      "journal": "Nature",
      "abstract": "Recent advances...",
      "doi": "10.1038/nature14539",
      "url": "https://example.com/paper"
    }
  ],
  "count": 150,
  "page": 1,
  "total_pages": 8,
  "limit": 20
}
```

### Advanced Search

**GET** `/api/advanced-search/`

**Query Parameters:**
- `title`: Title search
- `authors`: Author name
- `year_from`: Start year
- `year_to`: End year
- `journal`: Journal/Source name
- `keywords`: Keywords filter

**Example:**
```bash
curl "http://localhost:8000/api/advanced-search/?title=neural+networks&year_from=2020&year_to=2023"
```

---

## Deployment

### Using Docker Compose

```bash
# Start all services
docker-compose -f akdamia_docker-compose.yml up -d

# Run migrations
docker-compose exec web python manage.py migrate

# Load sample data
docker-compose exec web python manage.py load_sample

# Create superuser
docker-compose exec web python manage.py createsuperuser
```

### Production Deployment

#### Checklist

- [ ] Set `DEBUG=False` in `.env`
- [ ] Generate strong `SECRET_KEY`
- [ ] Configure PostgreSQL with backups
- [ ] Setup Elasticsearch cluster (3+ nodes)
- [ ] Configure HTTPS/SSL
- [ ] Setup static files (`python manage.py collectstatic`)
- [ ] Configure CDN for static files
- [ ] Setup email service
- [ ] Enable rate limiting
- [ ] Configure monitoring and logging
- [ ] Setup regular backups

#### Deploy to Heroku

```bash
# Create app
heroku create your-akdamia-app

# Set environment variables
heroku config:set SECRET_KEY=your-secret-key
heroku config:set DEBUG=False

# Add PostgreSQL
heroku addons:create heroku-postgresql:standard-0

# Deploy
git push heroku main

# Run migrations
heroku run python manage.py migrate

# Load sample data
heroku run python manage.py load_sample
```

#### Deploy to AWS/GCP

See AWS/GCP documentation for:
- EC2/Compute Engine instances
- RDS/Cloud SQL for PostgreSQL
- Elasticsearch managed service
- CloudFront/Cloud CDN for static files

---

## Troubleshooting

### Elasticsearch Connection Issues

```python
# Check Elasticsearch status
curl http://localhost:9200/_cluster/health

# Rebuild index if corrupted
python manage.py search_index --rebuild

# If still failing, use Django ORM fallback (automatic)
```

### Database Connection Issues

```bash
# Check PostgreSQL is running
psql -U postgres -h localhost

# Reset migrations if needed
python manage.py migrate --plan  # Preview
python manage.py migrate         # Execute
```

### Static Files Not Loading

```bash
# Collect static files
python manage.py collectstatic --noinput

# Check settings
python manage.py test --settings=akdamia.settings
```

### Slow Queries

```bash
# Enable query logging in settings.py
LOGGING = {
    'version': 1,
    'handlers': {
        'console': {'class': 'logging.StreamHandler'},
    },
    'loggers': {
        'django.db.backends': {
            'handlers': ['console'],
            'level': 'DEBUG',
        },
    },
}

# Check indexes
python manage.py dbshell
# List indexes: \d search_citation
```

---

## Performance Optimization

### Database
- Add indexes on frequently searched columns
- Use `select_related()` and `prefetch_related()`
- Enable connection pooling

### Elasticsearch
- Adjust shard/replica settings
- Enable caching
- Use bulk API for indexing

### Django
- Enable caching (Redis)
- Use Celery for background tasks
- Enable GZIP compression
- Optimize image sizes

---

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Run tests
5. Submit pull request

---

## Support

For issues, questions, or suggestions:
- GitHub Issues: https://github.com/treesbeats/akdamia/issues
- Email: support@akdamia.io

---

**Happy developing! 🚀**
