import Observation
import SwiftData

@Observable
final class DependencyContainer {
    private let modelContext: ModelContext
    private(set) var contentViewModel: MainFlowViewModel
    private(set) var foodRepository: FoodRepositoryProtocol
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        let databaseManager = DatabaseManager(modelContext: modelContext)
        let repository = FoodRepository(databaseManager: databaseManager)
        self.foodRepository = repository
        
        self.contentViewModel = MainFlowViewModel(foodRepository: repository)
    }
    
    func makeEditFoodItemViewModel(foodItem: FoodItem) -> EditFoodItemViewModel {
        EditFoodItemViewModel(foodItem: foodItem, repository: foodRepository)
    }
}
