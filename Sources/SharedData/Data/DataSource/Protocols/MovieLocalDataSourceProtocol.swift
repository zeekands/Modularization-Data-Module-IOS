import Foundation
import RealmSwift

public protocol MovieLocalDataSourceProtocol {
  func addOrUpdateMovie(_ movie: MovieRealmObject) throws
  func getMovies() throws -> [MovieRealmObject]
  func getMovie(by id: Int) throws -> MovieRealmObject?
  func getFavoriteMovies() throws -> [MovieRealmObject]
  func deleteMovie(id: Int) throws
  func addOrUpdateGenres(_ genres: [GenreRealmObject]) throws
  func getLocalGenres() throws -> [GenreRealmObject]
  func getGenre(by id: Int) throws -> GenreRealmObject?
}

public struct MovieLocalDataSource: MovieLocalDataSourceProtocol {
  private let realmDataSource: RealmDataSource
  
  public init(realmDataSource: RealmDataSource) {
    self.realmDataSource = realmDataSource
  }
  
  public func addOrUpdateMovie(_ movieRealmObject: MovieRealmObject) throws {
    try realmDataSource.addOrUpdate(movieRealmObject)
  }
  
  public func getMovies() throws -> [MovieRealmObject] {
    return Array(try realmDataSource.fetchAll(MovieRealmObject.self))
  }
  
  public func getMovie(by id: Int) throws -> MovieRealmObject? {
    return try realmDataSource.fetchObject(MovieRealmObject.self, by: id)
  }
  
  public func getFavoriteMovies() throws -> [MovieRealmObject] {
    let realm = try realmDataSource.getRealm()
    return Array(realm.objects(MovieRealmObject.self).filter("isFavorite == true"))
  }
  
  public func deleteMovie(id: Int) throws {
    try realmDataSource.delete(MovieRealmObject.self, by: id)
  }
  
  public func addOrUpdateGenres(_ genreRealmObjects: [GenreRealmObject]) throws {
    try realmDataSource.addOrUpdate(genreRealmObjects)
  }
  
  public func getLocalGenres() throws -> [GenreRealmObject] {
    return Array(try realmDataSource.fetchAll(GenreRealmObject.self))
  }
  
  public func getGenre(by id: Int) throws -> GenreRealmObject? {
    return try realmDataSource.fetchObject(GenreRealmObject.self, by: id)
  }
}
