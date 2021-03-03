//
//  MovieDatabaseService.swift
//  MovieBox
//
//  Created by Димас on 06.12.2020.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

class MovieDatabaseService {
    
    static let shared = MovieDatabaseService()
    let storageRef = Storage.storage().reference()
    let firestore = Firestore.firestore()
    
    private init() {

    }
    
    func saveMovie(title: String, genre: String, year: String, country: String, slogan: String, description: String, image: UIImage, videoURL: URL,
                   completion: @escaping (Result<String, Error>) -> Void) {
        let movieId = UUID().uuidString
        let date = Date()
        let timestamp = Timestamp(date: date)
        
        uploadImage(imageId: movieId, image: image) { (myresult) in
            switch myresult {
            case .success(let url):
                self.uploadVideo(videoId: movieId, videoURL: videoURL) { result in
                    switch result {
                    case .success(let videoURLL):
                        let videoDownloadURL = videoURLL.absoluteString
                        let imageUrl = url.absoluteString
                        self.firestore.collection("movies").document(movieId)
                            .setData(["id" : movieId,
                                      "title" : title,
                                      "genre" : genre,
                                      "year" : year,
                                      "country" : country,
                                      "slogan" : slogan,
                                      "description" : description,
                                      "image_url" : imageUrl,
                                      "video_url" : videoDownloadURL,
                                      "date" : timestamp]) { (error) in
                                if error != nil {
                                    completion(.failure(MovieDatabaseError.failedToSave))
                                }
                                completion(.success("Saving movie is done!"))
                            }
                    case .failure(_):
                        completion(.failure(MovieDatabaseError.failedToSave))
                    }
                }
                
            case .failure(_):
                completion(.failure(MovieDatabaseError.failedToSave))
            }
        }
    }
    
    func uploadImage(imageId: String, image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = storageRef.child("movie_image").child(imageId)
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        ref.putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            ref.downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
            }
        }
    }
    
    func uploadVideo(videoId: String, videoURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = storageRef.child("movie_trailer").child(videoId)
        guard let videoData = NSData(contentsOf: videoURL) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        
        ref.putData(videoData as Data, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            ref.downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
            }
        }
    }
    
    func downloadImage(forURL url: String,
                       completion: @escaping (Result<UIImage, Error>) -> Void) {

        let ref = Storage.storage().reference(forURL: url)
        let megabyte = Int64(1*1024*1024)
        ref.getData(maxSize: megabyte) { (data, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let image = UIImage(data: data!)
                completion(.success(image!))
            }
        }
    }
    
    func getAllMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        firestore.collection("movies").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let movies: [Movie] = querySnapshot!.documents.compactMap { dictionary in
                    guard let id = dictionary["id"] as? String,
                          let title = dictionary["title"] as? String,
                          let genre = dictionary["genre"] as? String,
                          let year = dictionary["year"] as? String,
                          let country = dictionary["country"] as? String,
                          let slogan = dictionary["slogan"] as? String,
                          let description = dictionary["description"] as? String,
                          let imageUrl = dictionary["image_url"] as? String,
                          let videoUrl = dictionary["video_url"] as? String,
                          let date = dictionary["date"] as? Timestamp else { return nil }
                    return Movie(id: id, title: title, genre: genre, year: year, country: country, slogan: slogan, description: description, imageUrl: imageUrl,
                                 videoUrl: videoUrl, date: date)
                }
                
                completion(.success(movies))
            }
        }
    }
    
    func getMovieById(movieId: String, completion: @escaping (Result<Movie, Error>) -> Void) {
        firestore.collection("movies").document(movieId).getDocument { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            }
            let movie = snapshot!.data().map { (dictionary) -> Movie? in
                guard let id = dictionary["id"] as? String,
                      let title = dictionary["title"] as? String,
                      let genre = dictionary["genre"] as? String,
                      let year = dictionary["year"] as? String,
                      let country = dictionary["country"] as? String,
                      let slogan = dictionary["slogan"] as? String,
                      let description = dictionary["description"] as? String,
                      let imageUrl = dictionary["image_url"] as? String,
                      let videoUrl = dictionary["video_url"] as? String,
                      let date = dictionary["date"] as? Timestamp else { return nil }
                return Movie(id: id, title: title, genre: genre, year: year, country: country, slogan: slogan, description: description, imageUrl: imageUrl,
                             videoUrl: videoUrl, date: date)
            }
            completion(.success(movie!!))
        }
    }
    
    public func deleteMovie(id: String, completion: @escaping (Result<String, Error>) -> Void) {
        firestore.collection("movies").document(id).delete { error in
            if error != nil {
                completion(.failure(MovieDatabaseError.failedToDelete))
            }
        }
        storageRef.child("movie_image").child(id).delete()
        storageRef.child("movie_trailer").child(id).delete()
        completion(.success("Movie is deleted."))
    }
    
    public enum MovieDatabaseError: Error {
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
}
