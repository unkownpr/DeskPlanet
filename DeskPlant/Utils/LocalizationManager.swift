import Foundation
import SwiftUI

// MARK: - Language Enum
enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case turkish = "tr"
    case french = "fr"
    case german = "de"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        case .french: return "Français"
        case .german: return "Deutsch"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .turkish: return "🇹🇷"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        }
    }
}

// MARK: - Localization Manager
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "AppLanguage")
            // Dil değiştiğinde tüm view'ları yenile
            NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
        }
    }
    
    private init() {
        // Kaydedilmiş dil varsa onu kullan, yoksa default İngilizce
        let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"
        self.currentLanguage = Language(rawValue: savedLanguage) ?? .english
    }
    
    func localizedString(_ key: String) -> String {
        let language = currentLanguage.rawValue
        
        // Dil klasörünün yolunu bul
        guard let bundlePath = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: bundlePath) else {
            // Fallback to English
            return NSLocalizedString(key, comment: "")
        }
        
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}

// MARK: - String Extension for easy localization
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

