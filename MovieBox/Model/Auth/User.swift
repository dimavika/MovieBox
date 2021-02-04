//
//  User.swift
//  MovieBox
//
//  Created by Димас on 04.02.2021.
//

import Foundation

struct User {
    public var uid: String
    public var username: String
    public var email: String
    public var photoURL: String
    
    init(uid: String, username: String, email: String, photoURL: String) {
        self.uid = uid
        self.username = username
        self.email = email
        self.photoURL = photoURL
    }
}
