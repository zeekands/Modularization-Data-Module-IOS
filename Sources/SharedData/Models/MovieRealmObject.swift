//
//  MovieRealmObject.swift
//  SharedData
//
//  Created by zeekands on 07/07/25.
//


import Foundation
import RealmSwift 

public class MovieRealmObject: Object, Identifiable { // <-- Mewarisi Object
    @Persisted(primaryKey: true) public var id: Int // Primary Key
    @Persisted public var title: String
    @Persisted public var overview: String?
    @Persisted public var posterPath: String?
    @Persisted public var backdropPath: String?
    @Persisted public var releaseDate: Date?
    @Persisted public var voteAverage: Double?
    @Persisted public var isFavorite: Bool // Fitur Favorite

    // Relasi ke GenreRealmObject (Many-to-Many)
    // List<T> digunakan untuk relasi many-to-many atau many-to-one
    @Persisted public var genres = RealmSwift.List<GenreRealmObject>() 

    public convenience init(
        id: Int,
        title: String,
        overview: String? = nil,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        releaseDate: Date? = nil,
        voteAverage: Double? = nil,
        isFavorite: Bool = false
    ) {
        self.init()
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.isFavorite = isFavorite
    }
}
