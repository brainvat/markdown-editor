# Mac MD Website

This is the marketing website for Mac MD, hosted on GitHub Pages.

## Features

- **38 Languages**: Fully localized in all languages supported by the Mac MD app
- **Auto-detection**: Automatically detects browser language and displays appropriate translation
- **Language Switcher**: Dropdown menu to manually select language
- **RTL Support**: Proper right-to-left layout for Arabic and Hebrew
- **Responsive**: Beautiful on iPhone, iPad, and Mac
- **Dark Mode**: Automatically adapts to system preference

## Setup GitHub Pages

1. Go to your repository settings on GitHub
2. Navigate to "Pages" in the left sidebar
3. Under "Source", select "Deploy from a branch"
4. Under "Branch", select `main` (or your default branch) and `/docs` folder
5. Click "Save"

Your site will be available at: `https://brainvat.github.io/markdown-editor/website/`

## Generating Translations

To generate all 38 language translation files:

```bash
cd tools
python3 translate_website.py
```

This will:
- Read the English source from `locales/en.json`
- Use the macOS Translation framework (via `bridge.swift`)
- Generate translation files for all 38 languages
- Output files to `docs/website/locales/`

**Note**: Translation requires macOS with the Translation framework available.

## Local Development

Simply open `index.html` in your browser to preview locally. The language detection will work based on your browser's language settings.

To test a specific language:
1. Open the browser's developer console
2. Run: `localStorage.setItem('macmd-lang', 'es')` (replace 'es' with any language code)
3. Refresh the page

## Structure

- `index.html` - Main landing page with data-i18n attributes
- `styles.css` - All styling (responsive, dark mode, RTL support)
- `i18n.js` - Internationalization engine
- `locales/` - Translation JSON files (38 languages)
  - `en.json` - English (source)
  - `es.json` - Spanish
  - `fr.json` - French
  - ... (35 more languages)
- `README.md` - This file

## How It Works

1. **Language Detection**: On page load, `i18n.js` checks:
   - User's saved preference (localStorage)
   - Browser language (navigator.language)
   - Falls back to English

2. **Translation Loading**: Fetches the appropriate JSON file from `locales/`

3. **DOM Update**: Updates all elements with `data-i18n` attributes

4. **Language Switching**: User can manually select language from dropdown

## Supported Languages

ar, cs, da, de, el, en, en-AU, en-GB, en-IN, es, es-419, es-US, fi, fr, fr-CA, he, hi, hr, hu, id, it, ja, ko, ms, nb, nl, pa, pl, pt-BR, ro, ru, sv, th, tr, uk, vi, zh-Hans, zh-Hant
