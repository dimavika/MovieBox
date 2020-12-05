//
//  DatabaseService.swift
//  MovieBox
//
//  Created by Димас on 06.12.2020.
//

import Foundation
import FirebaseDatabase

class DatabaseService {
    
    static let shared = DatabaseService()
    var ref = Database.database().reference()
    
    private init(){}
    
    func saveMovie(title: String, genre: String) {
        ref.child("movie").child("\(Int.random(in: 1...1000000))")
            .setValue(["title" : title,
                       "genre" : genre])
    }
}
