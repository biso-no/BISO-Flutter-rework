#!/usr/bin/env python3
"""
Automated Print Statement Migration Script for Flutter

This script helps migrate hundreds of print() statements to the new logging system.
Run this in phases to gradually improve your logging.

Usage:
    python scripts/migrate_prints.py --phase 1
    python scripts/migrate_prints.py --phase 2
    python scripts/migrate_prints.py --phase 3
"""

import os
import re
import argparse
import shutil
from pathlib import Path

class PrintMigrator:
    def __init__(self, project_root="lib"):
        self.project_root = Path(project_root)
        self.backup_dir = Path("backup_before_migration")
        
    def create_backup(self):
        """Create backup of lib folder before migration"""
        if self.backup_dir.exists():
            shutil.rmtree(self.backup_dir)
        shutil.copytree(self.project_root, self.backup_dir)
        print(f"[OK] Created backup at {self.backup_dir}")
    
    def find_dart_files(self):
        """Find all .dart files in the project"""
        return list(self.project_root.rglob("*.dart"))
    
    def phase_1_basic_replacement(self):
        """Phase 1: Replace print( with logPrint("""
        print("[PHASE 1] Basic print() -> logPrint() replacement")
        
        files_modified = 0
        replacements_made = 0
        
        for dart_file in self.find_dart_files():
            with open(dart_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Count print statements
            print_count = len(re.findall(r'\bprint\s*\(', content))
            if print_count == 0:
                continue
                
            # Replace print( with logPrint(
            new_content = re.sub(r'\bprint\s*\(', 'logPrint(', content)
            
            # Add import if logPrint is used and import doesn't exist
            if 'logPrint(' in new_content and 'print_migration.dart' not in content:
                # Find existing imports
                import_match = re.search(r'(import\s+[^;]+;\s*\n)*', new_content)
                if import_match:
                    # Add our import after existing imports
                    imports_end = import_match.end()
                    new_content = (new_content[:imports_end] + 
                                 "import '../../core/logging/print_migration.dart';\n" +
                                 new_content[imports_end:])
            
            # Write back if changed
            if new_content != content:
                with open(dart_file, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                files_modified += 1
                replacements_made += print_count
                print(f"  [FILE] {dart_file.relative_to(self.project_root)}: {print_count} replacements")
        
        print(f"[OK] Phase 1 complete: {files_modified} files, {replacements_made} print statements migrated")
        
    def phase_2_categorize_logs(self):
        """Phase 2: Identify and categorize common logging patterns"""
        print("[PHASE 2] Categorizing log patterns")
        
        patterns = {
            'auth': [r'login', r'logout', r'auth', r'token', r'otp', r'user.*logged'],
            'api': [r'api', r'http', r'request', r'response', r'endpoint', r'status.*code'],
            'chat': [r'chat', r'message', r'conversation'],
            'expense': [r'expense', r'reimbursement', r'receipt'],
            'error': [r'error', r'exception', r'failed', r'fail'],
            'warning': [r'warning', r'warn', r'potential.*issue'],
        }
        
        suggestions = []
        
        for dart_file in self.find_dart_files():
            with open(dart_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Find logPrint statements
            log_prints = re.findall(r'logPrint\([^)]+\)', content)
            
            for log_print in log_prints:
                log_content = log_print.lower()
                
                for category, category_patterns in patterns.items():
                    for pattern in category_patterns:
                        if re.search(pattern, log_content):
                            suggestions.append({
                                'file': dart_file.relative_to(self.project_root),
                                'line': log_print,
                                'category': category,
                                'suggested': f'log{category.capitalize()}(...)'
                            })
                            break
        
        # Write suggestions to file
        with open('migration_suggestions.txt', 'w') as f:
            f.write("PRINT MIGRATION SUGGESTIONS\n")
            f.write("=" * 50 + "\n\n")
            
            for suggestion in suggestions:
                f.write(f"File: {suggestion['file']}\n")
                f.write(f"Current: {suggestion['line']}\n")
                f.write(f"Suggested: {suggestion['suggested']}\n")
                f.write("-" * 30 + "\n")
        
        print(f"[OK] Phase 2 complete: {len(suggestions)} suggestions written to migration_suggestions.txt")
    
    def phase_3_smart_replacements(self):
        """Phase 3: Smart replacements for common patterns"""
        print("[PHASE 3] Smart pattern replacements")
        
        replacements = {
            # Error patterns
            r'logPrint\(["\']([^"\']*(?:error|failed|exception)[^"\']*)["\']': r'logError("\1"',
            r'logPrint\(["\']([^"\']*(?:warning|warn)[^"\']*)["\']': r'logWarning("\1"',
            
            # Auth patterns
            r'logPrint\(["\']([^"\']*(?:login|logout|auth|token)[^"\']*)["\']': r'logAuth("\1"',
            
            # API patterns  
            r'logPrint\(["\']([^"\']*(?:api|http|request|response)[^"\']*)["\']': r'logApi("\1"',
        }
        
        files_modified = 0
        total_replacements = 0
        
        for dart_file in self.find_dart_files():
            with open(dart_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            file_replacements = 0
            
            for pattern, replacement in replacements.items():
                matches = re.findall(pattern, content, re.IGNORECASE)
                if matches:
                    content = re.sub(pattern, replacement, content, flags=re.IGNORECASE)
                    file_replacements += len(matches)
            
            if content != original_content:
                with open(dart_file, 'w', encoding='utf-8') as f:
                    f.write(content)
                files_modified += 1
                total_replacements += file_replacements
                print(f"  [FILE] {dart_file.relative_to(self.project_root)}: {file_replacements} smart replacements")
        
        print(f"[OK] Phase 3 complete: {files_modified} files, {total_replacements} smart replacements")
    
    def analyze_remaining_prints(self):
        """Analyze what print statements remain"""
        print("[ANALYZE] Analyzing remaining print statements...")
        
        remaining_prints = []
        
        for dart_file in self.find_dart_files():
            with open(dart_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            for i, line in enumerate(lines, 1):
                if re.search(r'\bprint\s*\(', line):
                    remaining_prints.append({
                        'file': dart_file.relative_to(self.project_root),
                        'line_num': i,
                        'content': line.strip()
                    })
        
        if remaining_prints:
            print(f"[WARNING] Found {len(remaining_prints)} remaining print statements:")
            for item in remaining_prints[:10]:  # Show first 10
                print(f"  {item['file']}:{item['line_num']} - {item['content']}")
            
            if len(remaining_prints) > 10:
                print(f"  ... and {len(remaining_prints) - 10} more")
        else:
            print("[OK] No remaining print statements found!")
        
        return len(remaining_prints)

def main():
    parser = argparse.ArgumentParser(description='Migrate print statements to new logging system')
    parser.add_argument('--phase', type=int, choices=[1, 2, 3], 
                       help='Migration phase to run')
    parser.add_argument('--analyze', action='store_true',
                       help='Analyze remaining print statements')
    parser.add_argument('--backup', action='store_true',
                       help='Create backup before migration')
    
    args = parser.parse_args()
    
    migrator = PrintMigrator()
    
    if args.backup or args.phase:
        migrator.create_backup()
    
    if args.phase == 1:
        migrator.phase_1_basic_replacement()
    elif args.phase == 2:
        migrator.phase_2_categorize_logs()
    elif args.phase == 3:
        migrator.phase_3_smart_replacements()
    elif args.analyze:
        migrator.analyze_remaining_prints()
    else:
        print("Usage examples:")
        print("  python scripts/migrate_prints.py --backup")
        print("  python scripts/migrate_prints.py --phase 1")
        print("  python scripts/migrate_prints.py --phase 2") 
        print("  python scripts/migrate_prints.py --phase 3")
        print("  python scripts/migrate_prints.py --analyze")

if __name__ == "__main__":
    main()