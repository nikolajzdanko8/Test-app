import Foundation
import SwiftData

@Model
final class FoodItem: Identifiable {
    var id: UUID
    var name: String
    var calories: Int
    var dateAdded: Date
    
    init(name: String, calories: Int) {
        self.id = UUID()
        self.name = name
        self.calories = calories
        self.dateAdded = Date()
    }
}
