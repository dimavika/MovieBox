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
    public var imageUrl: String
    public var videoUrl : String
    
    
    init(id: String, title: String, genre: String, imageUrl: String, videoUrl: String) {
        self.id = id
        self.title = title
        self.genre = genre
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
    }
}
