import Foundation

class MockFoodRepository: FoodRepositoryProtocol {
    func getAllFoodItems() throws -> [FoodItem] {
        return []
    }
    
    func addFoodItem(name: String, calories: Int) throws -> FoodItem {
        return FoodItem(name: name, calories: calories)
    }
    
    func deleteFoodItem(_ item: FoodItem) throws {}
    
    func updateFoodItem(_ item: FoodItem) throws {}
}
