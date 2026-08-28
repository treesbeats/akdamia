#!/bin/bash
set -e

echo "🚀 Starting akdamia Django application..."

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
while ! nc -z ${DB_HOST:-localhost} ${DB_PORT:-5432}; do
  echo "   PostgreSQL not ready, waiting..."
  sleep 2
done
echo "✓ PostgreSQL is ready"

# Wait for Elasticsearch to be ready
echo "⏳ Waiting for Elasticsearch to be ready..."
while ! curl -s -f http://${ELASTICSEARCH_HOST:-localhost:9200}/_cluster/health > /dev/null 2>&1; do
  echo "   Elasticsearch not ready, waiting..."
  sleep 2
done
echo "✓ Elasticsearch is ready"

# Run migrations
echo "🔄 Running database migrations..."
python manage.py migrate --noinput || true

# Load sample data if LOAD_SAMPLE_DATA is set
if [ "${LOAD_SAMPLE_DATA}" = "true" ]; then
  echo "📚 Loading sample data..."
  python manage.py load_sample 2>/dev/null || echo "   Sample data already loaded or command not available"
fi

# Create superuser if DJANGO_SUPERUSER_USERNAME is set
if [ -n "${DJANGO_SUPERUSER_USERNAME}" ]; then
  echo "👤 Creating superuser..."
  python manage.py createsuperuser --noinput 2>/dev/null || echo "   Superuser already exists"
fi

# Collect static files
echo "📦 Collecting static files..."
python manage.py collectstatic --noinput --clear

echo "✓ Initialization complete!"
echo "🌐 Starting Django development server on 0.0.0.0:8000..."

# Start Django
exec "$@"
