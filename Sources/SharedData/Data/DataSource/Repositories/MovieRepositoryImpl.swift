import Foundation
import Combine
import RealmSwift
import SharedDomain


public class MovieRepositoryImpl: MovieRepositoryProtocol {
  private let localDataSource: MovieLocalDataSourceProtocol
  private let networkDataSource: MovieNetworkDataSourceProtocol
  private let genreLocalDataSource: MovieLocalDataSourceProtocol
  
  public init(
    localDataSource: MovieLocalDataSourceProtocol,
    networkDataSource: MovieNetworkDataSourceProtocol,
    genreLocalDataSource: MovieLocalDataSourceProtocol
  ) {
    self.localDataSource = localDataSource
    self.networkDataSource = networkDataSource
    self.genreLocalDataSource = genreLocalDataSource
  }
  
  private func movieDTOToEntity(_ dto: MovieDTO) throws -> MovieEntity {
    var movieEntity = MovieMapper.toEntity(from: dto)
    
    let genreEntities = try genreLocalDataSource.getLocalGenres().map { genreRealmObject in
      GenreMapper.toEntity(from: genreRealmObject)
    }
    
    movieEntity.genres = genreEntities
    return movieEntity
  }
  
  private func syncGenresFromNetwork() async throws {
    let genreDTOs = try await networkDataSource.getMovieGenres().async()
    
    for genreDTO in genreDTOs {
      let genreEntity = GenreMapper.toEntity(from: genreDTO)
      let genreRealmObject = GenreMapper.toRealmObject(from: genreEntity)
      
      try genreLocalDataSource.addOrUpdateGenres([genreRealmObject])
    }
  }
  
  private func processAndSaveMovies(_ movieDTOs: [MovieDTO]) async throws -> [MovieEntity] {
    var movieEntities: [MovieEntity] = []
    
    for dto in movieDTOs {
      let movieEntity = try movieDTOToEntity(dto)
      movieEntities.append(movieEntity)
    }
    
    // Save to local database
    for movie in movieEntities {
      let localMovie = try localDataSource.getMovie(by: movie.id)
      if localMovie != nil { continue }
      try localDataSource.addOrUpdateMovie(MovieMapper.toRealmObject(from: movie))
    }
    
    return movieEntities
  }
  
  public func getPopularMovies(page: Int) async throws -> [MovieEntity] {
    try await syncGenresFromNetwork()
    
    let movieDTOs = try await networkDataSource.getPopularMovies(page: page).async()
    return try await processAndSaveMovies(movieDTOs)
  }
  
  public func getTrendingMovies(page: Int) async throws -> [MovieEntity] {
    try await syncGenresFromNetwork()
    
    let movieDTOs = try await networkDataSource.getTrendingMovies(page: page).async()
    return try await processAndSaveMovies(movieDTOs)
  }
  
  public func getMovieDetails(id: Int) async throws -> MovieEntity? {
    try await syncGenresFromNetwork()
    
    let movieDTO = try await networkDataSource.getMovieDetails(id: id).async()
    var movieEntity = try movieDTOToEntity(movieDTO)
    
    // Check if movie exists locally to preserve favorite status
    let localMovie = try localDataSource.getMovie(by: id)
    if let movie = localMovie {
      movieEntity.isFavorite = movie.isFavorite
    }
    
    // Save updated movie to local database
    try localDataSource.addOrUpdateMovie(MovieMapper.toRealmObject(from: movieEntity))
    
    return movieEntity
  }
  
  public func searchMovies(query: String, page: Int) async throws -> [MovieEntity] {
    try await syncGenresFromNetwork()
    
    let movieDTOs = try await networkDataSource.searchMovies(query: query, page: page).async()
    return try await processAndSaveMovies(movieDTOs)
  }
  
  public func addOrUpdateMovie(_ movie: MovieEntity) async throws {
    try localDataSource.addOrUpdateMovie(MovieMapper.toRealmObject(from: movie))
  }
  
  public func getLocalMovie(id: Int) async throws -> MovieEntity? {
    let realmObject = try localDataSource.getMovie(by: id)
    return realmObject.map { MovieMapper.toEntity(from: $0) }
  }
  
  public func getFavoriteMovies() async throws -> [MovieEntity] {
    let realmObjects = try localDataSource.getFavoriteMovies()
    return realmObjects.map { MovieMapper.toEntity(from: $0) }
  }
  
  public func deleteMovie(id: Int) async throws {
    try localDataSource.deleteMovie(id: id)
  }
  
  public func updateMovie(_ movie: MovieEntity) async throws {
    try await addOrUpdateMovie(movie)
  }
}

extension MovieRepositoryImpl {
  public func getPopularMoviesWithCaching(page: Int, forceRefresh: Bool = false) async throws -> [MovieEntity] {
    if !forceRefresh && page == 1 {
      let cachedMovies = try await getFavoriteMovies() // Or implement proper cache logic
      if !cachedMovies.isEmpty {
        return cachedMovies
      }
    }
    
    return try await getPopularMovies(page: page)
  }
}

extension MovieRepositoryImpl {
  public func getPopularMoviesOfflineFirst(page: Int) async throws -> [MovieEntity] {
    do {
      // Try network first
      return try await getPopularMovies(page: page)
    } catch {
      // Fallback to local data
      print("Network failed, falling back to local data: \(error)")
      return try await getFavoriteMovies() // Or implement proper local fallback
    }
  }
}
