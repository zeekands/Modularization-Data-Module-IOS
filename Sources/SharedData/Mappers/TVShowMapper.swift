import Foundation
import SharedDomain
import RealmSwift

public struct TVShowMapper {
  public static func toEntity(from realmObject: TVShowRealmObject) -> TVShowEntity {
    let genres = realmObject.genres.map { GenreMapper.toEntity(from: $0) }
    return TVShowEntity(
      id: realmObject.id,
      name: realmObject.name,
      overview: realmObject.overview,
      posterPath: realmObject.posterPath,
      backdropPath: realmObject.backdropPath,
      firstAirDate: realmObject.firstAirDate,
      voteAverage: realmObject.voteAverage,
      isFavorite: realmObject.isFavorite,
      genres: Array(genres)
    )
  }
  
  public static func toRealmObject(from entity: TVShowEntity) -> TVShowRealmObject {
    return TVShowRealmObject(
      id: entity.id,
      name: entity.name,
      overview: entity.overview,
      posterPath: entity.posterPath,
      backdropPath: entity.backdropPath,
      firstAirDate: entity.firstAirDate,
      voteAverage: entity.voteAverage,
      isFavorite: entity.isFavorite
    )
  }
  
  public static func updateRealmObject(_ realmObject: TVShowRealmObject, from entity: TVShowEntity) {
    realmObject.name = entity.name
    realmObject.overview = entity.overview
    realmObject.posterPath = entity.posterPath
    realmObject.backdropPath = entity.backdropPath
    realmObject.firstAirDate = entity.firstAirDate
    realmObject.voteAverage = entity.voteAverage
    realmObject.isFavorite = entity.isFavorite
  }
  
  public static func toEntity(from dto: TVShowDTO, genres: [GenreEntity] = []) -> TVShowEntity {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let firstAirDate = dto.firstAirDate.flatMap { dateFormatter.date(from: $0) }
    return TVShowEntity(
      id: dto.id,
      name: dto.name,
      overview: dto.overview,
      posterPath: dto.posterPath,
      backdropPath: dto.backdropPath,
      firstAirDate: firstAirDate,
      voteAverage: dto.voteAverage,
      isFavorite: false,
      genres: genres
    )
  }
}
