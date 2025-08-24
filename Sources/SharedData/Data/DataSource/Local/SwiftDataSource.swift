import Foundation
import SwiftData

@MainActor
public class SwiftDataSource: @unchecked Sendable {
  public let modelContext: ModelContext
  
  public init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }
  
  public func add<T: PersistentModel>(_ model: T) async throws {
    modelContext.insert(model)
    try await saveContext()
  }
  
  public func fetch<T: PersistentModel>(
    predicate: Predicate<T>? = nil,
    sortBy: [SortDescriptor<T>] = [],
    limit: Int? = nil
  ) async throws -> [T] {
    var descriptor = FetchDescriptor(predicate: predicate, sortBy: sortBy)
    descriptor.fetchLimit = limit
    do {
      return try modelContext.fetch(descriptor)
    } catch {
      throw error
    }
  }
  
  public func delete<T: PersistentModel & Identifiable>(_ type: T.Type, id: Int) async throws where T.ID == Int {
    do {
      let predicate = #Predicate<T> { $0.id == id }
      try modelContext.delete(model: T.self, where: predicate)
      try await saveContext()
    } catch {
      throw error
    }
  }
  
  public func fetchObject<T: PersistentModel & Identifiable>(_ type: T.Type, by id: Int) async throws -> T? where T.ID == Int {
    let predicate = #Predicate<T> { $0.id == id }
    let descriptor = FetchDescriptor(predicate: predicate)
    do {
      return try modelContext.fetch(descriptor).first
    } catch {
      throw error
    }
  }
  
  public func update() async throws {
    try await saveContext()
  }
  
  private func saveContext() async throws {
    do {
      try modelContext.save()
    } catch {
      throw error
    }
  }
}
