import Foundation

struct AppDataModel: Codable {
    init(isBlockingEnabled: Bool = false) {
        self.isBlockingEnabled = isBlockingEnabled
    }
    
    let isBlockingEnabled: Bool
}
