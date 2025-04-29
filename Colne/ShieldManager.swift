import SwiftUI
import ManagedSettings
import FamilyControls
import DeviceActivity

class ShieldManager: ObservableObject {
    @Published var selection = FamilyActivitySelection()
    private let store = ManagedSettingsStore()
    
    func shield() {
        // Apply restrictions based on selected apps/websites
        let applications = selection.applicationTokens
        let categories = selection.categoryTokens
        
        // Handle application restrictions
        if !applications.isEmpty {
            store.shield.applications = applications
        } else {
            store.shield.applications = nil
        }
        
        // Handle category restrictions with proper type conversion
        if !categories.isEmpty {
            store.shield.applicationCategories = .specific(categories)
        } else {
            store.shield.applicationCategories = nil
        }
    }
    
    func unshield() {
        // Remove all restrictions
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }
}
