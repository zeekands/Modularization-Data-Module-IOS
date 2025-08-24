import Foundation
import SharedDomain
import RealmSwift

public struct MovieMapper: Sendable {
  // Mengonversi MovieRealmObject menjadi MovieEntity
  public static func toEntity(from realmObject: MovieRealmObject) -> MovieEntity {
    let genres = realmObject.genres.map { GenreMapper.toEntity(from: $0) }
    return MovieEntity(
      id: realmObject.id,
      title: realmObject.title,
      overview: realmObject.overview,
      posterPath: realmObject.posterPath,
      backdropPath: realmObject.backdropPath,
      releaseDate: realmObject.releaseDate,
      voteAverage: realmObject.voteAverage,
      isFavorite: realmObject.isFavorite,
      genres: Array(genres) // Convert List to Array
    )
  }
  
  // Mengonversi MovieEntity menjadi MovieRealmObject baru
  public static func toRealmObject(from entity: MovieEntity) -> MovieRealmObject {
    return MovieRealmObject(
      id: entity.id,
      title: entity.title,
      overview: entity.overview,
      posterPath: entity.posterPath,
      backdropPath: entity.backdropPath,
      releaseDate: entity.releaseDate,
      voteAverage: entity.voteAverage,
      isFavorite: entity.isFavorite
    )
  }
  
  // Memperbarui MovieRealmObject yang sudah ada dari MovieEntity
  public static func updateRealmObject(_ realmObject: MovieRealmObject, from entity: MovieEntity) {
    realmObject.title = entity.title
    realmObject.overview = entity.overview
    realmObject.posterPath = entity.posterPath
    realmObject.backdropPath = entity.backdropPath
    realmObject.releaseDate = entity.releaseDate
    realmObject.voteAverage = entity.voteAverage
    realmObject.isFavorite = entity.isFavorite
    // Genre relationship update will be handled in repository if necessary.
    // realmObject.genres.removeAll()
    // realmObject.genres.append(objectsIn: entity.genres.map { GenreMapper.toRealmObject(from: $0) }) // Only if genres are always updated in bulk
  }
  
  // Mengonversi MovieDTO menjadi MovieEntity (tetap sama dari sebelumnya)
  public static func toEntity(from dto: MovieDTO, genres: [GenreEntity] = []) -> MovieEntity {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let releaseDate = dto.releaseDate.flatMap { dateFormatter.date(from: $0) }
    return MovieEntity(
      id: dto.id,
      title: dto.title,
      overview: dto.overview,
      posterPath: dto.posterPath,
      backdropPath: dto.backdropPath,
      releaseDate: releaseDate,
      voteAverage: dto.voteAverage,
      isFavorite: false,
      genres: genres
    )
  }
}
