//
//  TVShowDTO.swift
//  SharedData
//
//  Created by zeekands on 05/07/25.
//


import Foundation
import SharedDomain // Untuk TVShowEntity jika ada referensi silang

public struct TVShowDTO: Decodable, Sendable {
  public let id: Int
  public let name: String
  public let overview: String?
  public let posterPath: String?
  public let backdropPath: String?
  public let firstAirDate: String?
  public let voteAverage: Double?
  public let genreIds: [Int]?
}
