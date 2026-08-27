# 🚀 Quick Deployment Checklist

## Before Deployment

### Local Testing
- [ ] All tests pass: `pytest`
- [ ] No linting errors: `flake8`
- [ ] Django checks pass: `python manage.py check`
- [ ] Migrations work: `python manage.py migrate`
- [ ] Search works locally
- [ ] Admin panel accessible
- [ ] API endpoints respond

### Code Review
- [ ] Code reviewed and approved
- [ ] No hardcoded secrets
- [ ] No DEBUG=True in production code
- [ ] No security vulnerabilities
- [ ] Performance acceptable (no N+1 queries)

### Environment Setup
- [ ] `.env` file created with production values
- [ ] Database backups configured
- [ ] Elasticsearch cluster healthy
- [ ] SSL/TLS certificates ready
- [ ] Domain DNS configured

---

## Deployment Options

### Option 1: Docker Compose (Local/VPS)
**Time: 15 minutes**

```bash
docker-compose -f Dockerfile-compose.yml up -d
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py load_sample
```

**Best for:** Development, staging, small production setups

### Option 2: Heroku
**Time: 10 minutes**

```bash
heroku create your-app
git push heroku main
heroku run python manage.py migrate
heroku run python manage.py load_sample
```

**Best for:** Quick deployments, free tier available, minimal DevOps

### Option 3: AWS EC2 + RDS
**Time: 45 minutes**

Follow DEPLOYMENT_GUIDE.md → AWS Deployment section

**Best for:** Enterprise, high availability, scaling

### Option 4: GCP Cloud Run
**Time: 30 minutes**

Follow DEPLOYMENT_GUIDE.md → GCP Deployment section

**Best for:** Serverless, cost-effective, auto-scaling

---

## Post-Deployment Verification

### Immediate (First 5 minutes)
- [ ] Application loads without errors
- [ ] Admin panel accessible
- [ ] Database migrations completed
- [ ] Static files loading
- [ ] Search functionality working

### First Hour
- [ ] Monitor error logs (should be clean)
- [ ] Test all major features
- [ ] Verify SSL/TLS certificate
- [ ] Check performance metrics
- [ ] Verify backups running

### First Day
- [ ] Monitor application stability
- [ ] Check database performance
- [ ] Verify Elasticsearch indexing
- [ ] Test admin functionality
- [ ] Review security logs

---

## Rollback Procedure

If deployment fails:

### Docker Compose
```bash
# View current containers
docker-compose ps

# Stop failed deployment
docker-compose down

# Restore previous version
git checkout previous-commit
docker-compose up -d
```

### Heroku
```bash
# View releases
heroku releases -a your-app

# Rollback to previous release
heroku releases:rollback -a your-app
```

### AWS/GCP
```bash
# For container deployments, revert image to previous tag
# Or restore from snapshots (if configured)
```

---

## Monitoring Dashboards

### Local (Docker)
- Application: http://localhost
- Admin: http://localhost/admin
- Elasticsearch: http://localhost:9200
- PostgreSQL: localhost:5432

### Production
- Application: https://yourdomain.com
- Admin: https://yourdomain.com/admin
- Logs: Check your monitoring service
- Metrics: CloudWatch / GCP Monitoring / Heroku Logs

---

## Support Contacts

- **Email:** support@akdamia.io
- **GitHub Issues:** https://github.com/treesbeats/akdamia/issues
- **Documentation:** See README.md and DEPLOYMENT_GUIDE.md

---

## Quick Reference

### Database Migrations
```bash
# Create migrations
python manage.py makemigrations

# Apply migrations
python manage.py migrate

# Rollback to previous migration
python manage.py migrate search 0001
```

### Search Index
```bash
# Rebuild search index
python manage.py search_index --rebuild

# Clear index
python manage.py search_index --delete

# Populate index
python manage.py search_index --populate
```

### Admin Tasks
```bash
# Create superuser
python manage.py createsuperuser

# Load sample data
python manage.py load_sample

# Collect static files
python manage.py collectstatic --noinput
```

### Testing
```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=search

# Run specific test
pytest tests/test_search.py::TestSearchAPI
```

---

## Environment Variables Needed

```
SECRET_KEY=your-secret-key-here
DEBUG=False
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

DB_NAME=akdamia
DB_USER=postgres
DB_PASSWORD=your-password
DB_HOST=your-database-host
DB_PORT=5432

ELASTICSEARCH_HOST=your-elasticsearch-host:9200

CORS_ALLOWED_ORIGINS=https://yourdomain.com

SECURE_SSL_REDIRECT=True
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True
```

---

**Deployment Ready! 🚀**

Choose your deployment method above and follow the instructions.
