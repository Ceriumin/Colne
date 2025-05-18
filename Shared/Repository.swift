import OSLog
import AppIntents

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
    static let appDataUpdatedNotification = Notification.Name("appDataUpdatedNotification")
    
    static var suiteUserDefaults = UserDefaults(suiteName: "group.com.rileytestut.AltStore.TB65GXLC46")!
    
    func updateAppDataModelStore(_ appDataModel: AppDataModel) {
        let encoder = JSONEncoder()
        do {
            let appDataModelEncoded = try encoder.encode(appDataModel)
            Self.suiteUserDefaults.set(appDataModelEncoded, forKey: "AppData")
            
            // Post notification when app data is updated
            NotificationCenter.default.post(name: Repository.appDataUpdatedNotification, object: nil)
        } catch {
            //
        }
    }
}
