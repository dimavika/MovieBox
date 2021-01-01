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
    var allReviews: [Review] = []
    
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
    
    func getAllReviews(forMovieId: String, completion: @escaping (Result<[Review], Error>) -> Void) {
        firestore.collection("reviews").whereField("movie_id", isEqualTo: forMovieId).getDocuments { (querySnapshot, error) in
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
    
    public func updateAllReviews(movieId: String) {
        print("Movie_id: \(movieId)")
        getAllReviews(forMovieId: movieId) { result in
            switch result {
            case .success(let reviews):
                print("success")
                print(reviews.count)
                self.allReviews = reviews
            case .failure(let error):
                print("Something went wrong cause: \(error)")
            }
        }
    }
}
