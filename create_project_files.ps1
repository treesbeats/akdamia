# Creates a Django project skeleton (akdamia) and a simple 'search' app from templates included below.
# Run this in PowerShell from the folder containing this script (the session files folder).
# It will create the akdamia/ directory and all files needed for the local demo.

$base = (Get-Location).ProviderPath
$projectDir = Join-Path $base 'akdamia'
Write-Host "Creating project directory: $projectDir"
New-Item -Path $projectDir -ItemType Directory -Force | Out-Null

function write-file($relativePath, $content) {
  $full = Join-Path $projectDir $relativePath
  $dir = Split-Path $full -Parent
  if (-not (Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
  Set-Content -Path $full -Value $content -Encoding UTF8
  Write-Host "Wrote: $relativePath"
}

$manage = @'
#!/usr/bin/env python
import os
import sys

def main():
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'akdamia.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError("Couldn't import Django") from exc
    execute_from_command_line(sys.argv)

if __name__ == '__main__':
    main()
'@

write-file 'manage.py' $manage

$settings = @'
import os
from pathlib import Path
import environ

env = environ.Env(DEBUG=(bool, True))
BASE_DIR = Path(__file__).resolve().parent.parent

DEBUG = env('DEBUG', default=True)
SECRET_KEY = env('SECRET_KEY', default='dev-secret-key')
ALLOWED_HOSTS = ['*']

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'search',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'akdamia.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'akdamia.wsgi.application'

# Default: sqlite for demo. Replace with Postgres env vars for production.
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# Elasticsearch placeholders
ELASTICSEARCH_DSL = {
    'default': {
        'hosts': env('ELASTICSEARCH_HOST', default='localhost:9200')
    },
}

AUTH_PASSWORD_VALIDATORS = []

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

STATIC_URL = '/static/'
STATICFILES_DIRS = [BASE_DIR / 'static']
'@

write-file 'akdamia/settings.py' $settings

$urls = @'
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('search.urls')),
]
'@

write-file 'akdamia/urls.py' $urls

$wsgi = @'
import os
from django.core.wsgi import get_wsgi_application
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'akdamia.settings')
application = get_wsgi_application()
'@

write-file 'akdamia/wsgi.py' $wsgi

$asgi = @'
import os
from django.core.asgi import get_asgi_application
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'akdamia.settings')
application = get_asgi_application()
'@

write-file 'akdamia/asgi.py' $asgi

# search app files
$app_init = ""
write-file 'search/__init__.py' $app_init

$app_apps = @'
from django.apps import AppConfig

class SearchConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'search'
'@
write-file 'search/apps.py' $app_apps

$app_models = @'
from django.db import models
from django.contrib.auth.models import User

class Author(models.Model):
    full_name = models.CharField(max_length=255, db_index=True)
    first_name = models.CharField(max_length=120, blank=True)
    last_name = models.CharField(max_length=120, blank=True)

    def __str__(self):
        return self.full_name

class Paper(models.Model):
    title = models.CharField(max_length=1000)
    year = models.IntegerField(null=True, blank=True)
    abstract = models.TextField(blank=True)
    authors = models.ManyToManyField(Author, related_name='papers')
    citations = models.JSONField(default=list, blank=True)  # list of citation strings
    citations_text = models.TextField(blank=True)  # denormalized for sqlite demo search

    def __str__(self):
        return self.title

class Insight(models.Model):
    paper = models.ForeignKey(Paper, on_delete=models.CASCADE, related_name='insights')
    text = models.TextField()

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    display_name = models.CharField(max_length=255, blank=True)

    def __str__(self):
        return self.display_name or self.user.username
'@
write-file 'search/models.py' $app_models

$app_admin = @'
from django.contrib import admin
from .models import Author, Paper, Insight, Profile

@admin.register(Author)
class AuthorAdmin(admin.ModelAdmin):
    search_fields = ('full_name',)

@admin.register(Paper)
class PaperAdmin(admin.ModelAdmin):
    search_fields = ('title', 'citations_text', 'abstract')
    list_display = ('title', 'year')

admin.site.register(Insight)
admin.site.register(Profile)
'@
write-file 'search/admin.py' $app_admin

$app_views = @'
from django.shortcuts import render, get_object_or_404
from .models import Paper, Author
from django.db.models import Q

def index(request):
    q = request.GET.get('q', '').strip()
    results = []
    if q:
        # Simple demo search over authors, title, abstract, and citations text
        results = Paper.objects.filter(
            Q(title__icontains=q) |
            Q(abstract__icontains=q) |
            Q(citations_text__icontains=q) |
            Q(authors__full_name__icontains=q)
        ).distinct()[:200]
    return render(request, 'search/index.html', {'results': results, 'q': q})

def profile(request, author_id):
    author = get_object_or_404(Author, pk=author_id)
    papers = author.papers.all()
    return render(request, 'search/profile.html', {'author': author, 'papers': papers})
'@
write-file 'search/views.py' $app_views

$app_urls = @'
from django.urls import path
from . import views

app_name = 'search'
urlpatterns = [
    path('', views.index, name='index'),
    path('author/<int:author_id>/', views.profile, name='profile'),
]
'@
write-file 'search/urls.py' $app_urls

# templates
$index_html = @'
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>akdamia — search</title>
  </head>
  <body>
    <h1>akdamia — Search</h1>
    <form method="get">
      <input name="q" placeholder="Search (e.g. First Name Last Name)" value="{{ q }}" size="60" />
      <button type="submit">Search</button>
    </form>
    <hr />
    {% if results %}
      <p>Showing {{ results|length }} results</p>
      <ul>
      {% for p in results %}
        <li>
          <strong>{{ p.title }}</strong> ({{ p.year }})<br/>
          Authors: {% for a in p.authors.all %}<a href="{% url 'search:profile' a.id %}">{{ a.full_name }}</a>{% if not forloop.last %}, {% endif %}{% endfor %}<br/>
          {{ p.abstract|truncatechars:200 }}<br/>
          Citations: {{ p.citations_text|truncatechars:150 }}
        </li>
      {% endfor %}
      </ul>
    {% else %}
      <p>No results. Try searching for "First Name Last Name".</p>
    {% endif %}
  </body>
</html>
'@
write-file 'templates/search/index.html' $index_html

$profile_html = @'
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>{{ author.full_name }}</title></head>
  <body>
    <h1>{{ author.full_name }}</h1>
    <h2>Papers</h2>
    <ul>
    {% for p in papers %}
      <li><strong>{{ p.title }}</strong> ({{ p.year }})</li>
    {% empty %}
      <li>No papers found.</li>
    {% endfor %}
    </ul>
    <p><a href="/">Back to search</a></p>
  </body>
</html>
'@
write-file 'templates/search/profile.html' $profile_html

# management command to load sample data
$load_cmd = @'
import json
from django.core.management.base import BaseCommand
from pathlib import Path
from search.models import Author, Paper, Insight

class Command(BaseCommand):
    help = 'Load sample_citations.json into the database for demo'

    def handle(self, *args, **options):
        base = Path(__file__).resolve().parents[4]  # points to files/akdamia/../../.. -> session files root
        sample = base.parent / 'sample_citations.json'
        if not sample.exists():
            self.stdout.write(self.style.ERROR(f"Sample file not found: {sample}"))
            return
        data = json.loads(sample.read_text(encoding='utf-8'))
        for entry in data:
            title = entry.get('title')
            paper, _ = Paper.objects.get_or_create(title=title, defaults={'year': entry.get('year'), 'abstract': entry.get('abstract','')})
            # authors
            authors = entry.get('authors', [])
            for a in authors:
                auth_obj, _ = Author.objects.get_or_create(full_name=a, defaults={'first_name': a.split()[0] if a else '', 'last_name': a.split()[-1] if a else ''})
                paper.authors.add(auth_obj)
            # citations
            citations = entry.get('citations', [])
            paper.citations = citations
            paper.citations_text = '; '.join(citations)
            paper.save()
            insights = entry.get('insights', [])
            for ins in insights:
                Insight.objects.create(paper=paper, text=ins)
        self.stdout.write(self.style.SUCCESS('Loaded sample data'))
'@
write-file 'search/management/commands/load_sample.py' $load_cmd

write-file 'search/management/__init__.py' ""
write-file 'search/management/commands/__init__.py' ""

# migrations placeholder
write-file 'search/migrations/__init__.py' ""

Write-Host "Project templates written. Next: run the existing create_scaffold.ps1 or run this project:\n  cd $projectDir\n  .\\.venv\\Scripts\\Activate.ps1 (after venv creation)\n  pip install -r ..\\akdamia_requirements.txt\n  python manage.py migrate\n  python manage.py createsuperuser\n  python manage.py load_sample\n  python manage.py runserver\n"
