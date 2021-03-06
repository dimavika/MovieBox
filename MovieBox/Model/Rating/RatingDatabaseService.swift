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
                    let ratingId = UUID().uuidString
                    self.firestore.collection("ratings").document(ratingId)
                        .setData(["id" : ratingId,
                                  "movie_id" : movieId,
                                  "value" : value,
                                  "uid" : uid,
                                  "date" : timestamp]) { (error) in
                            if error != nil {
                                completion(.failure(RatingDatabaseError.failedToSave))
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
                            if error != nil {
                                completion(.failure(RatingDatabaseError.failedToSave))
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
    
    func getAllRatingsByLastMonth(completion: @escaping (Result<[Rating], Error>) -> Void) {
        let currentDate = Date()
        let dateOneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
        let timestamp = Timestamp(date: dateOneMonthAgo)
        firestore.collection("ratings").whereField("date", isGreaterThan: timestamp).getDocuments { (querySnapshot, error) in
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
}

public enum RatingDatabaseError: Error {
    case failedToSave

    public var localizedDescription: String {
        switch self {
        case .failedToSave:
            return "Failed to save. Please try again later."
        }
    }
}
