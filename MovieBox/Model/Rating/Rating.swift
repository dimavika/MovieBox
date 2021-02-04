//
//  Rating.swift
//  MovieBox
//
//  Created by Димас on 03.01.2021.
//

import Foundation
import FirebaseFirestore

struct Rating {
    public var id: String
    public var movieId: String
    public var value: Int
    public var uid: String
    public var date: Timestamp
    
    public init(id: String, movieId: String, value: Int, uid: String, date: Timestamp) {
        self.id = id
        self.movieId = movieId
        self.value = value
        self.uid = uid
        self.date = date
    }
}
