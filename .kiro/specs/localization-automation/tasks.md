# Implementation Plan: Localization Automation Tool

## Overview

This implementation plan breaks down the localization automation tool into discrete coding tasks. The tool will be implemented as a Python command-line script (tools/localization.py) that processes Xcode localization files, detects missing translations, generates translations using macOS Translation framework, and manages new localization keys.

The implementation follows a pipeline architecture: Load Files → Detect Missing → Generate Translations → Insert Translations → Track New Keys → Report/Merge.

## Tasks

- [ ] 1. Set up project structure and dependencies
  - Create tools/localization.py as the main script
  - Add PyObjC dependency for Translation framework integration
  - Set up Python logging configuration
  - Create basic CLI argument parser with --auto-merge, --dry-run, and --help flags
  - _Requirements: 8.1, 8.2, 8.3_
  
  - [ ] 1.1 User acceptance test: Run with --dry-run flag
    - Execute: `python tools/localization.py --dry-run`
    - Verify: Script runs without errors and shows it's in dry-run mode
    - Verify: No files are created or modified

- [ ] 2. Implement File Loader component
  - [ ] 2.1 Create FileLoader class with JSON loading methods
    - Implement load_localizable() to load Markdown Editor/Localizable.xcstrings
    - Implement load_languages() to load tools/data/languages.json
    - Implement load_keys() to load tools/data/keys.json
    - Add error handling for missing files with clear error messages
    - Add error handling for invalid JSON with file identification
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_
  
  - [ ] 2.2 Implement Localizable.xcstrings structure validation
    - Validate presence of "sourceLanguage", "strings", and "version" fields
    - Report clear error messages for missing fields
    - _Requirements: 1.6, 1.7_
  
  - [ ] 2.3 User acceptance test: Verify file loading with --dry-run
    - Execute: `python tools/localization.py --dry-run`
    - Verify: Output shows all three files loaded successfully
    - Verify: Output displays count of languages and keys loaded
    - Verify: Output shows sourceLanguage and version from Localizable.xcstrings
    - Verify: No files are created or modified
  
  - [ ]* 2.4 Write property test for input structure validation
    - **Property 19: Input Structure Validation**
    - **Validates: Requirements 1.6, 1.7**
  
  - [ ]* 2.5 Write property test for missing file error handling
    - **Property 20: Missing File Error Handling**
    - **Validates: Requirements 1.4**
  
  - [ ]* 2.6 Write property test for invalid JSON error handling
    - **Property 21: Invalid JSON Error Handling**
    - **Validates: Requirements 1.5**
  
  - [ ]* 2.7 Write unit tests for FileLoader
    - Test loading valid files
    - Test missing file scenarios
    - Test invalid JSON scenarios
    - Test structure validation edge cases

- [ ] 3. Implement Translation Detector component
  - [ ] 3.1 Create TranslationDetector class
    - Implement initialization with localizable_data and supported_languages
    - Implement find_missing_translations() to iterate through all keys
    - Compare existing localizations against supported languages list
    - Handle keys with empty or missing "localizations" dictionaries
    - Return mapping of {localization_key: [missing_language_codes]}
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 3.2 User acceptance test: Verify missing translation detection with --dry-run
    - Execute: `python tools/localization.py --dry-run`
    - Verify: Output shows list of keys with missing translations
    - Verify: Output displays which languages are missing for each key
    - Verify: Output shows total count of missing translations detected
    - Verify: No files are created or modified
  
  - [ ]* 3.3 Write property test for missing translation detection
    - **Property 1: Missing Translation Detection Completeness**
    - **Validates: Requirements 2.2, 2.3, 2.4, 2.5**
  
  - [ ]* 3.4 Write property test for processing completeness
    - **Property 8: Processing Completeness**
    - **Validates: Requirements 2.1, 5.1**
  
  - [ ]* 3.5 Write unit tests for TranslationDetector
    - Test detection with complete translations
    - Test detection with partial translations
    - Test detection with empty localizations
    - Test detection with missing localizations field

- [ ] 4. Checkpoint - Ensure file loading and detection work correctly
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement Translation Generator component
  - [ ] 5.1 Create TranslationGenerator class with PyObjC integration
    - Implement check_framework_available() to verify Translation framework
    - Report error if framework not available (macOS Sequoia+ required)
    - Implement translate() method using Translation framework APIs
    - Use source language "en" for all translations
    - Use localization key text as source text
    - Handle missing language packs gracefully (log warning, return None)
    - Implement batch_translate() for efficiency
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_
  
  - [ ] 5.2 Implement format specifier preservation
    - Detect format specifiers in source text (%lld, %@, %1$@, %2$@)
    - Ensure translated text contains same format specifiers
    - Reject translations that corrupt format specifiers
    - _Requirements: 3.7, 9.6_
  
  - [ ] 5.3 User acceptance test: Verify translation generation with --dry-run
    - Execute: `python tools/localization.py --dry-run`
    - Verify: Output shows sample translations being generated
    - Verify: Output displays source text and translated text for each language
    - Verify: Format specifiers are preserved in translations (e.g., %lld stays %lld)
    - Verify: Warnings shown for any missing language packs
    - Verify: No files are created or modified
  
  - [ ]* 5.4 Write property test for format specifier preservation
    - **Property 3: Format Specifier Preservation**
    - **Validates: Requirements 3.7, 9.6**
  
  - [ ]* 5.5 Write property test for source language consistency
    - **Property 14: Source Language Consistency**
    - **Validates: Requirements 3.3**
  
  - [ ]* 5.6 Write property test for translation source text
    - **Property 15: Translation Source Text**
    - **Validates: Requirements 3.4**
  
  - [ ]* 5.7 Write property test for error resilience
    - **Property 16: Error Resilience**
    - **Validates: Requirements 3.6, 9.1**
  
  - [ ]* 5.8 Write unit tests for TranslationGenerator
    - Test successful translation (with mocked framework)
    - Test missing language pack handling
    - Test format specifier preservation
    - Test Unicode preservation
    - Test translation failure handling

- [ ] 6. Implement Translation Inserter component
  - [ ] 6.1 Create TranslationInserter class
    - Implement initialization with localizable_data
    - Implement insert_translation() to add translations to data structure
    - Create "localizations" dictionary if it doesn't exist
    - Create proper stringUnit structure with "state" and "value" fields
    - Never overwrite existing translations
    - Preserve all existing fields and metadata
    - Implement get_updated_data() to return modified data
    - _Requirements: 3.8, 4.1, 4.2, 4.3, 4.4, 4.5_
  
  - [ ] 6.2 User acceptance test: Verify translation insertion with --dry-run
    - Execute: `python tools/localization.py --dry-run`
    - Verify: Output shows updated JSON structure with new translations inserted
    - Verify: Existing translations are preserved (not overwritten)
    - Verify: New translations have proper stringUnit structure with "state": "translated"
    - Verify: Output shows before/after comparison for a sample key
    - Verify: No files are created or modified
  
  - [ ]* 6.3 Write property test for translation preservation
    - **Property 2: Translation Preservation**
    - **Validates: Requirements 4.3, 4.5, 7.5**
  
  - [ ]* 6.4 Write property test for translation insertion structure
    - **Property 4: Translation Insertion Structure**
    - **Validates: Requirements 3.8, 4.1, 4.2**
  
  - [ ]* 6.5 Write property test for Unicode preservation
    - **Property 13: Unicode Preservation**
    - **Validates: Requirements 9.5**
  
  - [ ]* 6.6 Write unit tests for TranslationInserter
    - Test inserting into empty localizations
    - Test inserting into existing localizations
    - Test preservation of existing translations
    - Test structure creation

- [ ] 7. Checkpoint - Ensure translation generation and insertion work correctly
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 8. Implement New Key Tracker component
  - [ ] 8.1 Create NewKeyTracker class
    - Implement initialization with localizable_data and keys_data
    - Implement find_new_keys() to iterate through keys.json
    - Check if each key exists in Localizable.xcstrings
    - Identify keys with zero translations or non-existent keys
    - Exclude keys with one or more translations
    - Implement create_to_localize_structure() to build output JSON
    - Create structure with "sourceLanguage", "strings", and "version" fields
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_
  
  - [ ] 8.2 User acceptance test: Verify new key tracking with --dry-run
    - Execute: `python tools/localization.py --dry-run`
    - Verify: Output shows list of new keys that need to be added
    - Verify: Output displays the to_localize.json structure that would be created
    - Verify: Keys with existing translations are NOT included in output
    - Verify: Keys with zero translations ARE included in output
    - Verify: No files are created or modified
  
  - [ ]* 8.3 Write property test for new key identification
    - **Property 5: New Key Identification**
    - **Validates: Requirements 5.3, 5.4**
  
  - [ ]* 8.4 Write property test for existing key exclusion
    - **Property 6: Existing Key Exclusion**
    - **Validates: Requirements 5.5**
  
  - [ ]* 8.5 Write property test for output structure validity
    - **Property 7: Output Structure Validity**
    - **Validates: Requirements 5.6, 4.4**
  
  - [ ]* 8.6 Write unit tests for NewKeyTracker
    - Test identifying non-existent keys
    - Test identifying keys with zero translations
    - Test excluding keys with translations
    - Test output structure creation

- [ ] 9. Implement Reporter component
  - [ ] 9.1 Create Reporter class
    - Implement initialization with statistics dictionary
    - Track keys_processed, translations_added, new_keys_found
    - Track missing_language_packs and translation_errors
    - Implement report_analysis_summary() to print formatted summary
    - Implement write_to_localize_file() to write JSON with indentation (skip in --dry-run mode)
    - Implement report_merge_summary() for merge operations
    - In --dry-run mode, output to_localize.json content to stdout instead of writing file
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_
  
  - [ ] 9.2 User acceptance test: Verify reporting with --dry-run
    - Execute: `python tools/localization.py --dry-run`
    - Verify: Output shows complete analysis summary with statistics
    - Verify: Output displays to_localize.json content (not written to file)
    - Verify: Summary includes: keys processed, translations added, new keys found
    - Verify: Any missing language pack warnings are displayed
    - Verify: No files are created or modified
  
  - [ ]* 9.3 Write property test for reporting accuracy
    - **Property 9: Reporting Accuracy**
    - **Validates: Requirements 6.1, 6.2, 6.3, 7.7**
  
  - [ ]* 9.4 Write property test for JSON formatting
    - **Property 25: JSON Formatting**
    - **Validates: Requirements 6.5**
  
  - [ ]* 9.5 Write property test for missing language pack reporting
    - **Property 26: Missing Language Pack Reporting**
    - **Validates: Requirements 6.6**
  
  - [ ]* 9.6 Write unit tests for Reporter
    - Test summary report formatting
    - Test JSON file writing with indentation
    - Test merge summary reporting

- [ ] 10. Implement Auto-Merger component
  - [ ] 10.1 Create AutoMerger class
    - Implement initialization with localizable_path
    - Implement backup_file() to create .old backup (skip in --dry-run mode)
    - Delete existing backup if present before creating new one
    - Implement merge_keys() to merge to_localize into main data
    - Preserve all existing keys and translations during merge
    - Implement write_merged_file() with atomic write strategy (skip in --dry-run mode)
    - Implement restore_backup() for error recovery
    - In --dry-run mode, output merged result to stdout instead of writing files
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8_
  
  - [ ] 10.2 User acceptance test: Verify auto-merge with --dry-run
    - Execute: `python tools/localization.py --auto-merge --dry-run`
    - Verify: Output shows what would be backed up (but doesn't create backup)
    - Verify: Output displays merged Localizable.xcstrings structure
    - Verify: Output shows merge summary (how many keys would be merged)
    - Verify: All existing keys and translations are preserved in output
    - Verify: No files are created, modified, or backed up
  
  - [ ]* 10.3 Write property test for merge completeness
    - **Property 10: Merge Completeness**
    - **Validates: Requirements 7.4**
  
  - [ ]* 10.4 Write property test for backup integrity
    - **Property 11: Backup Integrity**
    - **Validates: Requirements 7.3**
  
  - [ ]* 10.5 Write property test for error recovery
    - **Property 12: Error Recovery**
    - **Validates: Requirements 7.8, 9.7**
  
  - [ ]* 10.6 Write property test for backup deletion
    - **Property 23: Backup Deletion Before Creation**
    - **Validates: Requirements 7.2**
  
  - [ ]* 10.7 Write property test for analysis before merge
    - **Property 24: Analysis Before Merge**
    - **Validates: Requirements 7.1**
  
  - [ ]* 10.8 Write unit tests for AutoMerger
    - Test backup creation
    - Test backup deletion
    - Test merge operation
    - Test error recovery
    - Test backup restoration

- [ ] 11. Checkpoint - Ensure tracking, reporting, and merging work correctly
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 12. Implement main workflow orchestration
  - [ ] 12.1 Create main() function to orchestrate components
    - Parse command-line arguments (--auto-merge, --dry-run, --help)
    - Instantiate FileLoader and load all input files
    - Instantiate TranslationDetector and find missing translations
    - Instantiate TranslationGenerator and generate translations
    - Instantiate TranslationInserter and insert translations
    - Instantiate NewKeyTracker and identify new keys
    - Instantiate Reporter and write to_localize.json (or output to stdout in --dry-run)
    - If --auto-merge flag, instantiate AutoMerger and merge (or show merge preview in --dry-run)
    - Handle exceptions and provide clear error messages
    - Return appropriate exit codes (0 for success, non-zero for errors)
    - Display progress messages for long operations
    - In --dry-run mode, ensure NO files are written or modified
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  
  - [ ] 12.2 User acceptance test: Verify complete workflow with --dry-run
    - Execute: `python tools/localization.py --dry-run`
    - Verify: Complete end-to-end output showing all stages
    - Verify: Files loaded → Missing translations detected → Translations generated → Translations inserted → New keys tracked → Summary reported
    - Verify: All output goes to stdout, no files created or modified
    - Execute: `python tools/localization.py --auto-merge --dry-run`
    - Verify: Same as above plus merge preview showing what would be merged
    - Verify: No files created, modified, or backed up
  
  - [ ]* 12.3 Write property test for exit code correctness
    - **Property 17: Exit Code Correctness**
    - **Validates: Requirements 8.5, 8.6**
  
  - [ ]* 12.4 Write integration tests for main workflow
    - Test default mode (analysis only)
    - Test --auto-merge mode
    - Test --help flag
    - Test with sample data files
    - Test error scenarios

- [ ] 13. Implement comprehensive error handling
  - [ ] 13.1 Add error handling for all error categories
    - File system errors (missing files, permissions, disk full)
    - JSON parsing errors (invalid syntax, missing fields, type mismatches)
    - Translation framework errors (not available, missing packs, API failures)
    - Merge errors (backup failure, write failure, validation failure)
    - Format all error messages with component, description, file, reason, action
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7_
  
  - [ ] 13.2 User acceptance test: Verify error handling with --dry-run
    - Test with missing file: Rename languages.json temporarily, run `python tools/localization.py --dry-run`
    - Verify: Clear error message identifying missing file
    - Test with invalid JSON: Create invalid JSON in a test file
    - Verify: Clear error message identifying JSON syntax error
    - Verify: All error messages follow format: Component - Description, File, Reason, Action
  
  - [ ]* 13.3 Write property test for JSON validation before write
    - **Property 18: JSON Validation Before Write**
    - **Validates: Requirements 9.3, 9.4**
  
  - [ ]* 13.4 Write property test for file I/O error reporting
    - **Property 22: File I/O Error Reporting**
    - **Validates: Requirements 9.2**
  
  - [ ]* 13.5 Write unit tests for error handling
    - Test all error categories
    - Test error message format
    - Test error recovery
    - Test graceful degradation

- [ ] 14. Add progress reporting and logging
  - [ ] 14.1 Implement progress reporting
    - Add progress messages for long-running operations
    - Report progress every N keys (e.g., every 10 keys)
    - Use Python logging module with INFO, WARNING, ERROR levels
    - Format log messages consistently
    - _Requirements: 8.4, 10.5_
  
  - [ ] 14.2 User acceptance test: Verify progress reporting with --dry-run
    - Execute: `python tools/localization.py --dry-run` on a file with many keys
    - Verify: Progress messages appear during processing
    - Verify: Messages show which key is being processed
    - Verify: Final summary shows total time and throughput
    - Verify: No files are created or modified

- [ ] 15. Final integration and testing
  - [ ] 15.1 Create end-to-end integration tests
    - Test complete workflow with real data files
    - Test with various file sizes
    - Test with all 38 supported languages (if language packs available)
    - Test error scenarios and recovery
  
  - [ ] 15.2 Create test fixtures and sample data
    - Create minimal valid Localizable.xcstrings for testing
    - Create sample languages.json with subset of languages
    - Create sample keys.json with test keys
    - Create invalid versions for error testing
  
  - [ ] 15.3 User acceptance test: Final end-to-end verification
    - Execute: `python tools/localization.py --dry-run` with real Localizable.xcstrings
    - Verify: Complete workflow executes without errors
    - Verify: All statistics are accurate and reasonable
    - Verify: Output is well-formatted and easy to understand
    - Execute: `python tools/localization.py` (without --dry-run) to create to_localize.json
    - Verify: to_localize.json is created with correct structure
    - Execute: `python tools/localization.py --auto-merge --dry-run`
    - Verify: Merge preview shows correct merged structure
    - Execute: `python tools/localization.py --auto-merge` (without --dry-run)
    - Verify: Backup is created, merge completes, summary is accurate
    - Verify: Localizable.xcstrings contains all merged keys

- [ ] 16. Final checkpoint - Ensure all tests pass and tool is ready
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties (minimum 100 iterations each)
- Unit tests validate specific examples and edge cases
- The Translation framework integration may require macOS Sequoia or later
- PyObjC must be installed for Translation framework access
- All JSON files should use UTF-8 encoding
- Atomic write strategy (write to temp, then rename) prevents file corruption

### --dry-run Mode

The --dry-run flag is a critical testing feature that allows verification of each implementation step without modifying any files:

- **Purpose**: Output all results to stdout instead of writing files
- **Behavior**: 
  - NO files are created, modified, or deleted
  - All JSON output that would be written to files is displayed to stdout
  - Backup operations are simulated but not executed
  - Merge operations show preview of what would be merged
  - All analysis and processing still occurs normally
- **Usage**: `python tools/localization.py --dry-run` or `python tools/localization.py --auto-merge --dry-run`
- **Testing**: Every major task includes a user acceptance test using --dry-run to verify the feature works correctly before moving to the next task
