import Foundation
import Combine
import SharedDomain

public struct GenreRepositoryImpl: GenreRepositoryProtocol {
  private let apiClient: TMDBAPIClient
  private let movieLocalDataSource: MovieLocalDataSourceProtocol
  private let tvShowLocalDataSource: TVShowLocalDataSourceProtocol
  
  public init(apiClient: TMDBAPIClient, movieLocalDataSource: MovieLocalDataSourceProtocol, tvShowLocalDataSource: TVShowLocalDataSourceProtocol) {
    self.apiClient = apiClient
    self.movieLocalDataSource = movieLocalDataSource
    self.tvShowLocalDataSource = tvShowLocalDataSource
  }
  
  public func getMovieGenres() async throws -> [GenreEntity] {
    do {
      let genresResponse: GenresResponse = try await firstValue(from: apiClient.getMovieGenres())
      let genreDTOs = genresResponse.genres
      
      let genreEntities = genreDTOs.map { GenreMapper.toEntity(from: $0) }
      let genreRealmObjects = genreEntities.map { GenreMapper.toRealmObject(from: $0) }
      
      try  movieLocalDataSource.addOrUpdateGenres(genreRealmObjects)
      
      return genreEntities
    } catch {
      print("Error fetching movie genres from API, falling back to local: \(error.localizedDescription)")
      do {
        let localGenreRealmObjects = try  movieLocalDataSource.getLocalGenres()
        return localGenreRealmObjects.map { GenreMapper.toEntity(from: $0) }
      } catch {
        print("Error getting local movie genres: \(error.localizedDescription)")
        throw error
      }
    }
  }
  
  public func getTVShowGenres() async throws -> [GenreEntity] {
    do {
      let genresResponse: GenresResponse = try await firstValue(from: apiClient.getTVShowGenres())
      let genreDTOs = genresResponse.genres
      
      let genreEntities = genreDTOs.map { GenreMapper.toEntity(from: $0) }
      let genreRealmObjects = genreEntities.map { GenreMapper.toRealmObject(from: $0) }
      
      try  tvShowLocalDataSource.addOrUpdateGenres(genreRealmObjects)
      
      return genreEntities
    } catch {
      print("Error fetching TV show genres from API, falling back to local: \(error.localizedDescription)")
      do {
        let localGenreRealmObjects = try  tvShowLocalDataSource.getLocalGenres()
        return localGenreRealmObjects.map { GenreMapper.toEntity(from: $0) }
      } catch {
        print("Error getting local TV show genres: \(error.localizedDescription)")
        throw error
      }
    }
  }
  
  public func getLocalGenres() async throws -> [GenreEntity] {
    let localGenreRealmObjects = try  movieLocalDataSource.getLocalGenres()
    return localGenreRealmObjects.map { GenreMapper.toEntity(from: $0) }
  }
  
  public func addOrUpdateGenre(_ genre: GenreEntity) async throws {
    let genreRealmObject = GenreMapper.toRealmObject(from: genre)
    try  movieLocalDataSource.addOrUpdateGenres([genreRealmObject])
  }
}
