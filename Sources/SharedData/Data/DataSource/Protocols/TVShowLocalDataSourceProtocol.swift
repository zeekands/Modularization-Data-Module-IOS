import Foundation
import RealmSwift
import SharedDomain

public protocol TVShowLocalDataSourceProtocol {
  func addOrUpdateTVShow(_ tvShow: TVShowRealmObject)   throws
  func getTVShows()   throws -> [TVShowRealmObject]
  func getTVShow(by id: Int)   throws -> TVShowRealmObject?
  func getFavoriteTVShows()   throws -> [TVShowRealmObject]
  func deleteTVShow(id: Int)   throws
  func addOrUpdateGenres(_ genres: [GenreRealmObject])   throws
  func getLocalGenres()   throws -> [GenreRealmObject]
  func getGenre(by id: Int)   throws -> GenreRealmObject?
}

public struct TVShowLocalDataSource: TVShowLocalDataSourceProtocol {
  private let realmDataSource: RealmDataSource
  
  public init(realmDataSource: RealmDataSource) {
    self.realmDataSource = realmDataSource
  }
  
  public func addOrUpdateTVShow(_ tvShowRealmObject: TVShowRealmObject)   throws {
    try realmDataSource.addOrUpdate(tvShowRealmObject)
  }
  
  public func getTVShows()   throws -> [TVShowRealmObject] {
    return Array(try realmDataSource.fetchAll(TVShowRealmObject.self))
  }
  
  public func getTVShow(by id: Int)   throws -> TVShowRealmObject? {
    return try realmDataSource.fetchObject(TVShowRealmObject.self, by: id)
  }
  
  public func getFavoriteTVShows()   throws -> [TVShowRealmObject] {
    let realm = try realmDataSource.getRealm()
    return Array(realm.objects(TVShowRealmObject.self).filter("isFavorite == true"))
  }
  
  public func deleteTVShow(id: Int)   throws {
    try realmDataSource.delete(TVShowRealmObject.self, by: id)
  }
  
  public func addOrUpdateGenres(_ genreRealmObjects: [GenreRealmObject])   throws {
    try realmDataSource.addOrUpdate(genreRealmObjects)
  }
  
  public func getLocalGenres()   throws -> [GenreRealmObject] {
    return Array(try realmDataSource.fetchAll(GenreRealmObject.self))
  }
  
  public func getGenre(by id: Int)   throws -> GenreRealmObject? {
    return try realmDataSource.fetchObject(GenreRealmObject.self, by: id)
  }
}
