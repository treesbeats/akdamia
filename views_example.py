# Django views for the search app with API endpoint
# Place this in akdamia/search/views.py

from django.shortcuts import render, get_object_or_404
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from django.db.models import Q
from django.core.paginator import Paginator
from elasticsearch_dsl import Search
import json

from .models import Citation, Author


def index(request):
    """Home page with search interface."""
    return render(request, 'base.html')


@require_http_methods(["GET"])
def search_api(request):
    """
    REST API endpoint for citation search.
    
    Query Parameters:
        q: Search query string
        page: Page number (default 1)
        limit: Results per page (default 20)
    
    Returns JSON with results, count, and pagination info.
    """
    query = request.GET.get('q', '').strip()
    page = int(request.GET.get('page', 1))
    limit = int(request.GET.get('limit', 20))
    
    if not query:
        return JsonResponse({
            'results': [],
            'count': 0,
            'page': page,
            'total_pages': 0,
            'error': 'Search query required'
        }, status=400)
    
    try:
        # Use Elasticsearch for full-text search
        s = Search()
        
        # Search across title, authors, abstract, and keywords
        s = s.query('multi_match', query=query, fields=[
            'title^3',  # Boost title matches
            'authors^2',
            'abstract',
            'keywords',
            'source'
        ])
        
        # Add pagination
        start = (page - 1) * limit
        s = s[start:start + limit]
        
        # Execute search
        response = s.execute()
        
        # Format results
        results = []
        for hit in response:
            results.append({
                'id': hit.meta.id,
                'title': hit.title,
                'authors': hit.authors if hasattr(hit, 'authors') else 'Unknown',
                'year': hit.year if hasattr(hit, 'year') else None,
                'journal': hit.source if hasattr(hit, 'source') else 'Unknown',
                'abstract': hit.abstract if hasattr(hit, 'abstract') else None,
                'keywords': hit.keywords if hasattr(hit, 'keywords') else [],
                'doi': hit.doi if hasattr(hit, 'doi') else None,
                'url': hit.url if hasattr(hit, 'url') else None,
            })
        
        total_count = response.hits.total.value if hasattr(response.hits.total, 'value') else response.hits.total
        total_pages = (total_count + limit - 1) // limit
        
        return JsonResponse({
            'results': results,
            'count': total_count,
            'page': page,
            'total_pages': total_pages,
            'limit': limit
        })
    
    except Exception as e:
        print(f"Search error: {str(e)}")
        
        # Fallback to Django ORM search if Elasticsearch fails
        try:
            citations = Citation.objects.filter(
                Q(title__icontains=query) |
                Q(abstract__icontains=query) |
                Q(keywords__icontains=query)
            ).select_related('journal')[:limit]
            
            results = [{
                'id': str(c.id),
                'title': c.title,
                'authors': ', '.join([a.name for a in c.authors.all()]) if c.authors.exists() else 'Unknown',
                'year': c.year,
                'journal': c.journal.name if c.journal else 'Unknown',
                'abstract': c.abstract,
                'keywords': c.keywords.split(';') if c.keywords else [],
                'doi': c.doi,
                'url': c.url,
            } for c in citations]
            
            return JsonResponse({
                'results': results,
                'count': len(results),
                'page': page,
                'total_pages': 1,
                'limit': limit,
                'note': 'Using database search (Elasticsearch unavailable)'
            })
        
        except Exception as db_error:
            print(f"Database search error: {str(db_error)}")
            return JsonResponse({
                'results': [],
                'count': 0,
                'error': 'Search service temporarily unavailable'
            }, status=503)


def citation_detail(request, citation_id):
    """Display detailed view of a single citation."""
    citation = get_object_or_404(Citation, id=citation_id)
    
    return render(request, 'citation_detail.html', {
        'citation': citation,
        'authors': citation.authors.all(),
    })


def advanced_search(request):
    """Advanced search page with filters."""
    return render(request, 'advanced_search.html')


@require_http_methods(["GET"])
def advanced_search_api(request):
    """
    Advanced search with filtering.
    
    Query Parameters:
        title: Search in title
        authors: Search in authors
        year_from: Starting year
        year_to: Ending year
        journal: Journal/Source name
        keywords: Keywords filter
    """
    try:
        s = Search()
        
        # Apply filters
        title = request.GET.get('title')
        if title:
            s = s.query('match', title=title)
        
        authors = request.GET.get('authors')
        if authors:
            s = s.query('match', authors=authors)
        
        journal = request.GET.get('journal')
        if journal:
            s = s.filter('match', source=journal)
        
        year_from = request.GET.get('year_from')
        year_to = request.GET.get('year_to')
        if year_from or year_to:
            year_filter = {}
            if year_from:
                year_filter['gte'] = int(year_from)
            if year_to:
                year_filter['lte'] = int(year_to)
            s = s.filter('range', year=year_filter)
        
        # Execute search
        response = s.execute()
        
        results = []
        for hit in response:
            results.append({
                'id': hit.meta.id,
                'title': hit.title,
                'authors': hit.authors if hasattr(hit, 'authors') else 'Unknown',
                'year': hit.year if hasattr(hit, 'year') else None,
                'journal': hit.source if hasattr(hit, 'source') else 'Unknown',
                'abstract': hit.abstract if hasattr(hit, 'abstract') else None,
            })
        
        return JsonResponse({
            'results': results,
            'count': len(results)
        })
    
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)
