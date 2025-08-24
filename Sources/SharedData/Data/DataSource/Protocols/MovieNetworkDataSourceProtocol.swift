//
//  MovieNetworkDataSourceProtocol.swift
//  SharedData
//
//  Created by zeekands on 04/07/25.
//


import Foundation
import Combine // Penting untuk AnyPublisher

public protocol MovieNetworkDataSourceProtocol: Sendable {
    func getPopularMovies(page: Int) -> AnyPublisher<[MovieDTO], TMDBAPIError>
    func getTrendingMovies(page: Int) -> AnyPublisher<[MovieDTO], TMDBAPIError>
    func getMovieDetails(id: Int) -> AnyPublisher<MovieDTO, TMDBAPIError>
    func searchMovies(query: String, page: Int) -> AnyPublisher<[MovieDTO], TMDBAPIError>
    func getMovieGenres() -> AnyPublisher<[GenreDTO], TMDBAPIError>
}
