#!/usr/bin/env python3
"""
Localization Automation Tool

Automates translation management for Xcode localization files.
Identifies missing translations, generates translations using macOS Translation framework,
and manages new localization keys across 38 supported languages.
"""

import argparse
import json
import logging
import sys
from pathlib import Path


class FileLoader:
    """Loads and validates input JSON files for the localization tool."""
    
    def __init__(self, logger):
        """Initialize the FileLoader with a logger instance."""
        self.logger = logger
    
    def load_localizable(self, path: str) -> dict:
        """
        Load the Localizable.xcstrings file.
        
        Args:
            path: Path to the Localizable.xcstrings file
            
        Returns:
            Parsed JSON dictionary
            
        Raises:
            FileNotFoundError: If the file doesn't exist
            json.JSONDecodeError: If the file contains invalid JSON
        """
        return self._load_json_file(path, "Localizable.xcstrings")
    
    def load_languages(self, path: str) -> dict:
        """
        Load the languages.json file.
        
        Args:
            path: Path to the languages.json file
            
        Returns:
            Parsed JSON dictionary
            
        Raises:
            FileNotFoundError: If the file doesn't exist
            json.JSONDecodeError: If the file contains invalid JSON
        """
        return self._load_json_file(path, "languages.json")
    
    def load_keys(self, path: str) -> dict:
        """
        Load the keys.json file.
        
        Args:
            path: Path to the keys.json file
            
        Returns:
            Parsed JSON dictionary
            
        Raises:
            FileNotFoundError: If the file doesn't exist
            json.JSONDecodeError: If the file contains invalid JSON
        """
        return self._load_json_file(path, "keys.json")
    
    def _load_json_file(self, path: str, file_description: str) -> dict:
        """
        Load and parse a JSON file with error handling.
        
        Args:
            path: Path to the JSON file
            file_description: Human-readable description of the file
            
        Returns:
            Parsed JSON dictionary
            
        Raises:
            FileNotFoundError: If the file doesn't exist
            json.JSONDecodeError: If the file contains invalid JSON
        """
        file_path = Path(path)
        
        # Check if file exists
        if not file_path.exists():
            error_msg = (
                f"ERROR: File Loader - Failed to load {file_description}\n"
                f"  File: {path}\n"
                f"  Reason: File not found\n"
                f"  Action: Ensure the file exists at the specified path"
            )
            self.logger.error(error_msg)
            raise FileNotFoundError(error_msg)
        
        # Load and parse JSON
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            self.logger.info(f"Loaded {file_description} from {path}")
            return data
        except json.JSONDecodeError as e:
            error_msg = (
                f"ERROR: File Loader - Failed to parse {file_description}\n"
                f"  File: {path}\n"
                f"  Reason: Invalid JSON syntax at line {e.lineno}, column {e.colno}\n"
                f"  Action: Fix the JSON syntax error in the file"
            )
            self.logger.error(error_msg)
            raise json.JSONDecodeError(error_msg, e.doc, e.pos)
        except Exception as e:
            error_msg = (
                f"ERROR: File Loader - Failed to read {file_description}\n"
                f"  File: {path}\n"
                f"  Reason: {str(e)}\n"
                f"  Action: Check file permissions and try again"
            )
            self.logger.error(error_msg)
            raise
    
    def validate_localizable_structure(self, data: dict) -> bool:
        """
        Validate that the Localizable.xcstrings file has the required structure.
        
        Args:
            data: Parsed Localizable.xcstrings data
            
        Returns:
            True if structure is valid
            
        Raises:
            ValueError: If required fields are missing
        """
        required_fields = ["sourceLanguage", "strings", "version"]
        missing_fields = [field for field in required_fields if field not in data]
        
        if missing_fields:
            error_msg = (
                f"ERROR: File Loader - Invalid Localizable.xcstrings structure\n"
                f"  File: Localizable.xcstrings\n"
                f"  Reason: Missing required fields: {', '.join(missing_fields)}\n"
                f"  Action: Ensure the file contains 'sourceLanguage', 'strings', and 'version' fields"
            )
            self.logger.error(error_msg)
            raise ValueError(error_msg)
        
        self.logger.info(f"Validated Localizable.xcstrings structure (sourceLanguage: {data['sourceLanguage']}, version: {data['version']})")
        return True


class TranslationDetector:
    """Detects missing translations for localization keys."""
    
    def __init__(self, localizable_data: dict, supported_languages: list):
        """
        Initialize the TranslationDetector.
        
        Args:
            localizable_data: Parsed Localizable.xcstrings data
            supported_languages: List of supported language codes
        """
        self.localizable_data = localizable_data
        self.supported_languages = supported_languages
        self.logger = logging.getLogger(__name__)
    
    def find_missing_translations(self) -> dict:
        """
        Find missing translations for all localization keys.
        
        Iterates through all keys in the localizable data and identifies
        which languages are missing translations for each key.
        
        Returns:
            Dictionary mapping localization keys to lists of missing language codes
            Format: {localization_key: [missing_language_codes]}
        """
        missing_translations = {}
        strings = self.localizable_data.get("strings", {})
        
        for key in strings:
            # Get the localizations dictionary for this key
            localizations = strings[key].get("localizations", {})
            
            # Find which languages are missing
            missing_langs = []
            for lang in self.supported_languages:
                if lang not in localizations:
                    missing_langs.append(lang)
            
            # Only add to result if there are missing translations
            if missing_langs:
                missing_translations[key] = missing_langs
        
        self.logger.info(f"Detected missing translations for {len(missing_translations)} keys")
        return missing_translations


def setup_logging():
    """Configure logging for the application."""
    logging.basicConfig(
        level=logging.INFO,
        format='%(levelname)s: %(message)s'
    )
    return logging.getLogger(__name__)


def parse_args():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description='Automate translation management for Xcode localization files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                    Run analysis mode (default)
  %(prog)s --dry-run          Preview changes without modifying files
  %(prog)s --auto-merge       Run analysis and merge new keys automatically
  %(prog)s --auto-merge --dry-run  Preview merge without modifying files
        """
    )
    parser.add_argument(
        '--auto-merge',
        action='store_true',
        help='Automatically merge new keys into Localizable.xcstrings after analysis'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Preview changes without modifying any files'
    )
    return parser.parse_args()


def main():
    """Main entry point for the localization tool."""
    logger = setup_logging()
    args = parse_args()
    
    # Display mode information
    if args.dry_run:
        logger.info("Running in DRY-RUN mode - no files will be modified")
    
    if args.auto_merge:
        logger.info("Auto-merge mode enabled")
    else:
        logger.info("Analysis mode (use --auto-merge to enable merging)")
    
    logger.info("Localization automation tool initialized")
    
    # Define file paths
    localizable_path = "Markdown Editor/Localizable.xcstrings"
    languages_path = "tools/data/languages.json"
    keys_path = "tools/data/keys.json"
    
    try:
        # Load input files
        logger.info("Loading input files...")
        file_loader = FileLoader(logger)
        
        localizable_data = file_loader.load_localizable(localizable_path)
        languages_data = file_loader.load_languages(languages_path)
        keys_data = file_loader.load_keys(keys_path)
        
        # Validate Localizable.xcstrings structure
        file_loader.validate_localizable_structure(localizable_data)
        
        # Display summary of loaded data
        num_languages = len(languages_data)
        num_keys_in_localizable = len(localizable_data.get("strings", {}))
        num_keys_to_track = len(keys_data.get("strings", {}))
        
        logger.info(f"Loaded {num_languages} supported languages")
        logger.info(f"Loaded {num_keys_in_localizable} keys from Localizable.xcstrings")
        logger.info(f"Loaded {num_keys_to_track} keys to track from keys.json")
        logger.info(f"Source language: {localizable_data.get('sourceLanguage', 'unknown')}")
        logger.info(f"Version: {localizable_data.get('version', 'unknown')}")
        
        # Detect missing translations
        logger.info("Detecting missing translations...")
        supported_languages = list(languages_data.keys())
        detector = TranslationDetector(localizable_data, supported_languages)
        missing_translations = detector.find_missing_translations()
        
        # Display summary of missing translations
        total_missing = sum(len(langs) for langs in missing_translations.values())
        logger.info(f"Found {len(missing_translations)} keys with missing translations")
        logger.info(f"Total missing translations: {total_missing}")
        
        # Show sample of keys with missing translations (first 5)
        if missing_translations:
            logger.info("Sample keys with missing translations:")
            for i, (key, missing_langs) in enumerate(list(missing_translations.items())[:5]):
                key_display = key if len(key) <= 40 else key[:37] + "..."
                logger.info(f"  '{key_display}' - missing {len(missing_langs)} languages: {', '.join(missing_langs[:5])}{'...' if len(missing_langs) > 5 else ''}")
        
        # TODO: Implement workflow orchestration
        # - Generate translations
        # - Insert translations
        # - Track new keys
        # - Report/merge
        
        logger.info("File loading complete")
        return 0
        
    except (FileNotFoundError, json.JSONDecodeError, ValueError) as e:
        # Error already logged by FileLoader
        return 1
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return 1


if __name__ == '__main__':
    sys.exit(main())
