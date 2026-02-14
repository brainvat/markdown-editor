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
    
    def __init__(self, localizable_data: dict, supported_languages: list, keys_data: dict = None):
        """
        Initialize the TranslationDetector.
        
        Args:
            localizable_data: Parsed Localizable.xcstrings data
            supported_languages: List of supported language codes
            keys_data: Optional parsed keys.json data for skip_localization flags
        """
        self.localizable_data = localizable_data
        self.supported_languages = supported_languages
        self.keys_data = keys_data
        self.logger = logging.getLogger(__name__)
    
    def find_missing_translations(self) -> dict:
        """
        Find missing translations for all localization keys.
        
        Iterates through all keys in the localizable data and identifies
        which languages are missing translations for each key.
        
        Special cases:
        - Empty string keys ("") are skipped - they don't need translations
        - Keys with skip_localization=true in keys.json are skipped
        
        Returns:
            Dictionary mapping localization keys to lists of missing language codes
            Format: {localization_key: [missing_language_codes]}
        """
        missing_translations = {}
        strings = self.localizable_data.get("strings", {})
        
        for key in strings:
            # Skip empty string keys - they don't need translations
            if key == "":
                self.logger.debug(f"Skipping empty string key (no translations needed)")
                continue
            
            # Check if this key should skip localization (from keys.json)
            if self.keys_data:
                key_info = self.keys_data.get("strings", {}).get(key, {})
                if key_info.get("skip_localization", False):
                    self.logger.debug(f"Skipping key '{key}' (skip_localization=true)")
                    continue
            
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


class TranslationGenerator:
    """Generates translations using macOS Translation framework via Swift shim."""

    def __init__(self, force_language_download=False):
        """Initialize the TranslationGenerator and check framework availability.
        
        Args:
            force_language_download: If True, trigger system prompts to download missing language packs
        """
        self.logger = logging.getLogger(__name__)
        self.framework_available = self.check_framework_available()
        self.missing_language_packs = set()
        self.force_language_download = force_language_download
        self.download_triggered_languages = set()
        self.shim_path = Path(__file__).parent / "mac-translate"
        
        # Try to compile the Swift shim if it doesn't exist
        if self.framework_available and not self.shim_path.exists():
            self._compile_swift_shim()

    def check_framework_available(self) -> bool:
        """
        Check if the Translation framework is available on the system.

        Returns:
            True if framework is available, False otherwise
        """
        try:
            import subprocess
            
            # Check if we're on macOS and have Swift compiler available
            result = subprocess.run(
                ['swiftc', '--version'],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            if result.returncode == 0:
                self.logger.info("Swift compiler available - Translation framework can be used")
                return True
            else:
                self.logger.warning("Swift compiler not available - translations will be skipped")
                return False
                
        except FileNotFoundError:
            self.logger.warning(
                "Swift compiler not found - translations will be skipped\n"
                "  Action: Install Xcode Command Line Tools with: xcode-select --install"
            )
            return False
        except Exception as e:
            self.logger.error(
                f"ERROR: Translation Generator - Failed to check framework availability\n"
                f"  Reason: {str(e)}\n"
                f"  Action: Ensure you are running on macOS with Xcode Command Line Tools"
            )
            return False
    
    def _compile_swift_shim(self):
        """Compile the Swift translation shim if it doesn't exist."""
        import subprocess
        
        swift_source = Path(__file__).parent / "bridge.swift"
        
        if not swift_source.exists():
            self.logger.error(
                f"ERROR: Translation Generator - Swift shim source not found\n"
                f"  File: {swift_source}\n"
                f"  Action: Ensure bridge.swift exists in the tools directory"
            )
            self.framework_available = False
            return
        
        try:
            self.logger.info("Compiling Swift translation shim...")
            result = subprocess.run(
                ['swiftc', '-O', str(swift_source), '-o', str(self.shim_path)],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                self.logger.info(f"Swift shim compiled successfully: {self.shim_path}")
            else:
                self.logger.error(
                    f"ERROR: Translation Generator - Failed to compile Swift shim\n"
                    f"  Reason: {result.stderr}\n"
                    f"  Action: Check Swift compiler installation"
                )
                self.framework_available = False
                
        except subprocess.TimeoutExpired:
            self.logger.error("Swift compilation timed out")
            self.framework_available = False
        except Exception as e:
            self.logger.error(f"Failed to compile Swift shim: {str(e)}")
            self.framework_available = False

    def _extract_format_specifiers(self, text: str) -> list:
        """
        Extract format specifiers from text.

        Detects format specifiers like:
        - %lld (long long decimal)
        - %@ (object)
        - %1$@ (positional object)
        - %2$@ (positional object)
        - etc.

        Args:
            text: Text to extract format specifiers from

        Returns:
            List of format specifiers found in the text
        """
        import re
        # Pattern matches: %[position$][flags][width][.precision][length]type
        # Common patterns: %lld, %@, %1$@, %2$@, %d, %s, etc.
        pattern = r'%(?:\d+\$)?[@diouxXeEfFgGaAcspn]|%l{1,2}[diouxX]'
        return re.findall(pattern, text)

    def _validate_format_specifiers(self, source_text: str, translated_text: str) -> bool:
        """
        Validate that translated text contains the same format specifiers as source.

        Args:
            source_text: Original text with format specifiers
            translated_text: Translated text to validate

        Returns:
            True if format specifiers match, False otherwise
        """
        source_specifiers = self._extract_format_specifiers(source_text)
        translated_specifiers = self._extract_format_specifiers(translated_text)

        # Sort both lists for comparison (order might differ in translation)
        source_specifiers_sorted = sorted(source_specifiers)
        translated_specifiers_sorted = sorted(translated_specifiers)

        if source_specifiers_sorted != translated_specifiers_sorted:
            self.logger.warning(
                f"Format specifier mismatch - Source: {source_specifiers}, "
                f"Translated: {translated_specifiers}"
            )
            return False

        return True

    def translate(self, source_text: str, target_language: str) -> str | None:
        """
        Translate text from English to the target language using Swift shim.

        Args:
            source_text: The text to translate (localization key text)
            target_language: Target language code (e.g., 'es', 'fr', 'de')

        Returns:
            Translated text, or None if translation fails
        """
        if not self.framework_available:
            self.logger.warning(f"Translation framework not available, skipping translation to {target_language}")
            return None
        
        if not self.shim_path.exists():
            self.logger.warning(f"Swift shim not found at {self.shim_path}, skipping translation")
            return None

        try:
            import subprocess
            import re
            
            self.logger.debug(f"Translating '{source_text}' to {target_language}")

            # Extract format specifiers and replace with placeholders
            format_specs = self._extract_format_specifiers(source_text)
            protected_text = source_text
            placeholder_map = {}
            
            for i, spec in enumerate(format_specs):
                placeholder = f"__PLACEHOLDER_{i}__"
                placeholder_map[placeholder] = spec
                # Replace the format specifier with the placeholder
                protected_text = protected_text.replace(spec, placeholder, 1)

            # Call the Swift shim with protected text
            result = subprocess.run(
                [str(self.shim_path), "en", target_language, protected_text],
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if result.returncode == 0:
                translated_text = result.stdout.strip()
                
                # Restore format specifiers from placeholders
                for placeholder, spec in placeholder_map.items():
                    translated_text = translated_text.replace(placeholder, spec)
                
                # Validate format specifiers
                if not self._validate_format_specifiers(source_text, translated_text):
                    self.logger.error(
                        f"Translation rejected for '{source_text}' to {target_language}: "
                        "Format specifiers were corrupted"
                    )
                    return None
                
                return translated_text
            else:
                # Translation failed - likely missing language pack
                error_msg = result.stderr.strip()
                if "Error:" in error_msg:
                    # Track as missing language pack
                    if target_language not in self.missing_language_packs:
                        self.missing_language_packs.add(target_language)
                    self.logger.warning(
                        f"Language pack for '{target_language}' is not installed: {error_msg}"
                    )
                else:
                    self.logger.error(f"Translation failed: {error_msg}")
                return None
                
        except subprocess.TimeoutExpired:
            self.logger.error(f"Translation timed out for '{source_text}' to {target_language}")
            return None
        except Exception as e:
            self.logger.error(
                f"Translation failed for '{source_text}' to {target_language}: {str(e)}"
            )
            return None

    def get_available_languages(self) -> list:
        """
        Get a list of all currently available (installed) translation languages.
        
        Returns:
            List of language codes that have installed language packs
        """
        # With the Swift shim, we can't easily query available languages
        # The shim will fail gracefully if a language pack is missing
        # So we return an empty list and rely on runtime detection
        return []
    
    def get_missing_language_packs_summary(self) -> str:
        """
        Get a summary of missing language packs with instructions.
        
        Returns:
            Formatted string with missing language packs and installation instructions
        """
        summary = "\n" + "="*70 + "\n"
        summary += "TRANSLATION LANGUAGE PACKS DIAGNOSTIC\n"
        summary += "="*70 + "\n"
        summary += "\nUsing Swift shim for native Translation framework access.\n"
        summary += "Language packs are detected at runtime during translation.\n\n"
        
        # Show missing languages if any
        if self.missing_language_packs:
            summary += "-"*70 + "\n"
            summary += f"Missing language packs detected ({len(self.missing_language_packs)}):\n\n"
            
            # Group languages for better readability
            langs_list = sorted(list(self.missing_language_packs))
            for i in range(0, len(langs_list), 6):
                summary += "  " + ", ".join(langs_list[i:i+6]) + "\n"
            
            summary += "\n" + "-"*70 + "\n"
            summary += "TO INSTALL LANGUAGE PACKS:\n"
            summary += "-"*70 + "\n"
            summary += "1. Open System Settings\n"
            summary += "2. Go to General > Language & Region\n"
            summary += "3. Click the '+' button under Translation Languages\n"
            summary += "4. Select and download the languages you need\n"
            summary += "\n"
        else:
            summary += "No missing language packs detected during this run.\n"
            summary += "(Language packs are checked when translations are attempted)\n\n"
        
        summary += "="*70 + "\n"
        
        return summary
    
    def batch_translate(self, source_text: str, target_languages: list) -> dict:
        """
        Translate text to multiple target languages efficiently.

        Args:
            source_text: The text to translate (localization key text)
            target_languages: List of target language codes

        Returns:
            Dictionary mapping language codes to translated text
            Format: {language_code: translated_text}
            Missing translations will not be included in the result
        """
        if not self.framework_available:
            self.logger.warning("Translation framework not available, skipping batch translation")
            return {}

        translations = {}

        for target_lang in target_languages:
            translated = self.translate(source_text, target_lang)
            if translated is not None:
                translations[target_lang] = translated

        return translations




def setup_logging(verbose=False):
    """Configure logging for the application.
    
    Args:
        verbose: If True, show INFO/WARNING/DEBUG. If False, only show errors and summaries.
    """
    if verbose:
        level = logging.INFO
    else:
        level = logging.ERROR
    
    logging.basicConfig(
        level=level,
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
  %(prog)s --verbose          Show detailed logging output
  %(prog)s --force-language-download  Trigger system prompts to download missing language packs
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
    parser.add_argument(
        '--verbose',
        action='store_true',
        help='Show detailed logging output (INFO, WARNING, DEBUG messages)'
    )
    parser.add_argument(
        '--force-language-download',
        action='store_true',
        help='Trigger system prompts to download missing language packs (requires user approval in System Settings)'
    )
    return parser.parse_args()


def main():
    """Main entry point for the localization tool."""
    args = parse_args()
    logger = setup_logging(verbose=args.verbose)
    
    # Display mode information (always show, even in non-verbose mode)
    if not args.verbose:
        print("Localization Automation Tool")
        print("=" * 70)
        if args.dry_run:
            print("Mode: DRY-RUN (no files will be modified)")
        else:
            print("Mode: Analysis" + (" + Auto-merge" if args.auto_merge else ""))
        print()
    else:
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
        detector = TranslationDetector(localizable_data, supported_languages, keys_data)
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
        
        # Generate translations
        logger.info("Initializing translation generator...")
        generator = TranslationGenerator(force_language_download=args.force_language_download)
        
        if not generator.framework_available:
            logger.warning("Translation framework not available - translations will be skipped")
            logger.warning("To enable translations, ensure you are running macOS Sequoia (15.0) or later")
        
        if args.force_language_download:
            logger.info("Language download mode enabled - will trigger system prompts for missing language packs")
        
        # Generate sample translations for demonstration (first 3 keys, first 3 languages each)
        if missing_translations and generator.framework_available:
            logger.info("Generating sample translations...")
            sample_keys = list(missing_translations.items())[:3]
            
            # Track statistics
            translations_generated = 0
            translations_skipped = 0
            
            for key, missing_langs in sample_keys:
                key_display = key if len(key) <= 40 else key[:37] + "..."
                logger.info(f"Translating key: '{key_display}'")
                
                # Show format specifiers if present
                format_specs = generator._extract_format_specifiers(key)
                if format_specs:
                    logger.info(f"  Format specifiers detected: {format_specs}")
                
                # Generate translations for first 3 languages
                sample_langs = missing_langs[:3]
                for lang in sample_langs:
                    translated = generator.translate(key, lang)
                    if translated:
                        translations_generated += 1
                        logger.info(f"  [{lang}] {key} -> {translated}")
                        # Verify format specifiers are preserved
                        if format_specs:
                            translated_specs = generator._extract_format_specifiers(translated)
                            if sorted(format_specs) == sorted(translated_specs):
                                logger.info(f"       ✓ Format specifiers preserved: {translated_specs}")
                    else:
                        translations_skipped += 1
                        logger.info(f"  [{lang}] Translation skipped (framework not available or language pack missing)")
            
        # Display translation statistics
            if args.verbose:
                logger.info(f"Translation generation summary:")
                logger.info(f"  Translations generated: {translations_generated}")
                logger.info(f"  Translations skipped: {translations_skipped}")
                logger.info(f"  Success rate: {translations_generated}/{translations_generated + translations_skipped} ({100 * translations_generated / (translations_generated + translations_skipped) if (translations_generated + translations_skipped) > 0 else 0:.1f}%)")
            else:
                # Clean summary for non-verbose mode
                print(f"Processing: {len(missing_translations)} keys with missing translations")
                print(f"Total missing: {total_missing} translations")
                print(f"Sample translation: {translations_generated}/{translations_generated + translations_skipped} successful")
                print()
        
        # Display language packs diagnostic (always show)
        if generator.framework_available:
            diagnostic_summary = generator.get_missing_language_packs_summary()
            print(diagnostic_summary)
        
        # Final summary for non-verbose mode
        if not args.verbose:
            print("Analysis complete.")
            print(f"Found {len(missing_translations)} keys needing translations across {num_languages} languages.")
            if generator.framework_available:
                success_rate = (translations_generated / (translations_generated + translations_skipped) * 100) if (translations_generated + translations_skipped) > 0 else 0
                print(f"Translation success rate: {success_rate:.1f}%")
            print()
        
        # TODO: Implement workflow orchestration
        # - Insert translations
        # - Track new keys
        # - Report/merge
        
        logger.info("Analysis complete")
        return 0
        
    except (FileNotFoundError, json.JSONDecodeError, ValueError) as e:
        # Error already logged by FileLoader
        return 1
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return 1


if __name__ == '__main__':
    sys.exit(main())
