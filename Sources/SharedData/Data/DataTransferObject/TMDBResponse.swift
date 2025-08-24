//
//  TMDBResponse.swift
//  SharedData
//
//  Created by zeekands on 05/07/25.
//


import Foundation

public struct TMDBResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let page: Int
    public let results: [T]
    public let totalPages: Int?
    public let totalResults: Int?
}
