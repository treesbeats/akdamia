# Django management command to load sample data
# Place this in akdamia/search/management/commands/load_sample.py

import json
from django.core.management.base import BaseCommand
from django.utils.text import slugify
from search.models import Citation, Author, Journal


class Command(BaseCommand):
    help = 'Load sample citations data from sample_citations.json'

    def add_arguments(self, parser):
        parser.add_argument(
            '--file',
            type=str,
            default='sample_citations.json',
            help='Path to the sample citations JSON file'
        )

    def handle(self, *args, **options):
        file_path = options['file']
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
        except FileNotFoundError:
            self.stdout.write(self.style.ERROR(f'File not found: {file_path}'))
            return
        except json.JSONDecodeError:
            self.stdout.write(self.style.ERROR(f'Invalid JSON in: {file_path}'))
            return

        citations = data if isinstance(data, list) else data.get('citations', [])
        
        if not citations:
            self.stdout.write(self.style.WARNING('No citations found in file'))
            return

        created_count = 0
        updated_count = 0
        error_count = 0

        for citation_data in citations:
            try:
                # Get or create journal
                journal_name = citation_data.get('journal') or citation_data.get('source') or 'Unknown Journal'
                journal, _ = Journal.objects.get_or_create(
                    name=journal_name,
                    defaults={'slug': slugify(journal_name)}
                )

                # Create or update citation
                citation, created = Citation.objects.update_or_create(
                    title=citation_data.get('title', 'Untitled'),
                    defaults={
                        'abstract': citation_data.get('abstract', ''),
                        'year': citation_data.get('year'),
                        'journal': journal,
                        'doi': citation_data.get('doi', ''),
                        'url': citation_data.get('url', ''),
                        'keywords': ';'.join(citation_data.get('keywords', [])) if isinstance(citation_data.get('keywords'), list) else citation_data.get('keywords', ''),
                    }
                )

                # Add authors
                authors_text = citation_data.get('authors', '')
                if authors_text:
                    if isinstance(authors_text, list):
                        author_names = authors_text
                    else:
                        author_names = [a.strip() for a in authors_text.split(';')]
                    
                    for author_name in author_names:
                        if author_name:
                            author, _ = Author.objects.get_or_create(
                                name=author_name,
                                defaults={'slug': slugify(author_name)}
                            )
                            citation.authors.add(author)

                if created:
                    created_count += 1
                else:
                    updated_count += 1
                
                self.stdout.write(
                    self.style.SUCCESS(f'{"✓" if created else "↻"} {citation.title[:60]}'[:70])
                )

            except Exception as e:
                error_count += 1
                self.stdout.write(
                    self.style.ERROR(f'✗ Error loading citation: {str(e)[:100]}')
                )

        # Summary
        self.stdout.write('\n' + '='*70)
        self.stdout.write(self.style.SUCCESS(f'✓ Created: {created_count}'))
        self.stdout.write(self.style.WARNING(f'↻ Updated: {updated_count}'))
        if error_count:
            self.stdout.write(self.style.ERROR(f'✗ Errors: {error_count}'))
        
        total = created_count + updated_count
        self.stdout.write(self.style.SUCCESS(f'\n✓ Successfully processed {total} citations'))
