import AppIntents

struct ColneAppIntents: SetFocusFilterIntent {
    
    static var title: LocalizedStringResource = "Block Applications"
    
    static var description: IntentDescription = """
        Toggle application blocking when focus mode is active
        """
    
    @Dependency
    var repository: Repository
    
    @Parameter(title: "Block Applications", default: false)
    var isBlockingEnabled: Bool
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "Block Applications", subtitle: "")
    }
    
    func perform() async throws -> some IntentResult {
        let appDataModel = AppDataModel(isBlockingEnabled: self.isBlockingEnabled)
        repository.updateAppDataModelStore(appDataModel)
        return .result()
    }
}
