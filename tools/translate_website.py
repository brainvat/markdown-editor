#!/usr/bin/env python3
"""
Website Translation Generator

Generates translation JSON files for the Mac MD website using the macOS Translation framework.
Creates localized versions of the website content for all 38 supported languages.
"""

import json
import subprocess
import sys
from pathlib import Path


def load_languages():
    """Load supported languages from languages.json."""
    languages_file = Path(__file__).parent / "data" / "languages.json"
    with open(languages_file, 'r', encoding='utf-8') as f:
        return list(json.load(f).keys())


def translate_text(text, target_lang):
    """
    Translate text using macOS Translation framework via Swift bridge.
    
    Args:
        text: Text to translate
        target_lang: Target language code
        
    Returns:
        Translated text or original if translation fails
    """
    if target_lang == 'en':
        return text
    
    try:
        # Use the existing Swift bridge for translation
        bridge_path = Path(__file__).parent / "bridge.swift"
        result = subprocess.run(
            ['swift', str(bridge_path), 'en', target_lang, text],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            translated = result.stdout.strip()
            return translated if translated else text
        else:
            print(f"Warning: Translation failed for '{text}' to {target_lang}: {result.stderr}", file=sys.stderr)
            return text
    except Exception as e:
        print(f"Error translating '{text}' to {target_lang}: {e}", file=sys.stderr)
        return text


def translate_dict(data, target_lang, path=""):
    """
    Recursively translate all strings in a dictionary.
    
    Args:
        data: Dictionary to translate
        target_lang: Target language code
        path: Current path in the dictionary (for logging)
        
    Returns:
        Translated dictionary
    """
    if isinstance(data, dict):
        result = {}
        for key, value in data.items():
            current_path = f"{path}.{key}" if path else key
            result[key] = translate_dict(value, target_lang, current_path)
        return result
    elif isinstance(data, str):
        print(f"  Translating: {path}")
        return translate_text(data, target_lang)
    else:
        return data


def generate_translation(source_file, target_lang, output_file):
    """
    Generate a translation file for a specific language.
    
    Args:
        source_file: Path to English source JSON
        target_lang: Target language code
        output_file: Path to output JSON file
    """
    print(f"\nGenerating {target_lang}.json...")
    
    # Load English source
    with open(source_file, 'r', encoding='utf-8') as f:
        source_data = json.load(f)
    
    # Translate all strings
    translated_data = translate_dict(source_data, target_lang)
    
    # Write output
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(translated_data, f, ensure_ascii=False, indent=2)
    
    print(f"✓ Created {output_file}")


def main():
    """Main entry point for the website translation generator."""
    # Paths
    website_dir = Path(__file__).parent.parent / "docs" / "website"
    locales_dir = website_dir / "locales"
    source_file = locales_dir / "en.json"
    
    # Verify source file exists
    if not source_file.exists():
        print(f"Error: Source file not found: {source_file}", file=sys.stderr)
        sys.exit(1)
    
    # Load supported languages
    languages = load_languages()
    
    print(f"Generating translations for {len(languages)} languages...")
    print(f"Source: {source_file}")
    print(f"Output directory: {locales_dir}")
    
    # Generate translations for each language
    for lang in languages:
        if lang == 'en':
            print(f"\nSkipping {lang} (source language)")
            continue
        
        output_file = locales_dir / f"{lang}.json"
        
        try:
            generate_translation(source_file, lang, output_file)
        except KeyboardInterrupt:
            print("\n\nTranslation interrupted by user.")
            sys.exit(1)
        except Exception as e:
            print(f"Error generating {lang}.json: {e}", file=sys.stderr)
            continue
    
    print(f"\n✓ Translation complete! Generated {len(languages) - 1} translation files.")
    print(f"\nTo test locally, open docs/website/index.html in your browser.")


if __name__ == "__main__":
    main()
