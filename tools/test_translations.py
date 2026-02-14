#!/usr/bin/env python3
"""
Test script to show translations for longer localization keys.
"""

import json
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

from localization import FileLoader, TranslationDetector, TranslationGenerator
import logging

# Setup logging
logging.basicConfig(level=logging.WARNING, format='%(message)s')
logger = logging.getLogger(__name__)

def main():
    print("="*80)
    print("TRANSLATION SAMPLES - LONGER KEYS (30+ characters)")
    print("="*80)
    print()
    
    # Load files
    file_loader = FileLoader(logger)
    localizable_data = file_loader.load_localizable("Markdown Editor/Localizable.xcstrings")
    languages_data = file_loader.load_languages("tools/data/languages.json")
    keys_data = file_loader.load_keys("tools/data/keys.json")
    
    # Find missing translations
    supported_languages = list(languages_data.keys())
    detector = TranslationDetector(localizable_data, supported_languages, keys_data)
    missing_translations = detector.find_missing_translations()
    
    # Filter for longer keys (30+ characters)
    long_keys = {k: v for k, v in missing_translations.items() if len(k) >= 30}
    
    print(f"Found {len(long_keys)} keys with 30+ characters that need translations\n")
    
    # Initialize translator
    generator = TranslationGenerator()
    
    if not generator.framework_available:
        print("Translation framework not available!")
        return 1
    
    # Test languages to show variety (pick ones likely to have language packs)
    test_languages = ['ar', 'de', 'es', 'fr', 'it', 'ja', 'ko', 'pt-BR', 'ru', 'zh-Hans']
    
    # Show translations for first 5 long keys
    sample_keys = list(long_keys.keys())[:5]
    
    for i, key in enumerate(sample_keys, 1):
        print(f"{i}. SOURCE (English):")
        print(f"   \"{key}\"")
        print()
        
        translations_shown = 0
        for lang in test_languages:
            if lang in long_keys[key]:  # Only translate if it's missing
                translated = generator.translate(key, lang)
                if translated:
                    print(f"   [{lang:8}] \"{translated}\"")
                    translations_shown += 1
                    
                    # Show 3-4 translations per key for variety
                    if translations_shown >= 4:
                        break
        
        if translations_shown == 0:
            print("   (No translations available - language packs may be missing)")
        
        print()
        print("-" * 80)
        print()
    
    # Show summary
    print("\nLanguage Pack Status:")
    if generator.missing_language_packs:
        print(f"  Missing: {', '.join(sorted(generator.missing_language_packs))}")
    else:
        print("  All tested language packs available!")
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
