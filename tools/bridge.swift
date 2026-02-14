import Foundation
import Translation

struct TranslationBridge {
    static func main() async {
        let args = CommandLine.arguments
        
        // Expecting: bridge <source_lang> <target_lang> <text>
        guard args.count >= 4 else {
            fputs("Usage: bridge <source_lang> <target_lang> <text>\n", stderr)
            exit(1)
        }
        
        let sourceLang = args[1]
        let targetLang = args[2]
        let textToTranslate = args[3]
        
        let sourceLanguage = Locale.Language(identifier: sourceLang)
        let targetLanguage = Locale.Language(identifier: targetLang)
        
        let session = TranslationSession(installedSource: sourceLanguage, target: targetLanguage)
        
        do {
            // Execution of the on-device ML model
            let response = try await session.translate(textToTranslate)
            print(response.targetText)
            exit(0)
        } catch {
            // Fails if language packs are missing or unsupported
            fputs("Error: \(error.localizedDescription)\n", stderr)
            exit(1)
        }
    }
}

// Run the async main function
Task {
    await TranslationBridge.main()
}

// Keep the program running
RunLoop.main.run()
