//
//  GenresResponse.swift
//  SharedData
//
//  Created by zeekands on 05/07/25.
//


import Foundation

public struct GenresResponse: Decodable, Sendable {
    public let genres: [GenreDTO]
}