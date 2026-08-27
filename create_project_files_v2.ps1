# create_project_files_v2.ps1
# Enhanced project generator for akdamia with Postgres, Elasticsearch, and Celery templates.
# Run from the session files folder to create akdamia/ project ready for dev/docker.

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

# manage.py
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

# settings.py with Postgres/ES/Celery wiring
$settings = @'
import os
from pathlib import Path
import environ

env = environ.Env(DEBUG=(bool, True))
BASE_DIR = Path(__file__).resolve().parent.parent

DEBUG = env.bool('DEBUG', default=True)
SECRET_KEY = env('SECRET_KEY', default='dev-secret-key')
ALLOWED_HOSTS = env.list('ALLOWED_HOSTS', default=['*'])

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.sites',
    'search',
    'django_elasticsearch_dsl',
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

# Database: default to Postgres via env, fallback to sqlite for quick demo
if env.bool('USE_POSTGRES', default=False):
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': env('POSTGRES_DB', default='akdamia'),
            'USER': env('POSTGRES_USER', default='akdamia'),
            'PASSWORD': env('POSTGRES_PASSWORD', default='akdamia'),
            'HOST': env('POSTGRES_HOST', default='db'),
            'PORT': env('POSTGRES_PORT', default='5432'),
        }
    }
else:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }

# Elasticsearch
ELASTICSEARCH_DSL = {
    'default': {
        'hosts': env('ELASTICSEARCH_HOST', default='elasticsearch:9200')
    },
}

# Celery
CELERY_BROKER_URL = env('CELERY_BROKER_URL', default='redis://redis:6379/0')
CELERY_RESULT_BACKEND = env('CELERY_RESULT_BACKEND', default='redis://redis:6379/1')

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

STATIC_URL = '/static/'
STATICFILES_DIRS = [BASE_DIR / 'static']

SITE_ID = 1
'@
write-file 'akdamia/settings.py' $settings

# urls.py
$urls = @'
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('search.urls')),
]
'@
write-file 'akdamia/urls.py' $urls

# wsgi.py
$wsgi = @'
import os
from django.core.wsgi import get_wsgi_application
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'akdamia.settings')
application = get_wsgi_application()
'@
write-file 'akdamia/wsgi.py' $wsgi

# celery.py
$celery = @'
import os
from celery import Celery

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'akdamia.settings')
app = Celery('akdamia')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()
'@
write-file 'akdamia/celery.py' $celery

# __init__.py to load celery
$init = @'
from .celery import app as celery_app

__all__ = ('celery_app',)
'@
write-file 'akdamia/__init__.py' $init

# search app
write-file 'search/__init__.py' ""

$app_apps = @'
from django.apps import AppConfig

class SearchConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'search'
'@
write-file 'search/apps.py' $app_apps

# models (same as previous)
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
    citations = models.JSONField(default=list, blank=True)
    citations_text = models.TextField(blank=True)

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

# admin
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

# views
$app_views = @'
from django.shortcuts import render, get_object_or_404, redirect
from .models import Paper, Author
from django.db.models import Q
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth import login

def index(request):
    q = request.GET.get('q', '').strip()
    results = []
    if q:
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

def signup(request):
    if request.method == 'POST':
        form = UserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            return redirect('search:index')
    else:
        form = UserCreationForm()
    return render(request, 'registration/signup.html', {'form': form})
'@
write-file 'search/views.py' $app_views

# urls
$app_urls = @'
from django.urls import path
from . import views
from django.contrib.auth import views as auth_views

app_name = 'search'
urlpatterns = [
    path('', views.index, name='index'),
    path('author/<int:author_id>/', views.profile, name='profile'),
    path('signup/', views.signup, name='signup'),
    path('login/', auth_views.LoginView.as_view(template_name="registration/login.html"), name='login'),
    path('logout/', auth_views.LogoutView.as_view(next_page='/'), name='logout'),
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
    <p>{% if user.is_authenticated %}Hello {{ user.username }} | <a href="{% url 'search:logout' %}">Logout</a>{% else %}<a href="{% url 'search:login' %}">Login</a> | <a href="{% url 'search:signup' %}">Sign up</a>{% endif %}</p>
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

$login_html = @'
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>Login</title></head>
  <body>
    <h1>Login</h1>
    <form method="post">{% csrf_token %}
      {{ form.as_p }}
      <button type="submit">Login</button>
    </form>
    <p><a href="{% url 'search:signup' %}">Sign up</a></p>
  </body>
</html>
'@
write-file 'templates/registration/login.html' $login_html

$signup_html = @'
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>Sign up</title></head>
  <body>
    <h1>Sign up</h1>
    <form method="post">{% csrf_token %}
      {{ form.as_p }}
      <button type="submit">Create account</button>
    </form>
    <p><a href="{% url 'search:login' %}">Login</a></p>
  </body>
</html>
'@
write-file 'templates/registration/signup.html' $signup_html

# documents.py for django-elasticsearch-dsl
$documents = @'
from django_elasticsearch_dsl import Document, Index, fields
from django_elasticsearch_dsl.registries import registry
from .models import Paper

papers_index = Index('papers')

@papers_index.doc_type
class PaperDocument(Document):
    authors = fields.TextField(attr='citations_text')

    class Index:
        name = 'papers'
        settings = {'number_of_shards': 1, 'number_of_replicas': 0}

    class Django:
        model = Paper
        fields = [
            'title',
            'year',
            'abstract',
            'citations_text',
        ]
'@
write-file 'search/documents.py' $documents

# management command to rebuild ES index
$rebuild_cmd = @'
from django.core.management.base import BaseCommand
from django.conf import settings
from django_elasticsearch_dsl.registries import registry

class Command(BaseCommand):
    help = 'Rebuild all Elasticsearch indexes for the project'

    def handle(self, *args, **options):
        self.stdout.write('Deleting indices...')
        for index in registry.get_indexes():
            try:
                index.delete(ignore=[404])
            except Exception as e:
                self.stdout.write(f"Delete failed: {e}")
        self.stdout.write('Creating and indexing...')
        for index in registry.get_indexes():
            index.create()
            index.update()
        self.stdout.write(self.style.SUCCESS('Rebuilt ES indexes'))
'@
write-file 'search/management/commands/rebuild_index.py' $rebuild_cmd
write-file 'search/management/__init__.py' ""
write-file 'search/management/commands/__init__.py' ""

# Celery task example and tasks.py
$tasks = @'
from celery import shared_task
from .models import Paper

@shared_task
def index_all_papers():
    from .documents import PaperDocument
    for p in Paper.objects.all():
        PaperDocument().update(p)
'@
write-file 'search/tasks.py' $tasks

# migrations placeholder
write-file 'search/migrations/__init__.py' ""

# production-like docker-compose.yml
$docker_compose = @'
version: '"'3.7'"'
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: akdamia
      POSTGRES_USER: akdamia
      POSTGRES_PASSWORD: akdamia
    ports:
      - "5432:5432"
    volumes:
      - db_data:/var/lib/postgresql/data

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.9
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
    ports:
      - "9200:9200"

  redis:
    image: redis:6
    ports:
      - "6379:6379"

  web:
    build: .
    command: gunicorn akdamia.wsgi:application --bind 0.0.0.0:8000
    volumes:
      - .:/code
    ports:
      - "8000:8000"
    depends_on:
      - db
      - elasticsearch
      - redis

  worker:
    build: .
    command: celery -A akdamia worker --loglevel=info
    volumes:
      - .:/code
    depends_on:
      - redis
      - db

volumes:
  db_data:
'@
write-file 'docker-compose.yml' $docker_compose

Write-Host "Enhanced project templates written to $projectDir. To create the project, run this script and follow the README."
