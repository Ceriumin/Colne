import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity
import OSLog

class ShieldManager: ObservableObject {
    @Published var selection = FamilyActivitySelection()
    private let store = ManagedSettingsStore()
    private let center = AuthorizationCenter.shared
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ShieldManager")
    
    // Create a shared instance for access across the app
    static let shared = ShieldManager()
    
    init() {
        // Load any previously saved selection
        loadSavedSelection()
        
        // Request authorization when initialized
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
            } catch {
                logger.error("Failed to request authorization: \(error.localizedDescription)")
            }
        }
        
        // Set up notification observers for app data changes
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        // Listen for app data changes from other parts of the app or extensions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDataDidChange),
            name: UserDefaults.didChangeNotification,
            object: Repository.suiteUserDefaults
        )
    }
    
    @objc private func appDataDidChange() {
        DispatchQueue.main.async {
            self.updateShieldState()
        }
    }
    
    func shield() {
        logger.debug("Shielding applications: \(self.selection.applicationTokens.count) apps selected")
        
        // Block selected applications
        store.shield.applications = selection.applicationTokens.isEmpty ?
                                    nil :
                                    selection.applicationTokens
        
        // Save the selection so it persists between app launches
        saveSelection()
    }
    
    func unshield() {
        logger.debug("Unshielding all applications")
        
        // Remove all shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }
    
    // Update shield based on current app data
    func updateShieldState() {
        let decoder = JSONDecoder()
        guard let appData = Repository.suiteUserDefaults.data(forKey: "AppData"),
              let appDataModel = try? decoder.decode(AppDataModel.self, from: appData) else {
            logger.error("Failed to decode app data for shield update")
            return
        }
        
        logger.debug("Updating shield state, blocking enabled: \(appDataModel.isBlockingEnabled)")
        
        if appDataModel.isBlockingEnabled {
            shield()
        } else {
            unshield()
        }
    }
    
    // Save selection to UserDefaults
    private func saveSelection() {
        do {
            let encoder = JSONEncoder()
            let selectionData = try encoder.encode(selection)
            Repository.suiteUserDefaults.set(selectionData, forKey: "SavedAppSelection")
            logger.debug("Saved app selection with \(self.selection.applicationTokens.count) apps")
        } catch {
            logger.error("Failed to save app selection: \(error.localizedDescription)")
        }
    }
    
    // Load saved selection from UserDefaults
    private func loadSavedSelection() {
        guard let selectionData = Repository.suiteUserDefaults.data(forKey: "SavedAppSelection") else {
            logger.debug("No saved app selection found")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let savedSelection = try decoder.decode(FamilyActivitySelection.self, from: selectionData)
            self.selection = savedSelection
            logger.debug("Loaded app selection with \(self.selection.applicationTokens.count) apps")
        } catch {
            logger.error("Failed to load saved app selection: \(error.localizedDescription)")
        }
    }
}
