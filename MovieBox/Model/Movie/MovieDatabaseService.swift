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
    
    func saveMovie(title: String, genre: String, image: UIImage, videoURL: URL,
                   completion: @escaping (Result<String, Error>) -> Void) {
        let movieId = "\(Int.random(in: 1...1000000))"
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
                                      "image_url" : imageUrl,
                                      "video_url" : videoDownloadURL]) { (error) in
                                if let error = error {
                                    completion(.failure(error))
                                }
                                completion(.success("Saving movie is done!"))
                            }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
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
                          let imageUrl = dictionary["image_url"] as? String,
                          let videoUrl = dictionary["video_url"] as? String else { return nil }
                    return Movie(id: id, title: title, genre: genre, imageUrl: imageUrl,
                                 videoUrl: videoUrl)
                }
                
                completion(.success(movies))
            }
        }
    }
    
    public func deleteMovie(id: String, completion: @escaping (Result<String, Error>) -> Void) {
        firestore.collection("movies").document(id).delete { error in
            if let error = error {
                print("Couldn't delete document from firestore cause: \(error)")
                completion(.failure(error))
            }
        }
        storageRef.child("movie_image").child(id).delete { error in
            if let error = error {
                print("Couldn't delete image from storage cause: \(error)")
            }
        }
        storageRef.child("movie_trailer").child(id).delete { error in
            if let error = error {
                print("Couldn't delete video trailer from storage cause: \(error)")
            }
        }
        completion(.success("Movie is deleted."))
    }
    
    public enum DatabaseError: Error {
        case failedToFetch

        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "This means blah failed"
            }
        }
    }
}
