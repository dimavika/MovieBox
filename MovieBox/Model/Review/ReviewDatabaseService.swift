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
    
    func saveReview(text: String, username: String, date: String, movieId: String,
                   completion: @escaping (Result<String, Error>) -> Void) {
        let reviewId = "\(Int.random(in: 1...1000000))"
        firestore.collection("reviews").document(reviewId)
            .setData(["id" : reviewId,
                      "text" : text,
                      "username" : username,
                      "date" : date,
                      "movie_id" : movieId]) { (error) in
                if let error = error {
                    completion(.failure(error))
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
                          let username = dictionary["username"] as? String,
                          let date = dictionary["date"] as? String else { return nil }
                    return Review(id: id, movieId: movieId, text: text, username: username, date: date)
                }
                
                completion(.success(reviews))
            }
        }
    }
    
    // MARK: TODO
    func deleteAllReviewsForCurrentMovie(forMovieId: String) {
        firestore.collection("reviews").whereField("movie_id", isEqualTo: forMovieId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("gg")
                } else {
                    for document in querySnapshot!.documents {
                        self.firestore.collection("reviews").document(document.value(forKey: "id") as! String).delete()
                    }
                }
        }
    }
    
    public func deleteReview(id: String, completion: @escaping (Result<String, Error>) -> Void) {
        firestore.collection("reviews").document(id).delete { error in
            if let error = error {
                print("Couldn't delete document from firestore cause: \(error)")
                completion(.failure(error))
            }
            completion(.success("Review is deleted."))
        }
    }
}
