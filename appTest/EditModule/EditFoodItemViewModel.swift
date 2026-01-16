import Foundation
import Observation

@Observable
final class EditFoodItemViewModel {
    var name: String
    var calories: String
    var showErrorAlert = false
    var errorMessage = ""
    
    private let foodItem: FoodItem
    private let repository: FoodRepositoryProtocol
    private var originalItem: FoodItem?
    
    init(foodItem: FoodItem, repository: FoodRepositoryProtocol) {
        self.foodItem = foodItem
        self.repository = repository
        self.name = foodItem.name
        self.calories = String(foodItem.calories)
        
        self.originalItem = FoodItem(name: foodItem.name, calories: foodItem.calories)
    }
    
    var hasChanges: Bool {
        guard let original = originalItem else { return true }
        return name != original.name || Int(calories) != original.calories
    }
    
    var isValid: Bool {
        !name.isEmpty && Int(calories) != nil
    }
    
    @MainActor
    func saveChanges() async {
        guard let caloriesInt = Int(calories), isValid else {
            errorMessage = "Please check the entered data."
            showErrorAlert = true
            return
        }
        
        do {
            foodItem.name = name
            foodItem.calories = caloriesInt
            
            try repository.updateFoodItem(foodItem)
        } catch {
            errorMessage = "Error while saving: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
}
