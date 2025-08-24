import Foundation
import Combine
import RealmSwift
import SharedDomain

public class TVShowRepositoryImpl: TVShowRepositoryProtocol {
  
  private let localDataSource: TVShowLocalDataSourceProtocol
  private let networkDataSource: TVShowNetworkDataSourceProtocol
  private let genreLocalDataSource: MovieLocalDataSourceProtocol
  
  public init(
    localDataSource: TVShowLocalDataSourceProtocol,
    networkDataSource: TVShowNetworkDataSourceProtocol,
    genreLocalDataSource: MovieLocalDataSourceProtocol
  ) {
    self.localDataSource = localDataSource
    self.networkDataSource = networkDataSource
    self.genreLocalDataSource = genreLocalDataSource
  }
  
  private func tvShowDTOToEntity(_ dto: TVShowDTO) throws -> TVShowEntity {
    var tvShowEntity = TVShowMapper.toEntity(from: dto)
    
    let genreEntities = try genreLocalDataSource.getLocalGenres().map { genreRealmObject in
      GenreMapper.toEntity(from: genreRealmObject)
    }
    
    tvShowEntity.genres = genreEntities
    return tvShowEntity
  }
  
  private func syncGenresFromNetwork() async throws {
    let genreDTOs = try await networkDataSource.getTVShowGenres().async()
    
    for genreDTO in genreDTOs {
      let genreEntity = GenreMapper.toEntity(from: genreDTO)
      let genreRealmObject = GenreMapper.toRealmObject(from: genreEntity)
      
      try genreLocalDataSource.addOrUpdateGenres([genreRealmObject])
    }
  }
  
  private func processAndSaveTVShows(_ tvShowDTOs: [TVShowDTO]) async throws -> [TVShowEntity] {
    var tvShowEntities: [TVShowEntity] = []
    
    for dto in tvShowDTOs {
      let tvShowEntity = try tvShowDTOToEntity(dto)
      tvShowEntities.append(tvShowEntity)
    }
    
    // Save to local database
    for tvShow in tvShowEntities {
      let localTvShow = try  localDataSource.getTVShow(by: tvShow.id)
      if localTvShow != nil { continue }
      try  localDataSource.addOrUpdateTVShow(TVShowMapper.toRealmObject(from: tvShow))
    }
    
    return tvShowEntities
  }
  
  // MARK: - Public Methods - Network Operations
  
  public func getPopularTVShows(page: Int) async throws -> [TVShowEntity] {
    try await syncGenresFromNetwork()
    
    let tvShowDTOs = try await networkDataSource.getPopularTVShows(page: page).async()
    return try await processAndSaveTVShows(tvShowDTOs)
  }
  
  public func getTrendingTVShows(page: Int) async throws -> [TVShowEntity] {
    try await syncGenresFromNetwork()
    
    let tvShowDTOs = try await networkDataSource.getTrendingTVShows(page: page).async()
    return try await processAndSaveTVShows(tvShowDTOs)
  }
  
  public func getTVShowDetails(id: Int) async throws -> TVShowEntity? {
    try await syncGenresFromNetwork()
    
    let tvShowDTO = try await networkDataSource.getTVShowDetails(id: id).async()
    var tvShowEntity = try tvShowDTOToEntity(tvShowDTO)
    
    // Check if TV show exists locally to preserve favorite status
    let localTVShow = try localDataSource.getTVShow(by: id)
    if let tvShow = localTVShow {
      tvShowEntity.isFavorite = tvShow.isFavorite
    }
    
    // Save updated TV show to local database
    try  localDataSource.addOrUpdateTVShow(TVShowMapper.toRealmObject(from: tvShowEntity))
    
    return tvShowEntity
  }
  
  public func searchTVShows(query: String, page: Int) async throws -> [TVShowEntity] {
    try await syncGenresFromNetwork()
    
    let tvShowDTOs = try await networkDataSource.searchTVShows(query: query, page: page).async()
    return try await processAndSaveTVShows(tvShowDTOs)
  }
  
  
  public func addOrUpdateTVShow(_ tvShow: TVShowEntity) async throws {
    try  localDataSource.addOrUpdateTVShow(TVShowMapper.toRealmObject(from: tvShow))
  }
  
  public func getLocalTVShow(id: Int) async throws -> TVShowEntity? {
    let realmObject = try  localDataSource.getTVShow(by: id)
    return realmObject.map { TVShowMapper.toEntity(from: $0) }
  }
  
  public func getFavoriteTVShows() async throws -> [TVShowEntity] {
    let realmObjects = try  localDataSource.getFavoriteTVShows()
    return realmObjects.map { TVShowMapper.toEntity(from: $0) }
  }
  
  public func deleteTVShow(id: Int) async throws {
    try  localDataSource.deleteTVShow(id: id)
  }
  
  public func updateTVShow(_ tvShow: TVShowEntity) async throws {
    try await addOrUpdateTVShow(tvShow)
  }
}


extension TVShowRepositoryImpl {
  
  // Caching strategy
  public func getPopularTVShowsWithCaching(page: Int, forceRefresh: Bool = false) async throws -> [TVShowEntity] {
    if !forceRefresh && page == 1 {
      let cachedTVShows = try await getFavoriteTVShows()
      if !cachedTVShows.isEmpty {
        return cachedTVShows
      }
    }
    
    return try await getPopularTVShows(page: page)
  }
  
  // Offline-first approach
  public func getPopularTVShowsOfflineFirst(page: Int) async throws -> [TVShowEntity] {
    do {
      return try await getPopularTVShows(page: page)
    } catch {
      print("Network failed, falling back to local data: \(error)")
      return try await getFavoriteTVShows()
    }
  }
  
  // Bulk operations
  public func addMultipleTVShowsToFavorites(_ tvShows: [TVShowEntity]) async throws {
    for var tvShow in tvShows {
      tvShow.isFavorite = true
      try await updateTVShow(tvShow)
    }
  }
  
  // Get recommendations based on favorite TV shows
  public func getRecommendedTVShows() async throws -> [TVShowEntity] {
    let favoriteTVShows = try await getFavoriteTVShows()
    
    // Simple recommendation: get trending shows if user has favorites
    if !favoriteTVShows.isEmpty {
      return try await getTrendingTVShows(page: 1)
    } else {
      return try await getPopularTVShows(page: 1)
    }
  }
}

// 
