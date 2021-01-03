//
//  Rating.swift
//  MovieBox
//
//  Created by Димас on 03.01.2021.
//

import Foundation

class Rating {
    public var id: String
    public var movieId: String
    public var value: Int
    public var username: String
    
    public init(id: String, movieId: String, value: Int, username: String) {
        self.id = id
        self.movieId = movieId
        self.value = value
        self.username = username
    }
}
