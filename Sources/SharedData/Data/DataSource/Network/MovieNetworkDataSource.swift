//
//  MovieNetworkDataSource.swift
//  SharedData
//
//  Created by zeekands on 04/07/25.
//


import Foundation
import Combine
import SharedDomain


public struct MovieNetworkDataSource: MovieNetworkDataSourceProtocol {
    private let apiClient: TMDBAPIClient

    public init(apiClient: TMDBAPIClient) {
        self.apiClient = apiClient
    }

    public func getPopularMovies(page: Int) -> AnyPublisher<[MovieDTO], TMDBAPIError> {
        return apiClient.getMovies(category: "popular", page: page)
            .map { $0.results }
            .eraseToAnyPublisher()
    }

    public func getTrendingMovies(page: Int) -> AnyPublisher<[MovieDTO], TMDBAPIError> {
      return apiClient.getTrendingMovies(timeWindow: "day", page: page)
            .map { $0.results }
            .eraseToAnyPublisher()
    } 
    
    public func getMovieDetails(id: Int) -> AnyPublisher<MovieDTO, TMDBAPIError> {
        return apiClient.getMovieDetails(id: id)
    }
    
    public func searchMovies(query: String, page: Int) -> AnyPublisher<[MovieDTO], TMDBAPIError> {
        return apiClient.searchMovies(query: query, page: page)
            .map { $0.results }
            .eraseToAnyPublisher()
    }

    public func getMovieGenres() -> AnyPublisher<[GenreDTO], TMDBAPIError> {
        return apiClient.getMovieGenres()
            .map { $0.genres }
            .eraseToAnyPublisher()
    }
}
