//
//  RatingDatabaseService.swift
//  MovieBox
//
//  Created by Димас on 03.01.2021.
//

import Foundation
import FirebaseFirestore

class RatingDatabaseService {
    
    static let shared = RatingDatabaseService()
    let firestore = Firestore.firestore()
    var allRatings: [Rating] = []
    
    private init(){
        
    }
    
    func saveRating(movieId: String, value: Int, username: String,
                   completion: @escaping (Result<String, Error>) -> Void) {
        firestore.collection("ratings").document(movieId)
            .setData(["id" : movieId,
                      "movie_id" : movieId,
                      "value" : value,
                      "username" : username]) { (error) in
                if let error = error {
                    completion(.failure(error))
                }
                completion(.success("Saving rating is done!"))
            }
    }
    
    func getUserRatingForCurrentMovie(movieId: String, username: String,
                                      completion: @escaping (Result<[Rating], Error>) -> Void) {
        firestore.collection("ratings").whereField("movie_id", isEqualTo: movieId).whereField("username", isEqualTo: username)
            .getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let ratings: [Rating] = querySnapshot!.documents.compactMap { dictionary in
                    guard let id = dictionary["id"] as? String,
                          let movieId = dictionary["movie_id"] as? String,
                          let value = dictionary["value"] as? Int,
                          let username = dictionary["username"] as? String else { return nil }
                    return Rating(id: id, movieId: movieId, value: value, username: username)
                }
                print("Rating count:\(ratings.count)")
                completion(.success(ratings))
            }
        }
    }
}
