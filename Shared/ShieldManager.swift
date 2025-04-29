import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity
import OSLog

class ShieldManager: ObservableObject {
    @Published var selection = FamilyActivitySelection()
    private let store = ManagedSettingsStore()
    private let center = AuthorizationCenter.shared
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app.Colne", category: "ShieldManager")
    
    // Create a shared instance for access across the app
    static let shared = ShieldManager()
    
    init() {
        // Load any previously saved selection
        loadSavedSelectionIfNeeded()
        
        // Request authorization when initialized
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
            } catch {
                logger.error("Failed to request authorization: \(error.localizedDescription)")
            }
        }
        
        // Set up notification observers for app data changes
        NotificationCenter.default.addObserver(
            forName: Repository.appDataUpdatedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateShieldState()
        }
    }
    
    func selectionDidChange() {
        // Save the selection
        saveSelection()
        
    }
    
    func shield() {
        let appCount = self.selection.applicationTokens.count
        let categoryCount = self.selection.categoryTokens.count
        
        logger.debug("Shielding applications: \(appCount) apps, \(categoryCount) categories selected")
        
        // Block selected applications
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        
        // Block selected categories
        if selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = nil
        } else {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }
        
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
    func loadSavedSelectionIfNeeded() {
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
