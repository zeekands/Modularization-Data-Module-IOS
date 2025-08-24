//
//  MovieDTO.swift
//  SharedData
//
//  Created by zeekands on 05/07/25.
//


import Foundation
import SharedDomain

public struct MovieDTO: Decodable, Sendable {
  public let id: Int
  public let title: String
  public let overview: String?
  public let posterPath: String?
  public let backdropPath: String?
  public let releaseDate: String?
  public let voteAverage: Double?
  public let genreIds: [Int]?
  
}
