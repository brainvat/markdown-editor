# Requirements Document

## Introduction

This document specifies the requirements for a Python-based localization automation tool that manages translations for an Xcode localization file (Localizable.xcstrings). The tool automates the process of identifying missing translations, generating translations using macOS Translation framework, and managing new localization keys across 38 supported languages.

## Glossary

- **Localization_Tool**: The Python command-line script (tools/localization.py) that automates translation management
- **Localizable_File**: The Xcode localization file (Markdown Editor/Localizable.xcstrings) containing all translations in JSON format
- **Languages_File**: The reference file (tools/data/languages.json) containing all supported language codes with timestamps
- **Keys_File**: The reference file (tools/data/keys.json) containing localization keys that need translations with timestamps
- **Output_File**: The generated file (tools/data/to_localize.json) containing new keys to be merged into Localizable_File
- **Translation_Framework**: The macOS Translation.framework used for generating translations
- **Source_Language**: The base language for all translations (always "en" for English)
- **Target_Language**: Any language from Languages_File that needs translation
- **Localization_Key**: A unique string identifier in the Localizable_File strings dictionary
- **String_Unit**: A translation entry containing state and value fields within a localization

## Requirements

### Requirement 1: File Loading and Validation

**User Story:** As a developer, I want the tool to load and validate all required data files, so that I can ensure the tool has correct inputs before processing.

#### Acceptance Criteria

1. WHEN the Localization_Tool starts, THE Localization_Tool SHALL load the Localizable_File from "Markdown Editor/Localizable.xcstrings"
2. WHEN the Localization_Tool starts, THE Localization_Tool SHALL load the Languages_File from "tools/data/languages.json"
3. WHEN the Localization_Tool starts, THE Localization_Tool SHALL load the Keys_File from "tools/data/keys.json"
4. IF any required file is missing, THEN THE Localization_Tool SHALL report a clear error message indicating which file is missing and terminate
5. IF any JSON file contains invalid JSON syntax, THEN THE Localization_Tool SHALL report a clear error message indicating which file has invalid JSON and terminate
6. WHEN the Localizable_File is loaded, THE Localization_Tool SHALL validate that it contains "sourceLanguage", "strings", and "version" fields
7. IF the Localizable_File structure is invalid, THEN THE Localization_Tool SHALL report a clear error message describing the structural issue and terminate

### Requirement 2: Missing Translation Detection

**User Story:** As a developer, I want the tool to identify which languages are missing for each localization key, so that I can ensure complete translation coverage.

#### Acceptance Criteria

1. WHEN processing the Localizable_File, THE Localization_Tool SHALL iterate through all Localization_Keys in the "strings" dictionary
2. FOR each Localization_Key, WHEN checking translations, THE Localization_Tool SHALL compare the "localizations" dictionary against all language codes from Languages_File
3. WHEN a Target_Language from Languages_File is not present in a Localization_Key's "localizations" dictionary, THE Localization_Tool SHALL identify it as a missing translation
4. WHEN a Localization_Key has an empty "localizations" dictionary, THE Localization_Tool SHALL identify all languages from Languages_File as missing
5. WHEN a Localization_Key has no "localizations" field, THE Localization_Tool SHALL identify all languages from Languages_File as missing

### Requirement 3: Translation Generation

**User Story:** As a developer, I want the tool to automatically generate missing translations using macOS Translation framework, so that I can quickly populate translations without manual work.

#### Acceptance Criteria

1. WHEN the Localization_Tool starts, THE Localization_Tool SHALL verify that Translation_Framework is available on the system
2. IF Translation_Framework is not available, THEN THE Localization_Tool SHALL report an error indicating macOS Sequoia or later is required and terminate
3. WHEN generating a translation, THE Localization_Tool SHALL use Source_Language "en" as the source
4. WHEN generating a translation, THE Localization_Tool SHALL use the Localization_Key text as the source text
5. WHEN generating a translation for a Target_Language, THE Localization_Tool SHALL invoke Translation_Framework with the source text and Target_Language code
6. IF a language pack is not installed for a Target_Language, THEN THE Localization_Tool SHALL log a warning and skip that translation
7. WHEN a translation is successfully generated, THE Localization_Tool SHALL preserve any format specifiers (such as %lld, %@, %1$@, %2$@) in the translated text
8. WHEN a translation is generated, THE Localization_Tool SHALL create a String_Unit with "state" set to "translated" and "value" set to the translated text

### Requirement 4: Translation Insertion

**User Story:** As a developer, I want the tool to insert generated translations into the Localizable file structure, so that the file remains valid and complete.

#### Acceptance Criteria

1. WHEN inserting a translation, THE Localization_Tool SHALL add the Target_Language to the Localization_Key's "localizations" dictionary if not present
2. WHEN inserting a translation, THE Localization_Tool SHALL create a String_Unit structure with "state" and "value" fields
3. WHEN a Localization_Key already has a translation for a Target_Language, THE Localization_Tool SHALL preserve the existing translation without modification
4. WHEN all missing translations for a Localization_Key are processed, THE Localization_Tool SHALL maintain the exact JSON structure of the Localizable_File
5. WHEN inserting translations, THE Localization_Tool SHALL preserve all existing fields and metadata in the Localizable_File

### Requirement 5: New Key Tracking

**User Story:** As a developer, I want the tool to identify which keys from the Keys_File need to be added to the Localizable file, so that I can track new localization requirements.

#### Acceptance Criteria

1. WHEN processing Keys_File, THE Localization_Tool SHALL iterate through all keys in Keys_File
2. FOR each key in Keys_File, WHEN checking existence, THE Localization_Tool SHALL determine if the key exists in the Localizable_File "strings" dictionary
3. WHEN a key from Keys_File exists in Localizable_File with zero translations, THE Localization_Tool SHALL add it to Output_File
4. WHEN a key from Keys_File does not exist in Localizable_File, THE Localization_Tool SHALL add it to Output_File
5. WHEN a key from Keys_File exists in Localizable_File with one or more translations, THE Localization_Tool SHALL not add it to Output_File
6. WHEN creating Output_File, THE Localization_Tool SHALL use the same JSON structure as Localizable_File with "sourceLanguage", "strings", and "version" fields

### Requirement 6: Analysis Reporting

**User Story:** As a developer, I want the tool to report a summary of its analysis, so that I can understand what changes were identified.

#### Acceptance Criteria

1. WHEN analysis is complete, THE Localization_Tool SHALL report the total number of Localization_Keys processed
2. WHEN analysis is complete, THE Localization_Tool SHALL report the total number of new translations added to existing keys
3. WHEN analysis is complete, THE Localization_Tool SHALL report the number of new keys found that need to be merged
4. WHEN analysis is complete, THE Localization_Tool SHALL write the Output_File to "tools/data/to_localize.json"
5. WHEN writing Output_File, THE Localization_Tool SHALL format the JSON with proper indentation for readability
6. WHEN language pack warnings occur, THE Localization_Tool SHALL include a summary of which Target_Languages had missing language packs

### Requirement 7: Auto-Merge Functionality

**User Story:** As a developer, I want the tool to optionally merge new keys into the Localizable file automatically, so that I can streamline the localization workflow.

#### Acceptance Criteria

1. WHEN the --auto-merge flag is provided, THE Localization_Tool SHALL perform analysis first before merging
2. WHEN --auto-merge is active and a backup file exists at "Markdown Editor/Localizable.xcstrings.old", THE Localization_Tool SHALL delete the existing backup
3. WHEN --auto-merge is active, THE Localization_Tool SHALL copy the current Localizable_File to "Markdown Editor/Localizable.xcstrings.old"
4. WHEN --auto-merge is active, THE Localization_Tool SHALL merge all keys from Output_File into the Localizable_File "strings" dictionary
5. WHEN merging keys, THE Localization_Tool SHALL preserve all existing keys and translations in Localizable_File
6. WHEN merging is complete, THE Localization_Tool SHALL write the updated Localizable_File back to "Markdown Editor/Localizable.xcstrings"
7. WHEN merging is complete, THE Localization_Tool SHALL report the number of keys merged into Localizable_File
8. IF an error occurs during merging, THEN THE Localization_Tool SHALL restore the backup file and report the error

### Requirement 8: Command-Line Interface

**User Story:** As a developer, I want a clear command-line interface, so that I can easily run the tool with appropriate options.

#### Acceptance Criteria

1. WHEN invoked without arguments, THE Localization_Tool SHALL run in analysis mode and create Output_File
2. WHEN invoked with --auto-merge flag, THE Localization_Tool SHALL run in merge mode after analysis
3. WHEN invoked with --help flag, THE Localization_Tool SHALL display usage information and exit
4. THE Localization_Tool SHALL display progress messages during processing for long-running operations
5. WHEN processing completes successfully, THE Localization_Tool SHALL exit with status code 0
6. WHEN an error occurs, THE Localization_Tool SHALL exit with a non-zero status code

### Requirement 9: Error Handling and Robustness

**User Story:** As a developer, I want the tool to handle errors gracefully, so that I can diagnose and fix issues quickly.

#### Acceptance Criteria

1. IF Translation_Framework fails to translate a string, THEN THE Localization_Tool SHALL log the error and continue processing other translations
2. IF file I/O operations fail, THEN THE Localization_Tool SHALL report a clear error message with the file path and error reason
3. WHEN writing JSON files, THE Localization_Tool SHALL validate the JSON structure before writing
4. IF JSON validation fails before writing, THEN THE Localization_Tool SHALL report the validation error and not write the file
5. WHEN processing special characters in strings, THE Localization_Tool SHALL preserve Unicode characters correctly
6. WHEN processing format specifiers, THE Localization_Tool SHALL ensure they are not corrupted during translation
7. IF the Localizable_File is corrupted during processing, THEN THE Localization_Tool SHALL restore from backup when --auto-merge was used

### Requirement 10: Performance and Efficiency

**User Story:** As a developer, I want the tool to process large localization files efficiently, so that I can run it frequently without delays.

#### Acceptance Criteria

1. WHEN processing the Localizable_File, THE Localization_Tool SHALL load the entire file into memory once
2. WHEN generating translations, THE Localization_Tool SHALL batch translation requests where possible to minimize API calls
3. WHEN writing output files, THE Localization_Tool SHALL write the file once after all processing is complete
4. THE Localization_Tool SHALL process a file with 1000 keys and 38 languages within reasonable time limits
5. WHEN processing is ongoing, THE Localization_Tool SHALL provide periodic progress updates to indicate activity
