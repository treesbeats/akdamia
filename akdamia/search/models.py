from django.db import models
from django.utils.text import slugify
from django.urls import reverse
from django.core.validators import URLValidator
from django.db.models import Q


class TimeStampedModel(models.Model):
    """Abstract base model with timestamps."""
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        abstract = True


class Author(TimeStampedModel):
    """Model for academic authors."""
    name = models.CharField(max_length=200, unique=True, db_index=True)
    slug = models.SlugField(max_length=200, unique=True)
    bio = models.TextField(blank=True, null=True)
    orcid = models.CharField(max_length=50, blank=True, null=True, unique=True)
    email = models.EmailField(blank=True, null=True)
    url = models.URLField(blank=True, null=True)
    
    class Meta:
        ordering = ['name']
        verbose_name = 'Author'
        verbose_name_plural = 'Authors'
        indexes = [
            models.Index(fields=['name']),
            models.Index(fields=['slug']),
        ]
    
    def __str__(self):
        return self.name
    
    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)
    
    def get_absolute_url(self):
        return reverse('search:author_detail', kwargs={'slug': self.slug})


class Journal(TimeStampedModel):
    """Model for journals/publications."""
    name = models.CharField(max_length=300, unique=True, db_index=True)
    slug = models.SlugField(max_length=300, unique=True)
    issn = models.CharField(max_length=20, blank=True, null=True, unique=True)
    eissn = models.CharField(max_length=20, blank=True, null=True, unique=True)
    url = models.URLField(blank=True, null=True)
    description = models.TextField(blank=True, null=True)
    impact_factor = models.FloatField(blank=True, null=True)
    
    class Meta:
        ordering = ['name']
        verbose_name = 'Journal'
        verbose_name_plural = 'Journals'
        indexes = [
            models.Index(fields=['name']),
            models.Index(fields=['slug']),
        ]
    
    def __str__(self):
        return self.name
    
    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)
    
    def get_absolute_url(self):
        return reverse('search:journal_detail', kwargs={'slug': self.slug})


class Citation(TimeStampedModel):
    """Model for academic citations."""
    title = models.CharField(max_length=500, db_index=True)
    abstract = models.TextField(blank=True, null=True)
    authors = models.ManyToManyField(Author, related_name='citations', blank=True)
    year = models.IntegerField(blank=True, null=True, db_index=True)
    journal = models.ForeignKey(
        Journal,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='citations'
    )
    
    # Metadata
    doi = models.CharField(max_length=100, blank=True, null=True, unique=True, db_index=True)
    pubmed_id = models.CharField(max_length=50, blank=True, null=True, unique=True)
    arXiv_id = models.CharField(max_length=50, blank=True, null=True, unique=True)
    
    # URLs and access
    url = models.URLField(blank=True, null=True)
    pdf_url = models.URLField(blank=True, null=True)
    
    # Content
    keywords = models.TextField(
        blank=True,
        null=True,
        help_text="Semicolon-separated keywords"
    )
    pages = models.CharField(max_length=50, blank=True, null=True)
    volume = models.CharField(max_length=50, blank=True, null=True)
    issue = models.CharField(max_length=50, blank=True, null=True)
    
    # Citation metadata
    citation_count = models.IntegerField(default=0, db_index=True)
    is_published = models.BooleanField(default=True, db_index=True)
    language = models.CharField(
        max_length=10,
        default='en',
        choices=[
            ('en', 'English'),
            ('es', 'Spanish'),
            ('fr', 'French'),
            ('de', 'German'),
            ('zh', 'Chinese'),
            ('ja', 'Japanese'),
            ('pt', 'Portuguese'),
            ('ru', 'Russian'),
            ('other', 'Other'),
        ]
    )
    
    class Meta:
        ordering = ['-year', '-created_at']
        verbose_name = 'Citation'
        verbose_name_plural = 'Citations'
        indexes = [
            models.Index(fields=['title']),
            models.Index(fields=['doi']),
            models.Index(fields=['year']),
            models.Index(fields=['is_published']),
            models.Index(fields=['-citation_count']),
        ]
    
    def __str__(self):
        return self.title[:100]
    
    def get_absolute_url(self):
        return reverse('search:citation_detail', kwargs={'pk': self.pk})
    
    def get_authors_display(self):
        """Return comma-separated authors."""
        return ', '.join([a.name for a in self.authors.all()])
    
    def get_keywords_list(self):
        """Return keywords as a list."""
        if self.keywords:
            return [k.strip() for k in self.keywords.split(';')]
        return []
    
    def get_citation_formatted(self, style='apa'):
        """
        Return formatted citation in requested style.
        Supports: apa, chicago, harvard, mla
        """
        authors = self.get_authors_display()
        title = self.title
        journal = self.journal.name if self.journal else 'Unknown'
        year = self.year or 'n.d.'
        
        if style == 'apa':
            return f"{authors} ({year}). {title}. {journal}."
        elif style == 'chicago':
            return f"{authors}. \"{title}.\" {journal}, {year}."
        elif style == 'harvard':
            return f"{authors} {year}, '{title}', {journal}."
        elif style == 'mla':
            return f"{authors}. \"{title}.\" {journal}, {year}."
        else:
            return f"{authors} ({year}). {title}. {journal}."
    
    @classmethod
    def search(cls, query):
        """Simple search across citation fields."""
        return cls.objects.filter(
            Q(title__icontains=query) |
            Q(abstract__icontains=query) |
            Q(keywords__icontains=query)
        ).filter(is_published=True)


class Mention(TimeStampedModel):
    """Model for tracking mentions of citations."""
    citation = models.ForeignKey(
        Citation,
        on_delete=models.CASCADE,
        related_name='mentions'
    )
    source_title = models.CharField(max_length=500)
    source_url = models.URLField(blank=True, null=True)
    mentioned_date = models.DateField(blank=True, null=True)
    context = models.TextField(blank=True, null=True, help_text="Context where citation was mentioned")
    source_type = models.CharField(
        max_length=20,
        choices=[
            ('article', 'Article'),
            ('blog', 'Blog Post'),
            ('news', 'News'),
            ('social', 'Social Media'),
            ('paper', 'Paper'),
            ('other', 'Other'),
        ],
        default='article'
    )
    
    class Meta:
        ordering = ['-mentioned_date']
        verbose_name = 'Mention'
        verbose_name_plural = 'Mentions'
        indexes = [
            models.Index(fields=['citation']),
            models.Index(fields=['source_type']),
            models.Index(fields=['-mentioned_date']),
        ]
    
    def __str__(self):
        return f"Mention of {self.citation.title[:50]} in {self.source_title}"


class SearchLog(models.Model):
    """Model for logging searches (analytics)."""
    query = models.CharField(max_length=500)
    results_count = models.IntegerField(default=0)
    clicked_result = models.ForeignKey(
        Citation,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='search_logs'
    )
    timestamp = models.DateTimeField(auto_now_add=True, db_index=True)
    user_agent = models.TextField(blank=True, null=True)
    ip_address = models.GenericIPAddressField(blank=True, null=True)
    
    class Meta:
        ordering = ['-timestamp']
        verbose_name = 'Search Log'
        verbose_name_plural = 'Search Logs'
        indexes = [
            models.Index(fields=['query']),
            models.Index(fields=['-timestamp']),
        ]
    
    def __str__(self):
        return f"Search: {self.query}"
