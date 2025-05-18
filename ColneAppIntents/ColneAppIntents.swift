import AppIntents
import OSLog

struct ColneAppIntents: SetFocusFilterIntent {
    
    static var title: LocalizedStringResource = "Block Applications"
    
    static var description: IntentDescription = """
        Toggle application blocking when focus mode is active
        """
    
    @Dependency
    var repository: Repository
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ColneAppIntents")
    
    @Parameter(title: "Block Applications", default: false)
    var isBlockingEnabled: Bool
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "Block Applications", subtitle: "")
    }
    
    func perform() async throws -> some IntentResult {
        logger.debug("Focus filter intent executed with blocking enabled: \(isBlockingEnabled)")
        
        // Update app data model
        let appDataModel = AppDataModel(isBlockingEnabled: self.isBlockingEnabled)
        repository.updateAppDataModelStore(appDataModel)
        
        // Create a temporary shield manager to handle the update immediately
        let shieldManager = ShieldManager()
        
        // Load selection data to ensure it has the correct apps selected
        shieldManager.loadSavedSelectionIfNeeded()
        
        // Update shield based on current settings
        if self.isBlockingEnabled {
            shieldManager.shield()
        } else {
            shieldManager.unshield()
        }
        
        return .result()
    }
}
