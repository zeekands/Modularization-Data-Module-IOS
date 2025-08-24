//
//  GenreDTO.swift
//  SharedData
//
//  Created by zeekands on 05/07/25.
//


import Foundation
import SharedDomain // Untuk GenreEntity jika ada referensi silang

public struct GenreDTO: Decodable, Sendable {
    public let id: Int
    public let name: String
}