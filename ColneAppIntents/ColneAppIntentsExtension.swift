import AppIntents
import FamilyControls
import ManagedSettings
import OSLog
import SwiftUI
import DeviceActivity

@main
struct ColneAppIntentsExtension: AppIntentsExtension {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppIntentsExtension")
    
    // Store a reference to the notification observer
    private static var notificationObserver: Any?
    
    init() {
        AppDependencyManager.shared.add(dependency: Repository.shared)
        
        // Set up notification observer as a static property instead of capturing 'self'
        Self.setupNotificationObserver()
    }
    
    // Static method to handle notification setup
    private static func setupNotificationObserver() {
        // Remove previous observer if it exists
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        // Create a new observer
        notificationObserver = NotificationCenter.default.addObserver(
            forName: Repository.appDataUpdatedNotification,
            object: nil,
            queue: .main
        ) { _ in
            updateShieldingFromAppDataStatic()
        }
    }
    
    // Static version of updateShieldingFromAppData
    private static func updateShieldingFromAppDataStatic() {
        // Access the app data and update shielding immediately
        let decoder = JSONDecoder()
        guard let appData = Repository.suiteUserDefaults.data(forKey: "AppData"),
              let appDataModel = try? decoder.decode(AppDataModel.self, from: appData) else {
            let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppIntentsExtension")
            logger.error("Failed to decode app data for shield update in extension")
            return
        }
        
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppIntentsExtension")
        logger.debug("Extension updating shield state, blocking enabled: \(appDataModel.isBlockingEnabled)")
        
        // Create a temporary shield manager to handle the update
        let shieldManager = ShieldManager()
        
        // Load selection data to ensure it has the correct apps selected
        shieldManager.loadSavedSelectionIfNeeded()
        
        // Update shield based on current settings
        if appDataModel.isBlockingEnabled {
            shieldManager.shield()
        } else {
            shieldManager.unshield()
        }
    }
}
