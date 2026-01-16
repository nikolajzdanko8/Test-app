import Foundation

protocol FoodRepositoryProtocol {
    func getAllFoodItems() throws -> [FoodItem]
    func addFoodItem(name: String, calories: Int) throws -> FoodItem
    func deleteFoodItem(_ item: FoodItem) throws
    func updateFoodItem(_ item: FoodItem) throws
}

final class FoodRepository: FoodRepositoryProtocol {
    private let databaseManager: DatabaseManagerProtocol
    
    init(databaseManager: DatabaseManagerProtocol) {
        self.databaseManager = databaseManager
    }
    
    func getAllFoodItems() throws -> [FoodItem] {
        try databaseManager.fetch(FoodItem.self).sorted { $0.dateAdded > $1.dateAdded }
    }
    
    func addFoodItem(name: String, calories: Int) throws -> FoodItem {
        let item = FoodItem(name: name, calories: calories)
        try databaseManager.save(item)
        return item
    }
    
    func deleteFoodItem(_ item: FoodItem) throws {
        try databaseManager.delete(item)
    }
    
    func updateFoodItem(_ item: FoodItem) throws {
        try databaseManager.update(item)
    }
}
