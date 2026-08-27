# URL Configuration for akdamia
# For akdamia/akdamia/urls.py

from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from search import views as search_views

app_name = 'search'

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # Home and search
    path('', search_views.index, name='index'),
    path('search/', search_views.index, name='search'),
    path('citation/<int:citation_id>/', search_views.citation_detail, name='citation_detail'),
    
    # API endpoints
    path('api/search/', search_views.search_api, name='search_api'),
    path('api/advanced-search/', search_views.advanced_search_api, name='advanced_search_api'),
    
    # REST Framework
    path('api-auth/', include('rest_framework.urls')),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
