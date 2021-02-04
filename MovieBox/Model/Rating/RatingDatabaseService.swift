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
    
    private init(){
        
    }
    
    //MARK: TODO: INSTEAD USERNAME - UID EVERYWHERE
    func saveRating(movieId: String, value: Int, uid: String,
                   completion: @escaping (Result<String, Error>) -> Void) {
        firestore.collection("ratings").whereField("movie_id", isEqualTo: movieId).whereField("uid", isEqualTo: uid)
            .getDocuments { (querySnapshot, _) in
                let ratings: [Rating] = querySnapshot!.documents.compactMap { dictionary in
                    guard let id = dictionary["id"] as? String,
                          let movieId = dictionary["movie_id"] as? String,
                          let value = dictionary["value"] as? Int,
                          let date = dictionary["date"] as? Timestamp,
                          let uid = dictionary["uid"] as? String else { return nil }
                    return Rating(id: id, movieId: movieId, value: value, uid: uid, date: date)
                }
                
                let date = Date()
                let timestamp = Timestamp(date: date)
                
                //Checking if user rating is already exist
                if ratings.isEmpty {
                    let ratingId = "\(Int.random(in: 1...1000000))"
                    self.firestore.collection("ratings").document(ratingId)
                        .setData(["id" : ratingId,
                                  "movie_id" : movieId,
                                  "value" : value,
                                  "uid" : uid,
                                  "date" : timestamp]) { (error) in
                            if let error = error {
                                completion(.failure(error))
                            }
                            completion(.success("Saving rating is done!"))
                        }
                } else {
                    self.firestore.collection("ratings").document(ratings[0].id)
                        .setData(["id" : ratings[0].id,
                                  "movie_id" : movieId,
                                  "value" : value,
                                  "uid" : uid,
                                  "date" : timestamp]) { (error) in
                            if let error = error {
                                completion(.failure(error))
                            }
                            completion(.success("Saving rating is done!"))
                        }
                }
        }
    }
    
    func getUserRatingForCurrentMovie(movieId: String, uid: String,
                                      completion: @escaping (Result<[Rating], Error>) -> Void) {
        firestore.collection("ratings").whereField("movie_id", isEqualTo: movieId).whereField("uid", isEqualTo: uid)
            .getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let ratings: [Rating] = querySnapshot!.documents.compactMap { dictionary in
                    guard let id = dictionary["id"] as? String,
                          let movieId = dictionary["movie_id"] as? String,
                          let value = dictionary["value"] as? Int,
                          let uid = dictionary["uid"] as? String,
                          let date = dictionary["date"] as? Timestamp else { return nil }
                    return Rating(id: id, movieId: movieId, value: value, uid: uid, date: date)
                }
                completion(.success(ratings))
            }
        }
    }
    
    func getAverageRatingForMovie(movieId: String, completion: @escaping (Result<(rating: Double, count: Int), Error>) -> Void) {
        firestore.collection("ratings").whereField("movie_id", isEqualTo: movieId).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let ratings: [Rating] = querySnapshot!.documents.compactMap { dictionary in
                    guard let id = dictionary["id"] as? String,
                          let movieId = dictionary["movie_id"] as? String,
                          let value = dictionary["value"] as? Int,
                          let uid = dictionary["uid"] as? String,
                          let date = dictionary["date"] as? Timestamp else { return nil }
                    return Rating(id: id, movieId: movieId, value: value, uid: uid, date: date)
                }
                
                var sumOfRatings = 0.0
                if ratings.isEmpty {
                    completion(.success((sumOfRatings, ratings.count)))
                } else {
                    for rating in ratings {
                        sumOfRatings += Double(rating.value)
                    }
                    completion(.success((sumOfRatings / Double(ratings.count), ratings.count)))
                }
            }
        }
    }
    
    func getUserRatings(uid: String, completion: @escaping (Result<[Rating], Error>) -> Void) {
        firestore.collection("ratings").whereField("uid", isEqualTo: uid)
            .getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let ratings: [Rating] = querySnapshot!.documents.compactMap { dictionary in
                    guard let id = dictionary["id"] as? String,
                          let movieId = dictionary["movie_id"] as? String,
                          let value = dictionary["value"] as? Int,
                          let uid = dictionary["uid"] as? String,
                          let date = dictionary["date"] as? Timestamp else { return nil }
                    return Rating(id: id, movieId: movieId, value: value, uid: uid, date: date)
                }
                completion(.success(ratings))
            }
        }
    }
    
    func deleteAllRatingsForCurrentMovie(forMovieId: String, completion: @escaping (Result<String, Error>) -> Void) {
        firestore.collection("ratings").whereField("movie_id", isEqualTo: forMovieId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    for document in querySnapshot!.documents {
                        self.firestore.collection("ratings").document(document.get("id") as! String).delete()
                    }
                    completion(.success("All ratings for movie with id: \(forMovieId) deleted"))
                }
        }
    }
}
