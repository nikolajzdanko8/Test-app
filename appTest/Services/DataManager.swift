import SwiftData

final class DataManager {
    static let shared = DataManager()
    
    let modelContainer: ModelContainer
    
    private init() {
        do {
            modelContainer = try ModelContainer(for: FoodItem.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
