// i18n.js - Internationalization for Mac MD website

const i18n = {
    currentLang: 'en',
    translations: {},
    supportedLanguages: {
        'ar': 'العربية',
        'cs': 'Čeština',
        'da': 'Dansk',
        'de': 'Deutsch',
        'el': 'Ελληνικά',
        'en': 'English',
        'en-AU': 'English (Australia)',
        'en-GB': 'English (UK)',
        'en-IN': 'English (India)',
        'es': 'Español',
        'es-419': 'Español (Latinoamérica)',
        'es-US': 'Español (Estados Unidos)',
        'fi': 'Suomi',
        'fr': 'Français',
        'fr-CA': 'Français (Canada)',
        'he': 'עברית',
        'hi': 'हिन्दी',
        'hr': 'Hrvatski',
        'hu': 'Magyar',
        'id': 'Bahasa Indonesia',
        'it': 'Italiano',
        'ja': '日本語',
        'ko': '한국어',
        'ms': 'Bahasa Melayu',
        'nb': 'Norsk Bokmål',
        'nl': 'Nederlands',
        'pa': 'ਪੰਜਾਬੀ',
        'pl': 'Polski',
        'pt-BR': 'Português (Brasil)',
        'ro': 'Română',
        'ru': 'Русский',
        'sv': 'Svenska',
        'th': 'ไทย',
        'tr': 'Türkçe',
        'uk': 'Українська',
        'vi': 'Tiếng Việt',
        'zh-Hans': '简体中文',
        'zh-Hant': '繁體中文'
    },

    // Detect browser language
    detectLanguage() {
        // Check localStorage first
        const saved = localStorage.getItem('macmd-lang');
        if (saved && this.supportedLanguages[saved]) {
            return saved;
        }

        // Check browser language
        const browserLang = navigator.language || navigator.userLanguage;
        
        // Try exact match first
        if (this.supportedLanguages[browserLang]) {
            return browserLang;
        }

        // Try base language (e.g., 'en' from 'en-US')
        const baseLang = browserLang.split('-')[0];
        if (this.supportedLanguages[baseLang]) {
            return baseLang;
        }

        // Default to English
        return 'en';
    },

    // Load translation file
    async loadTranslations(lang) {
        try {
            const response = await fetch(`locales/${lang}.json`);
            if (!response.ok) {
                throw new Error(`Failed to load ${lang}.json`);
            }
            this.translations = await response.json();
            this.currentLang = lang;
            return true;
        } catch (error) {
            console.error(`Error loading translations for ${lang}:`, error);
            // Fallback to English if not already trying English
            if (lang !== 'en') {
                return this.loadTranslations('en');
            }
            return false;
        }
    },

    // Get nested translation value
    getTranslation(key) {
        const keys = key.split('.');
        let value = this.translations;
        
        for (const k of keys) {
            if (value && typeof value === 'object' && k in value) {
                value = value[k];
            } else {
                return key; // Return key if translation not found
            }
        }
        
        return value;
    },

    // Update DOM with translations
    updateContent() {
        // Update all elements with data-i18n attribute
        document.querySelectorAll('[data-i18n]').forEach(element => {
            const key = element.getAttribute('data-i18n');
            const translation = this.getTranslation(key);
            
            if (element.tagName === 'INPUT' || element.tagName === 'TEXTAREA') {
                element.placeholder = translation;
            } else {
                element.textContent = translation;
            }
        });

        // Update HTML lang attribute
        document.documentElement.lang = this.currentLang;

        // Update direction for RTL languages
        const rtlLanguages = ['ar', 'he'];
        document.documentElement.dir = rtlLanguages.includes(this.currentLang) ? 'rtl' : 'ltr';
    },

    // Populate language selector
    populateLanguageSelector() {
        const selector = document.getElementById('language-selector');
        if (!selector) return;

        // Clear existing options
        selector.innerHTML = '';

        // Add all supported languages
        Object.entries(this.supportedLanguages).forEach(([code, name]) => {
            const option = document.createElement('option');
            option.value = code;
            option.textContent = name;
            if (code === this.currentLang) {
                option.selected = true;
            }
            selector.appendChild(option);
        });

        // Add change event listener
        selector.addEventListener('change', async (e) => {
            const newLang = e.target.value;
            await this.changeLanguage(newLang);
        });
    },

    // Change language
    async changeLanguage(lang) {
        if (lang === this.currentLang) return;

        const success = await this.loadTranslations(lang);
        if (success) {
            this.updateContent();
            localStorage.setItem('macmd-lang', lang);
        }
    },

    // Initialize i18n
    async init() {
        const lang = this.detectLanguage();
        await this.loadTranslations(lang);
        this.updateContent();
        this.populateLanguageSelector();
    }
};

// Initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => i18n.init());
} else {
    i18n.init();
}
