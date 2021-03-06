//
//  ReviewDatabaseService.swift
//  MovieBox
//
//  Created by Димас on 31.12.2020.
//

import Foundation
import FirebaseFirestore

class ReviewDatabaseService{
    
    static let shared = ReviewDatabaseService()
    let firestore = Firestore.firestore()
    
    private init(){
        
    }
    
    func saveReview(text: String, uid: String, date: String, movieId: String,
                   completion: @escaping (Result<String, Error>) -> Void) {
        let reviewId = UUID().uuidString
        firestore.collection("reviews").document(reviewId)
            .setData(["id" : reviewId,
                      "text" : text,
                      "uid" : uid,
                      "date" : date,
                      "movie_id" : movieId]) { (error) in
                if error != nil {
                    completion(.failure(ReviewDatabaseError.failedToSave))
                }
                completion(.success("Saving review is done!"))
            }
    }
    
    func getAllReviewsForCurrentMovie(forMovieId: String, completion: @escaping (Result<[Review], Error>) -> Void) {
        firestore.collection("reviews").whereField("movie_id", isEqualTo: forMovieId)
            .getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let reviews: [Review] = querySnapshot!.documents.compactMap { dictionary in
                    guard let id = dictionary["id"] as? String,
                          let movieId = dictionary["movie_id"] as? String,
                          let text = dictionary["text"] as? String,
                          let uid = dictionary["uid"] as? String,
                          let date = dictionary["date"] as? String else { return nil }
                    return Review(id: id, movieId: movieId, text: text, uid: uid, date: date)
                }
                
                completion(.success(reviews))
            }
        }
    }
    
    func deleteAllReviewsForCurrentMovie(forMovieId: String, completion: @escaping (Result<String, Error>) -> Void) {
        firestore.collection("reviews").whereField("movie_id", isEqualTo: forMovieId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    for document in querySnapshot!.documents {
                        self.firestore.collection("reviews").document(document.get("id") as! String).delete()
                    }
                    completion(.success("All reviews for movie with id: \(forMovieId) deleted."))
                }
        }
    }
    
    public func deleteReview(id: String, completion: @escaping (Result<String, Error>) -> Void) {
        firestore.collection("reviews").document(id).delete { error in
            if error != nil {
                completion(.failure(ReviewDatabaseError.failedToDelete))
            }
            completion(.success("Review is deleted."))
        }
    }
}

public enum ReviewDatabaseError: Error {
    case failedToSave
    case failedToDelete

    public var localizedDescription: String {
        switch self {
        case .failedToSave:
            return "Failed to save. Please try again later."
        case .failedToDelete:
            return "Failed to delete. Please try again later."
        }
    }
}
