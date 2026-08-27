# 🔧 Fixed Integration Guide

## Step-by-Step Setup Instructions

All bugs have been fixed! Follow these steps to integrate the corrected files into your Django project.

### Prerequisites
- Django project structure already created (scaffold files ready)
- Python 3.9+
- PostgreSQL
- Elasticsearch

---

## 1️⃣ Update Python Dependencies

```bash
# Replace the content of akdamia_requirements.txt with the FIXED version
# Key additions:
# - python-decouple>=3.8          (for environment config)
# - djangorestframework>=3.14.0   (for REST API)
# - django-cors-headers>=4.0.0    (for CORS)
# - django-extensions>=3.2.0      (for admin)
# - Pillow>=9.0.0                 (for image handling)

# Install updated dependencies
pip install -r akdamia_requirements.txt
```

**Files affected:**
- ✅ `akdamia_requirements.txt` (already updated)

---

## 2️⃣ Create/Update Django Models

Copy the content of `models_new.py` to your search app:

```bash
# Create models file
cp models_new.py akdamia/search/models.py
```

**Or manually:**
1. Open `akdamia/search/models.py`
2. Replace entire content with `models_new.py`
3. Models include:
   - `Author` - Academic authors with ORCID
   - `Journal` - Publications with ISSN/impact factor
   - `Citation` - Main citation model with 15+ fields
   - `Mention` - Citation mentions/quotes tracking
   - `SearchLog` - Search analytics

**Key features:**
- Full-text search support
- Citation formatting (APA, Chicago, Harvard, MLA)
- Timestamps and metadata
- Database indexes for performance

---

## 3️⃣ Create/Update Django Views

Copy the content of `views_fixed.py` to your search app:

```bash
# Create views file
cp views_fixed.py akdamia/search/views.py
```

**Or manually:**
1. Open `akdamia/search/views.py`
2. Replace entire content with `views_fixed.py`
3. Includes:
   - `index()` - Home page
   - `search_api()` - Main search API
   - `_search_elasticsearch()` - Elasticsearch search
   - `_search_database()` - Django ORM fallback
   - `citation_detail()` - Citation detail page
   - `advanced_search()` - Advanced search interface
   - `advanced_search_api()` - Advanced search API

**Key improvements:**
- Try/except for Elasticsearch with ORM fallback
- Proper pagination with error handling
- Input validation and sanitization
- Comprehensive logging
- JSON responses with metadata

---

## 4️⃣ Update Django Settings

**Option A: Complete Replacement**
```bash
cp settings_fixed.py akdamia/akdamia/settings.py
```

**Option B: Merge into existing settings.py**

Copy these sections into your existing `akdamia/settings.py`:

**Section 1: Imports**
```python
import os
from pathlib import Path
from decouple import config, Csv
```

**Section 2: Security**
```python
SECRET_KEY = config('SECRET_KEY', default='django-insecure-CHANGE-THIS!')
DEBUG = config('DEBUG', default=False, cast=bool)
ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='localhost,127.0.0.1', cast=Csv())
```

**Section 3: Installed Apps (add these)**
```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    'rest_framework',          # ADD
    'corsheaders',             # ADD
    'django_elasticsearch_dsl', # ADD
    'django_extensions',       # ADD
    
    'search',
]
```

**Section 4: Middleware (position matters!)**
```python
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',  # ADD - must be here
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
```

**Section 5: Database**
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': config('DB_NAME', default='akdamia'),
        'USER': config('DB_USER', default='postgres'),
        'PASSWORD': config('DB_PASSWORD', default='postgres'),
        'HOST': config('DB_HOST', default='localhost'),
        'PORT': config('DB_PORT', default='5432'),
    }
}
```

**Section 6: Elasticsearch**
```python
ELASTICSEARCH_DSL = {
    'default': {
        'hosts': config('ELASTICSEARCH_HOST', default='localhost:9200'),
        'timeout': 20,
    }
}
```

**Section 7: REST Framework**
```python
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_FILTER_BACKENDS': [
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle'
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/hour',
        'user': '1000/hour'
    }
}
```

**Section 8: CORS**
```python
CORS_ALLOWED_ORIGINS = config(
    'CORS_ALLOWED_ORIGINS',
    default='http://localhost:3000,http://localhost:8000,http://127.0.0.1:8000',
    cast=Csv()
)
CORS_ALLOW_CREDENTIALS = True
```

---

## 5️⃣ Update URL Routing

Copy the content of `urls_example.py` to your project:

```bash
cp urls_example.py akdamia/akdamia/urls.py
```

**Or manually:**
1. Open `akdamia/akdamia/urls.py`
2. Replace entire content with `urls_example.py`
3. Routes:
   - `/` → Home/search
   - `/search/` → Search results
   - `/citation/<id>/` → Citation details
   - `/api/search/` → API search
   - `/api/advanced-search/` → Advanced API search
   - `/admin/` → Django admin

---

## 6️⃣ Setup Templates Directory

```bash
# Create template directories
mkdir -p akdamia/templates/search

# Copy the search template
cp templates_base_search.html akdamia/templates/search/base.html

# You can also copy other templates (optional)
# cp templates_citation_detail.html akdamia/templates/search/citation_detail.html
```

**Directory structure should be:**
```
akdamia/
├── templates/
│   ├── search/
│   │   ├── base.html              (Main search interface)
│   │   ├── citation_detail.html   (Optional)
│   │   └── advanced_search.html   (Optional)
│   └── admin/                      (Django admin templates)
├── search/
│   ├── models.py                   ✅ FIXED
│   ├── views.py                    ✅ FIXED
│   ├── admin.py
│   ├── urls.py
│   └── management/
│       └── commands/
│           └── load_sample.py
├── akdamia/
│   ├── settings.py                 ✅ UPDATED
│   ├── urls.py                     ✅ FIXED
│   └── wsgi.py
└── manage.py
```

---

## 7️⃣ Environment Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your values
nano .env  # or your favorite editor
```

**Essential settings:**
```
SECRET_KEY=your-super-secret-key-here
DEBUG=False
ALLOWED_HOSTS=localhost,127.0.0.1,yourdomain.com

DB_NAME=akdamia
DB_USER=postgres
DB_PASSWORD=your_postgres_password
DB_HOST=localhost
DB_PORT=5432

ELASTICSEARCH_HOST=localhost:9200
```

---

## 8️⃣ Database Migrations

```bash
# Create migrations for new models
python manage.py makemigrations search

# Apply migrations
python manage.py migrate

# Verify database
python manage.py dbshell
# \dt search_*  (list search app tables)
```

---

## 9️⃣ Load Sample Data

```bash
# Create superuser first
python manage.py createsuperuser

# Load sample citations (500+)
python manage.py load_sample

# Verify data loaded
python manage.py shell
>>> from search.models import Citation
>>> Citation.objects.count()
500
```

---

## 🔟 Test the Setup

```bash
# Run Django checks
python manage.py check

# Collect static files
python manage.py collectstatic --noinput

# Start development server
python manage.py runserver

# Test endpoints:
# http://127.0.0.1:8000/               (Home)
# http://127.0.0.1:8000/api/search/?q=machine+learning
# http://127.0.0.1:8000/admin/
```

---

## 🐛 Troubleshooting

### ImportError: No module named 'decouple'
```bash
pip install python-decouple
```

### ImportError: No module named 'rest_framework'
```bash
pip install djangorestframework django-cors-headers
```

### Elasticsearch Connection Error
- Check if Elasticsearch is running: `curl http://localhost:9200`
- App will fallback to Django ORM if ES is down ✅

### PostgreSQL Connection Error
```bash
# Check connection
psql -U postgres -h localhost -d akdamia

# Or use Docker
docker run -d --name postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=akdamia -p 5432:5432 postgres:14
```

### Template Not Found
- Ensure directory structure is: `templates/search/base.html`
- Check `TEMPLATES` setting in `settings.py`

### Static Files Not Loading
```bash
python manage.py collectstatic --noinput
```

---

## 📋 Validation Checklist

- [ ] All requirements installed: `pip install -r akdamia_requirements.txt`
- [ ] Models copied to `search/models.py`
- [ ] Views copied to `search/views.py`
- [ ] Settings updated in `akdamia/settings.py`
- [ ] URLs updated in `akdamia/urls.py`
- [ ] Templates created in `templates/search/base.html`
- [ ] `.env` file created and configured
- [ ] PostgreSQL running and database created
- [ ] Elasticsearch running (or app can use ORM fallback)
- [ ] Migrations run: `python manage.py migrate`
- [ ] Superuser created: `python manage.py createsuperuser`
- [ ] Sample data loaded: `python manage.py load_sample`
- [ ] Server starts: `python manage.py runserver`
- [ ] Home page loads: http://127.0.0.1:8000/
- [ ] Search works: http://127.0.0.1:8000/api/search/?q=test

---

## 🎉 Success Indicators

✅ No import errors on startup
✅ Django checks pass: `python manage.py check`
✅ Server starts without errors
✅ Home page loads with search interface
✅ Search returns results (500+ sample citations)
✅ Admin panel works: http://127.0.0.1:8000/admin/
✅ API endpoints respond: `/api/search/?q=...`

---

## 📝 Files Overview

| File | Purpose | Status |
|------|---------|--------|
| `models_new.py` | Django models | ✅ NEW - Copy to search/models.py |
| `views_fixed.py` | Django views | ✅ FIXED - Copy to search/views.py |
| `settings_fixed.py` | Django settings | ✅ FIXED - Merge into settings.py |
| `urls_example.py` | URL routing | ✅ OK - Copy to urls.py |
| `templates_base_search.html` | Search UI | ✅ OK - Copy to templates/search/base.html |
| `akdamia_requirements.txt` | Dependencies | ✅ UPDATED |
| `.env.example` | Environment template | ✅ OK |
| `load_sample_command.py` | Data loader | ✅ OK |
| `DEBUG_REPORT.md` | Issues & fixes | 📖 REFERENCE |

---

## 🚀 Next Steps

After successful setup:

1. **Test the API**
   ```bash
   curl "http://127.0.0.1:8000/api/search/?q=machine+learning"
   ```

2. **Use the Web UI**
   - Visit http://127.0.0.1:8000
   - Search for "First Name Last Name"
   - Click on results to see details

3. **Access Admin Panel**
   - Visit http://127.0.0.1:8000/admin
   - Manage citations, authors, journals
   - Add custom data

4. **Deploy to Production**
   - See DEPLOYMENT_GUIDE.md
   - Configure production database
   - Set up Elasticsearch cluster
   - Enable HTTPS/SSL
   - Use Gunicorn + Nginx

---

**All bugs fixed and ready for deployment! 🎉**
