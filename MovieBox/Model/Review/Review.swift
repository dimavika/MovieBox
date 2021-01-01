//
//  Review.swift
//  MovieBox
//
//  Created by Димас on 31.12.2020.
//

import Foundation

class Review{
    
    public var id: String
    public var movieId: String
    public var text: String
    public var username: String
    public var date: String

    init(id: String, movieId: String, text: String, username: String, date: String) {
        self.id = id
        self.movieId = movieId
        self.text = text
        self.username = username
        self.date = date
    }
}
