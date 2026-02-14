# Localization Automation Tool

A Python command-line tool that automates translation management for Xcode localization files (`.xcstrings` format). The tool identifies missing translations, generates translations using macOS Translation framework, and manages new localization keys across 38 supported languages.

## Features

- **Automatic Translation Detection**: Identifies missing translations across all supported languages
- **Native macOS Translation**: Uses macOS Translation framework via Swift for high-quality translations
- **Format Specifier Preservation**: Maintains format specifiers like `%lld`, `%@`, `%1$@`, `%2$@` in translations
- **Unicode Support**: Correctly handles all Unicode characters (Arabic, Chinese, Japanese, etc.)
- **Safe Operations**: Never overwrites existing translations
- **Dry-Run Mode**: Preview all changes before applying them
- **Auto-Merge**: Optionally merge new keys into the main localization file automatically

## Requirements

- **macOS Sequoia (15.0) or later** (for Translation framework)
- **Python 3.8+**
- **Xcode Command Line Tools** (for Swift compiler)
- **Language Packs**: Install desired language packs via System Settings

## Installation

1. Ensure Xcode Command Line Tools are installed:
   ```bash
   xcode-select --install
   ```

2. The tool uses native macOS frameworks, no additional Python packages required.

## Usage

### Basic Analysis (Default Mode)

Analyze missing translations and create a `to_localize.json` file:

```bash
python tools/localization.py
```

### Dry-Run Mode

Preview changes without modifying any files:

```bash
python tools/localization.py --dry-run
```

### Verbose Output

Show detailed logging information:

```bash
python tools/localization.py --verbose
```

### Auto-Merge Mode

Automatically merge new keys into the main localization file:

```bash
python tools/localization.py --auto-merge
```

### Combined Options

```bash
python tools/localization.py --auto-merge --dry-run --verbose
```

## File Structure

### Input Files

- **`Markdown Editor/Localizable.xcstrings`**: Main Xcode localization file
- **`tools/data/languages.json`**: List of supported language codes
- **`tools/data/keys.json`**: Localization keys that need translations

### Output Files

- **`tools/data/to_localize.json`**: Generated file containing new keys to be merged
- **`Markdown Editor/Localizable.xcstrings.old`**: Backup file (created in auto-merge mode)

## Supported Languages

The tool supports 38 languages:

Arabic (ar), Czech (cs), Danish (da), German (de), Greek (el), English (en), Spanish (es), Finnish (fi), French (fr), Hebrew (he), Hindi (hi), Croatian (hr), Hungarian (hu), Indonesian (id), Italian (it), Japanese (ja), Korean (ko), Malay (ms), Norwegian Bokmål (nb), Dutch (nl), Polish (pl), Portuguese (pt-BR), Portuguese (pt-PT), Romanian (ro), Russian (ru), Slovak (sk), Swedish (sv), Thai (th), Turkish (tr), Ukrainian (uk), Vietnamese (vi), Chinese Simplified (zh-Hans), Chinese Traditional (zh-Hant), Chinese Hong Kong (zh-HK)

## How It Works

### Pipeline Architecture

```
Load Files → Detect Missing → Generate Translations → Insert Translations → Track New Keys → Report/Merge
```

### Components

1. **File Loader**: Loads and validates all input JSON files
2. **Translation Detector**: Identifies missing translations for each key
3. **Translation Generator**: Generates translations using macOS Translation framework
4. **Translation Inserter**: Inserts generated translations into data structure
5. **New Key Tracker**: Identifies keys that need to be added to main file
6. **Reporter**: Generates summary reports and writes output files
7. **Auto-Merger**: Backs up and merges new keys into main file (optional)

## Translation Quality

### Format Specifier Handling

The tool automatically detects and preserves format specifiers:

- `%lld` - Long long decimal
- `%@` - Object
- `%1$@`, `%2$@` - Positional objects
- `%d`, `%s`, etc. - Standard format specifiers

Example:
```
Source: "%lld words"
Arabic: "%lld كلمات"  ✓ Format specifier preserved
```

### Unicode Preservation

All Unicode characters are correctly preserved through the entire pipeline:

- Japanese: 日本語
- Chinese: 中文
- Arabic: العربية
- German umlauts: Ä, Ö, Ü

## Language Pack Management

### Installing Language Packs

1. Open **System Settings**
2. Go to **General > Language & Region**
3. Click the **'+'** button under **Translation Languages**
4. Select and download the languages you need

### Missing Language Packs

The tool will detect and report missing language packs:

```
======================================================================
TRANSLATION LANGUAGE PACKS DIAGNOSTIC
======================================================================

Missing language packs detected (2):

  cs, da

----------------------------------------------------------------------
TO INSTALL LANGUAGE PACKS:
----------------------------------------------------------------------
1. Open System Settings
2. Go to General > Language & Region
3. Click the '+' button under Translation Languages
4. Select and download the languages you need
======================================================================
```

## Error Handling

The tool handles errors gracefully:

- **Missing Files**: Clear error messages with file paths
- **Invalid JSON**: Syntax error reporting with line numbers
- **Missing Language Packs**: Warnings logged, processing continues
- **Translation Failures**: Errors logged, other translations continue
- **Merge Errors**: Automatic backup restoration

### Error Message Format

```
ERROR: [Component] - [Description]
  File: [path if applicable]
  Reason: [detailed reason]
  Action: [what the user should do]
```

## Examples

### Example 1: Basic Analysis

```bash
$ python tools/localization.py --dry-run

Localization Automation Tool
======================================================================
Mode: DRY-RUN (no files will be modified)

Processing: 128 keys with missing translations
Total missing: 4365 translations
Sample translation: 3/9 successful

======================================================================
SAMPLE TRANSLATION INSERTION
======================================================================

Key: '%@ theme%@'

Before insertion:
  Localizations: ['en']
  Count: 1 languages

After insertion:
  Localizations: ['en', 'ar']
  Count: 2 languages
  Newly added: ['ar']

New translation structure for 'ar':
  {
  "stringUnit": {
    "state": "translated",
    "value": "%@ موضوع%@"
  }
}

Verification:
  ✓ Existing translations preserved (not overwritten)
  ✓ New translations have proper stringUnit structure
  ✓ All new translations have 'state': 'translated'
  ✓ All new translations have 'value' field with translated text
======================================================================

Analysis complete.
Found 128 keys needing translations across 38 languages.
Translation success rate: 33.3%
Translations inserted: 3

✓ DRY-RUN mode: No files were created or modified
```

### Example 2: Auto-Merge with Verbose Output

```bash
$ python tools/localization.py --auto-merge --verbose

INFO: Auto-merge mode enabled
INFO: Localization automation tool initialized
INFO: Loading input files...
INFO: Loaded Localizable.xcstrings from Markdown Editor/Localizable.xcstrings
INFO: Loaded 38 supported languages
INFO: Detected missing translations for 128 keys
INFO: Generating sample translations...
INFO: Inserted 3 translations
INFO: Creating backup: Markdown Editor/Localizable.xcstrings.old
INFO: Merging 5 new keys into Localizable.xcstrings
INFO: Merge complete
```

## Troubleshooting

### Translation Framework Not Available

**Error**: `Translation framework not available`

**Solution**: Ensure you're running macOS Sequoia (15.0) or later and have Xcode Command Line Tools installed.

### Swift Compiler Not Found

**Error**: `Swift compiler not found`

**Solution**: Install Xcode Command Line Tools:
```bash
xcode-select --install
```

### Missing Language Packs

**Warning**: `Language pack for 'cs' is not installed`

**Solution**: Install the language pack via System Settings (see Language Pack Management section above).

### Invalid JSON Structure

**Error**: `Invalid Localizable.xcstrings structure`

**Solution**: Ensure the file contains required fields: `sourceLanguage`, `strings`, and `version`.

## Development

### Running Tests

Run the comprehensive checkpoint test:

```bash
python3 << 'EOF'
import sys
sys.path.insert(0, 'tools')
from localization import TranslationGenerator, TranslationInserter

# Test translation generation
generator = TranslationGenerator()
result = generator.translate("%lld words", "ar")
print(f"Translation: {result}")

# Test translation insertion
test_data = {"sourceLanguage": "en", "strings": {"Test": {}}, "version": "1.0"}
inserter = TranslationInserter(test_data)
inserter.insert_translation("Test", "es", "Prueba")
print(f"Inserted: {inserter.get_insertion_count()} translations")
EOF
```

### Code Structure

```
tools/
├── localization.py          # Main script
├── bridge.swift             # Swift shim for Translation framework
├── mac-translate            # Compiled Swift binary (auto-generated)
├── data/
│   ├── languages.json       # Supported languages
│   ├── keys.json           # Keys to track
│   └── to_localize.json    # Generated output (created by tool)
└── docs/
    └── README.md           # This file
```

## Best Practices

1. **Always use --dry-run first**: Preview changes before applying them
2. **Review translations**: Machine translations may need human review
3. **Backup regularly**: The tool creates backups, but maintain your own as well
4. **Install language packs**: Install all needed language packs before running
5. **Use version control**: Commit changes to track translation history
6. **Test format specifiers**: Verify format specifiers work in your app
7. **Review Unicode**: Check that Unicode characters display correctly

## Limitations

- Requires macOS Sequoia (15.0) or later for Translation framework
- Translation quality depends on macOS Translation framework
- Language packs must be installed manually
- Some languages may not have available language packs
- Machine translations may require human review for accuracy
- Format specifiers must be simple (complex patterns may not be preserved)

## Future Enhancements

Potential improvements for future versions:

- Batch processing for large files
- Custom translation glossaries
- Translation memory
- Quality scoring
- Parallel processing
- Web-based UI
- CI/CD integration
- Translation validation rules

## License

This tool is part of the Markdown Editor project.

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review error messages carefully
3. Ensure all requirements are met
4. Check that language packs are installed

## Version History

- **v1.0** (2026-02-13): Initial implementation
  - File loading and validation
  - Translation detection
  - Translation generation with macOS Translation framework
  - Translation insertion with preservation
  - Format specifier preservation
  - Unicode support
  - Dry-run mode
  - Auto-merge functionality
