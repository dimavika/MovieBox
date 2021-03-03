//
//  UserProfileDatabaseService.swift
//  MovieBox
//
//  Created by Димас on 04.02.2021.
//

import Foundation
import Firebase
import FirebaseStorage

class UserProfileDatabaseService {
    
    static let shared = UserProfileDatabaseService()
    let storageRef = Storage.storage().reference()
    let firestore = Firestore.firestore()
    
    private init() {

    }
    
    func saveUser(uid: String, username: String, email: String, photoURL: String, completion: @escaping (Result<String, Error>) -> Void) {
        firestore.collection("users").document(uid)
            .setData(["uid" : uid,
                      "username" : username,
                      "email" : email,
                      "photo_url" : photoURL]) { (error) in
                if let error = error {
                    completion(.failure(error))
                }
                completion(.success("Saving user is done!"))
            }
    }
    
    func getUserByUid(uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        firestore.collection("users").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            }
            let user = snapshot!.data().map { (dictionary) -> User? in
                guard let uid = dictionary["uid"] as? String,
                      let username = dictionary["username"] as? String,
                      let email = dictionary["email"] as? String,
                      let photoURL = dictionary["photo_url"] as? String else { return nil }
                return User(uid: uid, username: username, email: email, photoURL: photoURL)
            }
            completion(.success(user!!))
        }
    }
    
    func uploadUserProfilePhoto(imageId: String, image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = storageRef.child("user_image").child(imageId)
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
    
    func updateUsername(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        let user = Auth.auth().currentUser!
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = username
        changeRequest.commitChanges { (error) in
            if error != nil {
                completion(.failure(UserDatabaseError.failedToUpdateUsername))
            } else {
                self.saveUser(uid: user.uid, username: username, email: user.email!, photoURL: user.photoURL!.absoluteString) { (result) in
                    switch result {
                    case .failure(_):
                        completion(.failure(UserDatabaseError.failedToUpdateUsername))
                    case .success(_):
                        completion(.success(username))
                    }
                }
            }
        }
    }
}

public enum UserDatabaseError: Error {
    case failedToUpdateUsername
    
    public var localizedDescription: String {
        switch self {
        case .failedToUpdateUsername:
            return "Failed to update username. Please try again later."
        }
    }
}
