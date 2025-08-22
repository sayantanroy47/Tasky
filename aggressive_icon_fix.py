#!/usr/bin/env python3
"""
Aggressive fix for PhosphorIcons issues
"""

import os
import re

def fix_phosphor_icons(file_path):
    """Fix PhosphorIcons in a single file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # 1. Fix PhosphorIcons function calls - add () if missing
        # Match PhosphorIcons.iconName NOT followed by (
        content = re.sub(r'PhosphorIcons\.(\w+)(?!\()', r'PhosphorIcons.\1()', content)
        
        # 2. Fix const contexts that can't have function calls
        # Remove const from constructors using PhosphorIcons
        content = re.sub(r'const\s+([\w]+)\s*\([^)]*PhosphorIcons\.\w+\(\)', 
                        lambda m: m.group(0).replace('const ', ''), content)
        
        # 3. Fix NavigationState const issue 
        content = re.sub(r'state = const NavigationState\(', 'state = NavigationState(', content)
        content = re.sub(r'this\.currentDestination = AppNavigationDestination\.home,', 
                        'this.currentDestination = AppNavigationDestination.home,', content)
        
        # 4. Remove const from static final declarations with PhosphorIcons
        content = re.sub(r'static const (\w+) (\w+) = \1\([^)]*PhosphorIcons\.\w+\(\)', 
                        r'static final \1 \2 = \1(', content)
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        
        return False
        
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def main():
    """Apply aggressive PhosphorIcons fixes"""
    lib_dir = "lib"
    if not os.path.exists(lib_dir):
        print("lib directory not found")
        return
    
    files_fixed = 0
    total_files = 0
    
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                total_files += 1
                
                if fix_phosphor_icons(file_path):
                    files_fixed += 1
                    print(f"Fixed: {file_path}")
    
    print(f"\nProcessed {total_files} Dart files")
    print(f"Fixed {files_fixed} files")

if __name__ == "__main__":
    main()