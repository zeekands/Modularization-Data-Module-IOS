//
//  TVShowNetworkDataSourceProtocol.swift
//  SharedData
//
//  Created by zeekands on 04/07/25.
//


import Foundation
import Combine // Penting untuk AnyPublisher

public protocol TVShowNetworkDataSourceProtocol: Sendable {
    func getPopularTVShows(page: Int) -> AnyPublisher<[TVShowDTO], TMDBAPIError>
    func getTrendingTVShows(page: Int) -> AnyPublisher<[TVShowDTO], TMDBAPIError>
    func getTVShowDetails(id: Int) -> AnyPublisher<TVShowDTO, TMDBAPIError>
    func searchTVShows(query: String, page: Int) -> AnyPublisher<[TVShowDTO], TMDBAPIError>
    func getTVShowGenres() -> AnyPublisher<[GenreDTO], TMDBAPIError>
}
