akdamia — Open-source academic citations platform (prototype)

Overview

This repository scaffolds a Django + PostgreSQL + Elasticsearch prototype for indexing and searching citations, mentions, and insights. It includes sample data (sample_citations.json) and a PowerShell script to generate a local Django project and app skeleton.

Stack
- Django
- PostgreSQL
- Elasticsearch
- django-elasticsearch-dsl

Quick start (Windows, PowerShell)
1. Clone or download these scaffold files into a local folder.
2. Open PowerShell in that folder and run: .\create_scaffold.ps1
3. Follow the script prompts: it will create a virtualenv, install requirements, create the Django project and a "search" app, and add minimal models/views.
4. Use Docker Compose (optional) to run Postgres + Elasticsearch: docker-compose up -d
5. Load sample data: python manage.py loaddata sample_citations.json (or run the provided management command if created)
6. Run the dev server: python manage.py runserver

Pushing to GitHub
Remote (as provided): https://github.com/treesbeats/akdamia.git
To push once you have a local repo created:
  git init
  git add .
  git commit -m "Initial scaffold"
  git remote add origin https://github.com/treesbeats/akdamia.git
  git push -u origin main

Notes
- This scaffold avoids copying proprietary UI from any existing service. It provides an open-source architecture and sample data to help search for mentions like "First Name Last Name".
- Next steps (can be implemented on request): authentication, user profiles, bulk indexing pipeline, citation parsers, analytics dashboards.
