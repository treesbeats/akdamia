# 🚀 Deployment Guide for akdamia

Complete instructions for deploying akdamia to production.

## Table of Contents

1. [Local Docker Setup](#local-docker-setup)
2. [Heroku Deployment](#heroku-deployment)
3. [AWS Deployment](#aws-deployment)
4. [GCP Deployment](#gcp-deployment)
5. [Production Checklist](#production-checklist)

---

## Local Docker Setup

### Prerequisites
- Docker & Docker Compose installed
- `.env` file configured

### Quick Start

```bash
# 1. Prepare environment
cp .env.example .env
# Edit .env with your values

# 2. Build and start services
docker-compose -f Dockerfile-compose.yml up -d

# 3. Run migrations
docker-compose -f Dockerfile-compose.yml exec web python manage.py migrate

# 4. Create superuser
docker-compose -f Dockerfile-compose.yml exec web python manage.py createsuperuser

# 5. Load sample data
docker-compose -f Dockerfile-compose.yml exec web python manage.py load_sample

# 6. Access application
# Web: http://localhost
# Admin: http://localhost/admin
# API: http://localhost/api/search/?q=test
```

### Viewing Logs

```bash
# All services
docker-compose -f Dockerfile-compose.yml logs -f

# Specific service
docker-compose -f Dockerfile-compose.yml logs -f web
docker-compose -f Dockerfile-compose.yml logs -f postgres
docker-compose -f Dockerfile-compose.yml logs -f elasticsearch
```

### Stopping Services

```bash
# Stop all services
docker-compose -f Dockerfile-compose.yml down

# Stop and remove volumes (WARNING: deletes data!)
docker-compose -f Dockerfile-compose.yml down -v
```

---

## Heroku Deployment

### Prerequisites
- Heroku CLI installed
- Heroku account with payment method
- Git repository initialized

### Step 1: Create Heroku App

```bash
# Login to Heroku
heroku login

# Create app
heroku create your-app-name

# Or add existing app
heroku git:remote -a your-app-name
```

### Step 2: Configure Add-ons

```bash
# PostgreSQL (production tier)
heroku addons:create heroku-postgresql:standard-0 -a your-app-name

# Redis (optional, for caching)
heroku addons:create heroku-redis:premium-0 -a your-app-name

# Elasticsearch (optional, but recommended)
# Note: Use Bonsai Elasticsearch add-on
heroku addons:create bonsai:sandbox -a your-app-name
```

### Step 3: Configure Environment Variables

```bash
# Set secret key
heroku config:set SECRET_KEY='your-very-secret-key-here' -a your-app-name

# Set debug to false
heroku config:set DEBUG=False -a your-app-name

# Set allowed hosts
heroku config:set ALLOWED_HOSTS='your-app-name.herokuapp.com' -a your-app-name

# Get database URL (automatically set by add-on)
heroku config -a your-app-name | grep DATABASE_URL

# Set Elasticsearch URL (if using Bonsai)
heroku config -a your-app-name | grep BONSAI_URL
```

### Step 4: Create Procfile

```bash
cat > Procfile << 'EOF'
web: gunicorn akdamia.wsgi --log-file -
release: python manage.py migrate && python manage.py search_index --rebuild
EOF
```

### Step 5: Deploy

```bash
# Deploy
git push heroku main

# View logs
heroku logs --tail -a your-app-name

# Open app
heroku open -a your-app-name
```

### Step 6: Post-Deployment

```bash
# Create superuser
heroku run python manage.py createsuperuser -a your-app-name

# Load sample data
heroku run python manage.py load_sample -a your-app-name

# Collect static files
heroku run python manage.py collectstatic --noinput -a your-app-name
```

---

## AWS Deployment

### Option A: EC2 + RDS + OpenSearch

#### Prerequisites
- AWS Account
- AWS CLI configured
- Key pair created

#### Step 1: Launch EC2 Instance

```bash
# Launch Ubuntu 22.04 LTS instance
# Instance type: t3.medium (or larger)
# Security group: Allow 80, 443, 22
# Assign elastic IP
```

#### Step 2: Install Dependencies

```bash
# SSH into instance
ssh -i key.pem ec2-user@your-instance-ip

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io docker-compose

# Install certbot for SSL
sudo apt install -y certbot python3-certbot-nginx

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

#### Step 3: Setup RDS

```bash
# Create PostgreSQL RDS instance
# - Engine: PostgreSQL 14
# - Instance: db.t3.micro (or larger for production)
# - Storage: 100 GB
# - Multi-AZ: Yes (for production)
# - Backup retention: 30 days

# Note the endpoint and credentials
```

#### Step 4: Setup OpenSearch

```bash
# Create OpenSearch domain
# - Version: 7.10
# - Domain name: akdamia-search
# - Instance: t3.small.search
# - Storage: 100 GB
```

#### Step 5: Deploy Application

```bash
# Clone repository
cd /opt
git clone https://github.com/treesbeats/akdamia.git
cd akdamia

# Create .env file
cat > .env << 'EOF'
DEBUG=False
SECRET_KEY=your-very-secret-key
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
DB_NAME=akdamia
DB_USER=postgres
DB_PASSWORD=your-password
DB_HOST=your-rds-endpoint
DB_PORT=5432
ELASTICSEARCH_HOST=your-opensearch-endpoint:9200
EOF

# Start services
docker-compose -f Dockerfile-compose.yml up -d

# Run migrations
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser
docker-compose exec web python manage.py load_sample
```

#### Step 6: Setup SSL/TLS

```bash
# Stop Nginx temporarily
docker-compose -f Dockerfile-compose.yml stop nginx

# Get SSL certificate
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ./ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ./ssl/key.pem
sudo chown $(id -u):$(id -g) ./ssl/*

# Start Nginx with SSL
docker-compose -f Dockerfile-compose.yml up -d nginx
```

#### Step 7: Setup Auto-Renewal

```bash
# Create renewal script
sudo tee /usr/local/bin/renew-ssl.sh << 'EOF'
#!/bin/bash
certbot renew --quiet
cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem /opt/akdamia/ssl/cert.pem
cp /etc/letsencrypt/live/yourdomain.com/privkey.pem /opt/akdamia/ssl/key.pem
chown $(id -u akdamia):$(id -g akdamia) /opt/akdamia/ssl/*
docker-compose -f /opt/akdamia/Dockerfile-compose.yml restart nginx
EOF

sudo chmod +x /usr/local/bin/renew-ssl.sh

# Add to crontab
sudo crontab -e
# Add: 0 0 * * * /usr/local/bin/renew-ssl.sh
```

---

## GCP Deployment

### Option A: Cloud Run + Cloud SQL + Elasticsearch

#### Prerequisites
- GCP Account with billing enabled
- gcloud CLI installed

#### Step 1: Create Cloud SQL Instance

```bash
# Create PostgreSQL instance
gcloud sql instances create akdamia-db \
  --database-version POSTGRES_14 \
  --tier db-f1-micro \
  --region us-central1 \
  --backup \
  --enable-bin-log

# Create database
gcloud sql databases create akdamia \
  --instance=akdamia-db

# Create user
gcloud sql users create postgres --instance=akdamia-db --password
```

#### Step 2: Build and Push Docker Image

```bash
# Build image
docker build -t us-central1-docker.pkg.dev/your-project/akdamia/web .

# Push to Artifact Registry
docker push us-central1-docker.pkg.dev/your-project/akdamia/web
```

#### Step 3: Deploy to Cloud Run

```bash
# Deploy service
gcloud run deploy akdamia-web \
  --image us-central1-docker.pkg.dev/your-project/akdamia/web \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars \
    "SECRET_KEY=your-secret-key,\
    DEBUG=False,\
    DB_NAME=akdamia,\
    DB_USER=postgres,\
    DB_PASSWORD=your-password,\
    DB_HOST=your-cloud-sql-ip,\
    DB_PORT=5432,\
    ELASTICSEARCH_HOST=your-elastic-endpoint:9200" \
  --add-cloudsql-instances your-project:us-central1:akdamia-db \
  --cpu 2 \
  --memory 512Mi \
  --timeout 3600
```

#### Step 4: Setup Domain

```bash
# Map custom domain
gcloud run services update-traffic akdamia-web \
  --platform managed \
  --region us-central1 \
  --update-routes \
    yourdomain.com=100
```

---

## Production Checklist

Before going live, verify:

### Security
- [ ] `DEBUG=False` in production environment
- [ ] `SECRET_KEY` is a strong, random value
- [ ] `ALLOWED_HOSTS` configured correctly
- [ ] HTTPS/SSL enabled
- [ ] Database credentials in secrets, not code
- [ ] Elasticsearch authentication configured
- [ ] Firewall rules restrict access appropriately
- [ ] Regular security updates applied
- [ ] Backups tested and working

### Performance
- [ ] Database indexes created
- [ ] Elasticsearch cluster configured with 3+ nodes
- [ ] Redis caching enabled
- [ ] Static files served by CDN
- [ ] Gzip compression enabled in Nginx
- [ ] Database connection pooling configured
- [ ] Load testing completed (minimum 1000 concurrent users)

### Monitoring & Logging
- [ ] Error tracking (Sentry or similar) configured
- [ ] Application logging to persistent storage
- [ ] Database backups automated (daily minimum)
- [ ] Elasticsearch backups configured
- [ ] Health checks configured
- [ ] Uptime monitoring enabled
- [ ] Alerts configured for critical issues

### Data & Compliance
- [ ] Data backup strategy tested
- [ ] GDPR compliance reviewed (if applicable)
- [ ] Terms of Service and Privacy Policy in place
- [ ] API rate limiting configured
- [ ] User data encryption at rest
- [ ] Audit logging enabled

### Deployment
- [ ] CI/CD pipeline working
- [ ] Blue/green deployment configured
- [ ] Rollback procedure documented and tested
- [ ] Staging environment mirrors production
- [ ] Database migration scripts tested
- [ ] Zero-downtime deployment process

### Documentation
- [ ] Architecture documentation complete
- [ ] API documentation accessible
- [ ] Runbooks for common issues
- [ ] Disaster recovery plan documented
- [ ] On-call procedures documented

---

## Post-Deployment Tasks

### Immediate (Day 1)
- [ ] Verify all endpoints working
- [ ] Test search functionality
- [ ] Check admin panel access
- [ ] Monitor error logs
- [ ] Verify backups running

### First Week
- [ ] Monitor performance metrics
- [ ] Review access logs
- [ ] Run security scan
- [ ] Test failover procedures
- [ ] Verify monitoring alerts

### Ongoing
- [ ] Weekly backup verification
- [ ] Monthly security updates
- [ ] Quarterly performance reviews
- [ ] Annual disaster recovery test

---

## Troubleshooting

### Application Won't Start
```bash
# Check logs
docker-compose logs web

# Verify environment variables
docker-compose config

# Check database connectivity
docker-compose exec web python manage.py dbshell

# Check Elasticsearch
curl http://elasticsearch:9200/_health
```

### Database Connection Error
```bash
# Verify credentials
echo $DB_USER $DB_PASSWORD

# Test connection
psql -h $DB_HOST -U $DB_USER -d $DB_NAME

# Check network connectivity
nc -zv $DB_HOST $DB_PORT
```

### Elasticsearch Not Working
```bash
# Check cluster health
curl http://elasticsearch:9200/_cluster/health

# Check indices
curl http://elasticsearch:9200/_cat/indices

# Rebuild index
docker-compose exec web python manage.py search_index --rebuild
```

### Static Files Not Loading
```bash
# Collect static files
docker-compose exec web python manage.py collectstatic --noinput

# Check Nginx configuration
docker-compose exec nginx nginx -t

# Verify permissions
docker-compose exec web ls -la /app/staticfiles
```

---

**Deployment Guide Complete!** 🚀

For more information, see the main README.md and DEVELOPMENT_GUIDE.md
