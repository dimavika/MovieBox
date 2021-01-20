//
//  Movie.swift
//  MovieBox
//
//  Created by Димас on 18.12.2020.
//

import Foundation

class Movie {
    
    public var id: String
    public var title: String
    public var genre: String
    public var year: String
    public var country: String
    public var slogan: String
    public var imageUrl: String
    public var videoUrl : String
    
    
    init(id: String, title: String, genre: String, year: String, country: String, slogan: String, imageUrl: String, videoUrl: String) {
        self.id = id
        self.title = title
        self.genre = genre
        self.year = year
        self.country = country
        self.slogan = slogan
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
    }
}
