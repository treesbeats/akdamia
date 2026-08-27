Implementation notes — akdamia (milestone A)

Files created by assistant:
- create_project_files.ps1  : writes a full Django project skeleton into files/akdamia when run locally
- sample_citations.json    : sample dataset (already in session files root)
- akdamia_README.md        : high-level README and push instructions
- create_scaffold.ps1      : earlier helper to run django-admin locally
- akdamia_docker-compose.yml, akdamia_requirements.txt, .gitignore, LICENSE

How to create the real project locally (recommended):
1. Open PowerShell in this folder (the session files folder) where create_project_files.ps1 is located.
2. Run: .\create_project_files.ps1
   - This will create the akdamia/ directory with a Django project and the 'search' app.
3. Create and activate a virtualenv and install requirements:
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   pip install -r akdamia_requirements.txt
4. Initialize Django DB and load sample data:
   cd akdamia
   python manage.py migrate
   python manage.py createsuperuser
   python manage.py load_sample
   python manage.py runserver
5. Visit http://127.0.0.1:8000 and search for: First Name Last Name

Next recommended development tasks (can implement now):
- Wire PostgreSQL and django-elasticsearch-dsl for robust searching
- Implement indexing pipeline and a Celery worker for background tasks
- Add authentication flows (email verification, OAuth)
- Build richer UI and React frontend if desired

If you'd like, continue and I will:
- Implement Postgres & Elasticsearch settings + Docker Compose targets
- Add indexing via django-elasticsearch-dsl and a simple indexing command
- Add CI (GitHub Actions) and production deploy manifests

Tell me which to implement next or allow me to continue autonomously.
