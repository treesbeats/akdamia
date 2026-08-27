# Django views for the search app with API endpoint
# Place this in akdamia/search/views.py

from django.shortcuts import render, get_object_or_404
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from django.db.models import Q
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from django.core.exceptions import ObjectDoesNotExist
import logging

try:
    from elasticsearch_dsl import Search
    from elasticsearch.exceptions import ConnectionError as ElasticsearchConnectionError
    HAS_ELASTICSEARCH = True
except ImportError:
    HAS_ELASTICSEARCH = False

from .models import Citation, Author

logger = logging.getLogger(__name__)


def index(request):
    """Home page with search interface."""
    return render(request, 'search/base.html')


@require_http_methods(["GET"])
def search_api(request):
    """
    REST API endpoint for citation search.
    
    Query Parameters:
        q: Search query string (required)
        page: Page number (default 1)
        limit: Results per page (default 20, max 100)
    
    Returns JSON with results, count, and pagination info.
    """
    query = request.GET.get('q', '').strip()
    
    try:
        page = int(request.GET.get('page', 1))
        limit = min(int(request.GET.get('limit', 20)), 100)  # Max 100 per page
    except (ValueError, TypeError):
        page = 1
        limit = 20
    
    if not query or len(query) < 2:
        return JsonResponse({
            'results': [],
            'count': 0,
            'page': page,
            'total_pages': 0,
            'error': 'Search query must be at least 2 characters'
        }, status=400)
    
    try:
        # Try Elasticsearch first if available
        if HAS_ELASTICSEARCH:
            return _search_elasticsearch(query, page, limit)
    except Exception as es_error:
        logger.warning(f"Elasticsearch error: {str(es_error)}")
    
    # Fallback to Django ORM
    return _search_database(query, page, limit)


def _search_elasticsearch(query, page, limit):
    """Search using Elasticsearch."""
    try:
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
            try:
                results.append({
                    'id': hit.meta.id,
                    'title': getattr(hit, 'title', 'Untitled'),
                    'authors': getattr(hit, 'authors', 'Unknown'),
                    'year': getattr(hit, 'year', None),
                    'journal': getattr(hit, 'source', 'Unknown'),
                    'abstract': getattr(hit, 'abstract', None),
                    'keywords': getattr(hit, 'keywords', []),
                    'doi': getattr(hit, 'doi', None),
                    'url': getattr(hit, 'url', None),
                })
            except Exception as e:
                logger.error(f"Error processing search result: {str(e)}")
                continue
        
        # Get total count
        total_count = response.hits.total
        if hasattr(total_count, 'value'):
            total_count = total_count.value
        
        total_pages = (total_count + limit - 1) // limit if total_count else 0
        
        return JsonResponse({
            'results': results,
            'count': total_count,
            'page': page,
            'total_pages': total_pages,
            'limit': limit,
            'search_engine': 'elasticsearch'
        })
    
    except ElasticsearchConnectionError as e:
        logger.error(f"Elasticsearch connection failed: {str(e)}")
        raise
    except Exception as e:
        logger.error(f"Elasticsearch search error: {str(e)}")
        raise


def _search_database(query, page, limit):
    """Search using Django ORM (fallback)."""
    try:
        # Search in multiple fields
        citations = Citation.objects.filter(
            Q(title__icontains=query) |
            Q(abstract__icontains=query) |
            Q(keywords__icontains=query)
        ).select_related('journal').prefetch_related('authors').distinct()
        
        # Paginate results
        paginator = Paginator(citations, limit)
        
        try:
            paginated_results = paginator.page(page)
        except PageNotAnInteger:
            paginated_results = paginator.page(1)
            page = 1
        except EmptyPage:
            paginated_results = paginator.page(paginator.num_pages)
            page = paginator.num_pages
        
        # Format results
        results = []
        for citation in paginated_results:
            results.append({
                'id': str(citation.id),
                'title': citation.title,
                'authors': ', '.join([a.name for a in citation.authors.all()]) if citation.authors.exists() else 'Unknown',
                'year': citation.year,
                'journal': citation.journal.name if citation.journal else 'Unknown',
                'abstract': citation.abstract,
                'keywords': citation.keywords.split(';') if citation.keywords else [],
                'doi': citation.doi,
                'url': citation.url,
            })
        
        return JsonResponse({
            'results': results,
            'count': paginator.count,
            'page': page,
            'total_pages': paginator.num_pages,
            'limit': limit,
            'search_engine': 'database'
        })
    
    except Exception as e:
        logger.error(f"Database search error: {str(e)}")
        return JsonResponse({
            'results': [],
            'count': 0,
            'error': 'Search service temporarily unavailable'
        }, status=503)


def citation_detail(request, citation_id):
    """Display detailed view of a single citation."""
    try:
        citation = get_object_or_404(Citation, id=citation_id)
        
        return render(request, 'search/citation_detail.html', {
            'citation': citation,
            'authors': citation.authors.all(),
        })
    except ObjectDoesNotExist:
        return render(request, 'search/404.html', {
            'message': 'Citation not found'
        }, status=404)
    except Exception as e:
        logger.error(f"Citation detail error: {str(e)}")
        return JsonResponse({
            'error': 'Error loading citation'
        }, status=500)


def advanced_search(request):
    """Advanced search page with filters."""
    return render(request, 'search/advanced_search.html')


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
        page: Page number (default 1)
        limit: Results per page (default 20)
    """
    try:
        page = int(request.GET.get('page', 1))
        limit = min(int(request.GET.get('limit', 20)), 100)
    except (ValueError, TypeError):
        page = 1
        limit = 20
    
    try:
        # Try Elasticsearch first if available
        if HAS_ELASTICSEARCH:
            return _advanced_search_elasticsearch(request, page, limit)
    except Exception as es_error:
        logger.warning(f"Elasticsearch error in advanced search: {str(es_error)}")
    
    # Fallback to Django ORM
    return _advanced_search_database(request, page, limit)


def _advanced_search_elasticsearch(request, page, limit):
    """Advanced search using Elasticsearch."""
    try:
        s = Search()
        
        # Apply filters
        title = request.GET.get('title', '').strip()
        if title:
            s = s.query('match', title=title)
        
        authors = request.GET.get('authors', '').strip()
        if authors:
            s = s.query('match', authors=authors)
        
        journal = request.GET.get('journal', '').strip()
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
        
        # Add pagination
        start = (page - 1) * limit
        s = s[start:start + limit]
        
        # Execute search
        response = s.execute()
        
        results = []
        for hit in response:
            results.append({
                'id': hit.meta.id,
                'title': getattr(hit, 'title', 'Untitled'),
                'authors': getattr(hit, 'authors', 'Unknown'),
                'year': getattr(hit, 'year', None),
                'journal': getattr(hit, 'source', 'Unknown'),
                'abstract': getattr(hit, 'abstract', None),
            })
        
        total_count = response.hits.total
        if hasattr(total_count, 'value'):
            total_count = total_count.value
        
        total_pages = (total_count + limit - 1) // limit if total_count else 0
        
        return JsonResponse({
            'results': results,
            'count': total_count,
            'page': page,
            'total_pages': total_pages,
            'limit': limit
        })
    
    except Exception as e:
        logger.error(f"Elasticsearch advanced search error: {str(e)}")
        raise


def _advanced_search_database(request, page, limit):
    """Advanced search using Django ORM (fallback)."""
    try:
        # Start with all citations
        q_objects = Q()
        
        # Apply filters
        title = request.GET.get('title', '').strip()
        if title:
            q_objects &= Q(title__icontains=title)
        
        authors = request.GET.get('authors', '').strip()
        if authors:
            q_objects &= Q(authors__name__icontains=authors)
        
        journal = request.GET.get('journal', '').strip()
        if journal:
            q_objects &= Q(journal__name__icontains=journal)
        
        year_from = request.GET.get('year_from')
        if year_from:
            q_objects &= Q(year__gte=int(year_from))
        
        year_to = request.GET.get('year_to')
        if year_to:
            q_objects &= Q(year__lte=int(year_to))
        
        # Execute search
        citations = Citation.objects.filter(q_objects).select_related('journal').prefetch_related('authors').distinct()
        
        # Paginate
        paginator = Paginator(citations, limit)
        
        try:
            paginated_results = paginator.page(page)
        except PageNotAnInteger:
            paginated_results = paginator.page(1)
            page = 1
        except EmptyPage:
            paginated_results = paginator.page(paginator.num_pages)
            page = paginator.num_pages
        
        results = []
        for citation in paginated_results:
            results.append({
                'id': str(citation.id),
                'title': citation.title,
                'authors': ', '.join([a.name for a in citation.authors.all()]) if citation.authors.exists() else 'Unknown',
                'year': citation.year,
                'journal': citation.journal.name if citation.journal else 'Unknown',
                'abstract': citation.abstract,
            })
        
        return JsonResponse({
            'results': results,
            'count': paginator.count,
            'page': page,
            'total_pages': paginator.num_pages,
            'limit': limit
        })
    
    except ValueError as e:
        logger.error(f"Invalid parameter in advanced search: {str(e)}")
        return JsonResponse({
            'error': 'Invalid search parameters'
        }, status=400)
    except Exception as e:
        logger.error(f"Advanced search error: {str(e)}")
        return JsonResponse({
            'error': 'Search service temporarily unavailable'
        }, status=503)
