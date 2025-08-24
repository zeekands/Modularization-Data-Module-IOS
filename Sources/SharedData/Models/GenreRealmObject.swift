//
//  GenreRealmObject.swift
//  SharedData
//
//  Created by zeekands on 07/07/25.
//


import Foundation
import RealmSwift

public class GenreRealmObject: Object, Identifiable {
    @Persisted(primaryKey: true) public var id: Int
    @Persisted public var name: String
    
    public convenience init(id: Int, name: String) {
        self.init()
        self.id = id
        self.name = name
    }
}
