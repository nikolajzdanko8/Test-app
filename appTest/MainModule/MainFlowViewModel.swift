import Observation
import SwiftUI

@Observable
final class MainFlowViewModel {
    var foodItems: [FoodItem] = []
    var inputText: String = ""
    var showingAddAlert: Bool = false
    var alertMessage: String = ""
    var itemToDelete: FoodItem?
    var itemToEdit: FoodItem?
    
    private let foodRepository: FoodRepositoryProtocol
    
    var totalCalories: Int {
        foodItems.reduce(0) { $0 + $1.calories }
    }
    
    init(foodRepository: FoodRepositoryProtocol) {
        self.foodRepository = foodRepository
        
        Task {
            await loadFoodItems()
        }
    }
    
    @MainActor
    func loadFoodItems() async {
        do {
            foodItems = try foodRepository.getAllFoodItems()
        } catch {
            alertMessage = "Error loading data: \(error.localizedDescription)"
            showingAddAlert = true
        }
    }
    
    @MainActor
    func addFoodItem() async {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let components = trimmedText.components(separatedBy: " ")
        
        guard components.count >= 2 else {
            alertMessage = "Enter the product name and calorie count separated by a space. For example: 'Orange 12'"
            showingAddAlert = true
            return
        }
        
        guard let calories = Int(components.last!) else {
            alertMessage = "Calories must be a number. For example: 'Orange 12'"
            showingAddAlert = true
            return
        }
        
        let name = components.dropLast().joined(separator: " ").trimmingCharacters(in: .whitespaces)
        
        guard !name.isEmpty else {
            alertMessage = "Enter the product name. For example: 'Orange 12'"
            showingAddAlert = true
            return
        }
        
        let existingItem = foodItems.first { $0.name.lowercased() == name.lowercased() }
        if existingItem != nil {
            alertMessage = "The product \"\(name)\" is already in the list. Do you want to add it again?"
            showingAddAlert = true
        }
        
        do {
            let newItem = try foodRepository.addFoodItem(name: name, calories: calories)
            foodItems.insert(newItem, at: 0)
            inputText = ""
        } catch {
            alertMessage = "Error adding product: \(error.localizedDescription)"
            showingAddAlert = true
        }
    }
    
    @MainActor
    func deleteItem(_ item: FoodItem) async {
        do {
            try foodRepository.deleteFoodItem(item)
            if let index = foodItems.firstIndex(where: { $0.id == item.id }) {
                foodItems.remove(at: index)
            }
        } catch {
            alertMessage = "Error deleting product: \(error.localizedDescription)"
            showingAddAlert = true
        }
    }
    
    @MainActor
    func updateItem(_ item: FoodItem) async {
        do {
            try foodRepository.updateFoodItem(item)
            if let index = foodItems.firstIndex(where: { $0.id == item.id }) {
                foodItems[index] = item
            }
        } catch {
            alertMessage = "Error updating product: \(error.localizedDescription)"
            showingAddAlert = true
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = foodItems[index]
            itemToDelete = item
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
