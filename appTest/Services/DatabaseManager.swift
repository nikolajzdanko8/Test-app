import Foundation
import SwiftData

protocol DatabaseManagerProtocol {
    func save<T: PersistentModel>(_ item: T) throws
    func delete<T: PersistentModel>(_ item: T) throws
    func fetch<T: PersistentModel>(_ type: T.Type) throws -> [T]
    func update<T: PersistentModel>(_ item: T) throws
}

final class DatabaseManager: DatabaseManagerProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func save<T: PersistentModel>(_ item: T) throws {
        modelContext.insert(item)
        try modelContext.save()
    }
    
    func delete<T: PersistentModel>(_ item: T) throws {
        modelContext.delete(item)
        try modelContext.save()
    }
    
    func fetch<T: PersistentModel>(_ type: T.Type) throws -> [T] {
        let descriptor = FetchDescriptor<T>()
        return try modelContext.fetch(descriptor)
    }
    
    func update<T: PersistentModel>(_ item: T) throws {
        try modelContext.save()
    }
}
