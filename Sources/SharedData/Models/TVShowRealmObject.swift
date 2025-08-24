//
//  TVShowRealmObject.swift
//  SharedData
//
//  Created by zeekands on 07/07/25.
//


import Foundation
import RealmSwift

public class TVShowRealmObject: Object, Identifiable {
    @Persisted(primaryKey: true) public var id: Int
    @Persisted public var name: String
    @Persisted public var overview: String?
    @Persisted public var posterPath: String?
    @Persisted public var backdropPath: String?
    @Persisted public var firstAirDate: Date?
    @Persisted public var voteAverage: Double?
    @Persisted public var isFavorite: Bool

    @Persisted public var genres = RealmSwift.List<GenreRealmObject>() 

    public convenience init(
        id: Int,
        name: String,
        overview: String? = nil,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        firstAirDate: Date? = nil,
        voteAverage: Double? = nil,
        isFavorite: Bool = false
    ) {
        self.init()
        self.id = id
        self.name = name
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.firstAirDate = firstAirDate
        self.voteAverage = voteAverage
        self.isFavorite = isFavorite
    }
}
