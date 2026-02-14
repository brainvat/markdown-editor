# Localization Automation Tool

Automated translation management for Mac MD's Xcode localization files. This tool identifies missing translations, generates translations using macOS Translation framework, and manages new localization keys across 38 supported languages.

## Features

- 🌍 **38 Language Support** - Automatic translation to all supported languages
- 🔍 **Smart Detection** - Identifies missing translations and new keys
- 🤖 **Native Translation** - Uses macOS Translation framework via Swift bridge
- 📊 **Progress Tracking** - Real-time progress with ETA and throughput metrics
- 🔄 **Auto-Merge** - Optionally merge translations directly into Localizable.xcstrings
- 🧪 **Dry-Run Mode** - Preview all changes without modifying files
- 💾 **Safe Backups** - Automatic backup before merge operations
- 🎯 **Format Preservation** - Protects format specifiers (%lld, %@, etc.)

## Quick Start

### Prerequisites

- macOS Sequoia (15.0) or later
- Xcode Command Line Tools
- Python 3.8+
- Swift compiler (comes with Xcode)

### Installation

The tool is ready to use - no installation required. The Swift translation bridge will be compiled automatically on first run.

### Basic Usage

```bash
# Preview what would be translated (recommended first step)
python tools/localization.py --dry-run

# Generate translations and create to_localize.json
python tools/localization.py

# Generate translations and auto-merge into Localizable.xcstrings
python tools/localization.py --auto-merge

# Show detailed progress and logging
python tools/localization.py --verbose
```

## How It Works

### Pipeline Architecture

The tool follows a six-stage pipeline:

1. **Load Files** - Reads Localizable.xcstrings, languages.json, and keys.json
2. **Detect Missing** - Identifies keys with missing translations
3. **Generate Translations** - Uses macOS Translation framework to translate text
4. **Insert Translations** - Adds translations to the data structure
5. **Track New Keys** - Identifies keys from keys.json that need to be added
6. **Report/Merge** - Outputs results or merges into Localizable.xcstrings

### Translation Process

```
keys.json (source of truth)
    ↓
Find new keys (not in Localizable.xcstrings or have 0 translations)
    ↓
Generate translations (macOS Translation framework)
    ↓
Create to_localize.json
    ↓
[Optional] Auto-merge into Localizable.xcstrings
```

### Key Features

**Smart Key Detection**
- Only translates keys that are truly new
- Skips keys that already have translations
- Excludes non-translatable keys (format specifiers only, minimal content)
- Respects `skip_localization` flag in keys.json

**Format Specifier Protection**
- Detects format specifiers: `%lld`, `%@`, `%1$@`, `%2$@`, etc.
- Replaces with placeholders during translation
- Restores after translation
- Validates format specifiers match source text

**Progress Reporting**
- Shows current language being processed
- Updates every 10 keys with percentage, rate, and ETA
- Final summary with total time and throughput
- Example: `Progress: 10/2318 (0.4%) - 8.5 translations/sec - ETA: 271s`

## Command-Line Options

```
--dry-run              Preview changes without modifying files
--auto-merge           Automatically merge translations into Localizable.xcstrings
--verbose              Show detailed logging (INFO, WARNING, DEBUG)
--force-language-download  Trigger system prompts for missing language packs
```

## File Structure

```
tools/
├── localization.py           # Main script
├── bridge.swift              # Swift translation bridge
├── mac-translate             # Compiled Swift binary (auto-generated)
├── data/
│   ├── languages.json        # Supported languages (38 total)
│   ├── keys.json            # Source of truth for all localization keys
│   └── to_localize.json     # Generated output (new keys with translations)
└── README.md                # This file
```

### Input Files

**languages.json**
- Maps language codes to display names
- Defines all 38 supported languages
- Example: `{"en": "English", "es": "Spanish", ...}`

**keys.json**
- Source of truth for all localization keys
- Tracks last update date for each key
- Optional `skip_localization` flag
- Format:
```json
{
  "sourceLanguage": "en",
  "strings": {
    "Hello World": {
      "last_update": "2026-02-14"
    },
    "Format example: %lld items": {
      "last_update": "2026-02-14"
    }
  }
}
```

### Output Files

**to_localize.json**
- Contains new keys with generated translations
- Same structure as Localizable.xcstrings
- Can be manually reviewed before merging
- Created in `tools/data/` directory

**Localizable.xcstrings.old**
- Backup of original file (created during auto-merge)
- Deleted and recreated on each merge
- Used for error recovery

**Localizable.xcstrings.diff**
- JSON structural diff showing changes made during merge
- Shows new keys added, translations added, and modifications
- Includes metadata with counts

## Supported Languages

The tool supports 38 languages:

Arabic (ar), Chinese Simplified (zh-Hans), Chinese Traditional (zh-Hant), Czech (cs), Danish (da), Dutch (nl), English (en), French (fr), French Canadian (fr-CA), German (de), Greek (el), Hindi (hi), Indonesian (id), Italian (it), Japanese (ja), Korean (ko), Polish (pl), Portuguese Brazil (pt-BR), Russian (ru), Spanish (es), Spanish Latin America (es-419), Spanish US (es-US), Thai (th), Turkish (tr), Ukrainian (uk), Vietnamese (vi)

### Installing Language Packs

If you see missing language pack warnings:

1. Open System Settings
2. Go to General > Language & Region
3. Click the '+' button under Translation Languages
4. Select and download the languages you need

The tool will automatically detect and use installed language packs.

## Performance

**Typical Performance:**
- Translation speed: 6-8 translations/second
- 61 keys × 22 languages = 1,342 translations in ~3 minutes
- Translation is 99% of total runtime
- Subprocess overhead is minimal due to language-first processing

**Optimization:**
- Translates by language (all keys for one language) rather than by key
- Reduces subprocess overhead significantly
- Progress updates every 10 keys to avoid output spam

## Error Handling

The tool includes comprehensive error handling:

- **File Errors** - Clear messages for missing or invalid files
- **JSON Errors** - Identifies syntax errors with line/column numbers
- **Translation Errors** - Gracefully handles missing language packs
- **Merge Errors** - Automatic backup restoration on failure
- **Format Errors** - Rejects translations that corrupt format specifiers

All errors follow the format:
```
ERROR: Component - Description
  File: path/to/file
  Reason: specific error message
  Action: what to do next
```

## Workflow Examples

### Adding New Keys

1. Add keys to `tools/data/keys.json`:
```json
{
  "strings": {
    "New Feature": {
      "last_update": "2026-02-14"
    }
  }
}
```

2. Preview translations:
```bash
python tools/localization.py --dry-run
```

3. Generate and merge:
```bash
python tools/localization.py --auto-merge
```

### Reviewing Before Merge

1. Generate translations:
```bash
python tools/localization.py
```

2. Review `tools/data/to_localize.json`

3. Manually merge or run with `--auto-merge`

### Recovering from Errors

If auto-merge fails:

1. Check `Localizable.xcstrings.old` backup
2. Manually restore if needed:
```bash
cp "Markdown Editor/Localizable.xcstrings.old" "Markdown Editor/Localizable.xcstrings"
```

## Development

### Architecture

**Components:**
- `FileLoader` - Loads and validates JSON files
- `TranslationDetector` - Finds missing translations
- `TranslationGenerator` - Generates translations via Swift bridge
- `TranslationInserter` - Inserts translations into data structure
- `NewKeyTracker` - Identifies and translates new keys
- `Reporter` - Generates summaries and writes output
- `AutoMerger` - Merges translations with backup/restore

**Swift Bridge:**
- `bridge.swift` - Swift source for translation bridge
- `mac-translate` - Compiled binary (auto-generated)
- Uses macOS Translation framework directly
- Handles language pack detection and errors

### Testing

The tool includes extensive testing capabilities:

```bash
# Test with dry-run (no file modifications)
python tools/localization.py --dry-run

# Test with verbose logging
python tools/localization.py --dry-run --verbose

# Test auto-merge with dry-run
python tools/localization.py --auto-merge --dry-run
```

## Troubleshooting

**Swift compiler not found:**
```bash
xcode-select --install
```

**Translation framework not available:**
- Requires macOS Sequoia (15.0) or later
- Ensure Xcode Command Line Tools are installed

**Missing language packs:**
- Install via System Settings > General > Language & Region
- Or use `--force-language-download` flag (requires user approval)

**Slow translation speed:**
- Normal: 6-8 translations/second
- Each translation requires subprocess call to Swift bridge
- Language-first processing minimizes overhead

## Contributing

Contributions welcome! Areas for improvement:

- [ ] Batch translation API (reduce subprocess overhead)
- [ ] Parallel translation (multiple languages simultaneously)
- [ ] Translation caching (avoid re-translating identical strings)
- [ ] Custom translation providers (Google Translate, DeepL, etc.)
- [ ] Translation quality metrics
- [ ] A/B testing for translation variations

## License

MIT License - see root LICENSE file for details.

## Credits

Built with:
- macOS Translation framework (macOS Sequoia+)
- Swift for native translation bridge
- Python for orchestration and file management

Part of the Mac MD project by Allen Hammock ([@brainvat](https://github.com/brainvat))
