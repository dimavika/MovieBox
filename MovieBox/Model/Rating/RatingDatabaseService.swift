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
        let ratingId = "\(Int.random(in: 1...1000000))"
        firestore.collection("ratings").document(ratingId)
            .setData(["id" : ratingId,
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
                completion(.success(ratings))
            }
        }
    }
    
    func getAverageRatingForMovie(movieId: String, completion: @escaping (Result<Double, Error>) -> Void) {
        firestore.collection("ratings").whereField("movie_id", isEqualTo: movieId).getDocuments { (querySnapshot, error) in
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
                
                var sumOfRatings = 0.0
                if ratings.isEmpty {
                    completion(.success(sumOfRatings))
                } else {
                    for rating in ratings {
                        sumOfRatings += Double(rating.value)
                    }
                    completion(.success(sumOfRatings / Double(ratings.count)))
                }
            }
        }
    }
    
    func deleteAllRatingsForCurrentMovie(forMovieId: String) {
        firestore.collection("ratings").whereField("movie_id", isEqualTo: forMovieId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Cannot get ratings for movie with id: \(forMovieId), cause: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        self.firestore.collection("ratings").document(document.get("id") as! String).delete()
                    }
                }
        }
    }
}
