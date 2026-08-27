web: gunicorn akdamia.wsgi --log-file - --workers 4 --threads 2 --worker-class sync --worker-tmp-dir /dev/shm --max-requests 1000 --max-requests-jitter 50 --timeout 60

release: python manage.py migrate && python manage.py search_index --rebuild

worker: celery -A akdamia worker -l info

beat: celery -A akdamia beat -l info --scheduler django_celery_beat.schedulers:DatabaseScheduler
