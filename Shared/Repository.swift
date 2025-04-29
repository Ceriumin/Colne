import OSLog
import AppIntents

/// - Tag: Repository
final class Repository: Sendable {
    enum RepositoryError: Error, CustomLocalizedStringResourceConvertible {
        case notFound
        
        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .notFound: return "Element not found"
            }
        }
    }
    
    static let shared = Repository()
    
    static var suiteUserDefaults = UserDefaults(suiteName: "group.com.rileytestut.AltStore.TB65GXLC46")!
    
    func updateAppDataModelStore(_ appDataModel: AppDataModel) {
        let encoder = JSONEncoder()
        do {
            let appDataModelEncoded = try encoder.encode(appDataModel)
            Self.suiteUserDefaults.set(appDataModelEncoded, forKey: "AppData")
            logger.debug("Stored app data model")
        } catch {
            logger.error("Failed to encode app data model \(error.localizedDescription)")
        }
    }
}

extension Repository {
    var logger: Logger {
        let subsystem = Bundle.main.bundleIdentifier!
        return Logger(subsystem: subsystem, category: "Repository")
    }
}
