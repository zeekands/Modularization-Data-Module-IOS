import Foundation
import SharedDomain
import RealmSwift

public struct GenreMapper: Sendable {
  public static func toEntity(from realmObject: GenreRealmObject) -> GenreEntity {
    return GenreEntity(
      id: realmObject.id,
      name: realmObject.name
    )
  }
  
  public static func toRealmObject(from entity: GenreEntity) -> GenreRealmObject {
    return GenreRealmObject(
      id: entity.id,
      name: entity.name
    )
  }
  
  public static func updateRealmObject(_ realmObject: GenreRealmObject, from entity: GenreEntity) {
    realmObject.name = entity.name
  }
  
  public static func toEntity(from dto: GenreDTO) -> GenreEntity {
    return GenreEntity(id: dto.id, name: dto.name)
  }
}
