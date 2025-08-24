

import Foundation
import Combine
import SharedDomain // Untuk TVShowEntity, GenreEntity


public struct TVShowNetworkDataSource: TVShowNetworkDataSourceProtocol {
  private let apiClient: TMDBAPIClient
  
  public init(apiClient: TMDBAPIClient) {
    self.apiClient = apiClient
  }
  
  public func getPopularTVShows(page: Int) -> AnyPublisher<[TVShowDTO], TMDBAPIError> {
    return apiClient.getTVShows(category: "popular", page: page)
      .map { $0.results }
      .eraseToAnyPublisher()
  }
  
  public func getTrendingTVShows(page: Int) -> AnyPublisher<[TVShowDTO], TMDBAPIError> {
    return apiClient.getTrendingTVShows(timeWindow: "day", page: page)
      .map { $0.results }
      .eraseToAnyPublisher()
  }
  
  public func getTVShowDetails(id: Int) -> AnyPublisher<TVShowDTO, TMDBAPIError> {
    return apiClient.getTVShowDetails(id: id)
  }
  
  public func searchTVShows(query: String, page: Int) -> AnyPublisher<[TVShowDTO], TMDBAPIError> {
    return apiClient.searchTVShows(query: query, page: page)
      .map { $0.results }
      .eraseToAnyPublisher()
  }
  
  public func getTVShowGenres() -> AnyPublisher<[GenreDTO], TMDBAPIError> {
    return apiClient.getTVShowGenres()
      .map { $0.genres }
      .eraseToAnyPublisher()
  }
}
