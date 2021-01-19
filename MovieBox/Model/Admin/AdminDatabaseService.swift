//
//  AdminDatabaseService.swift
//  MovieBox
//
//  Created by Димас on 16.01.2021.
//

import Foundation
import FirebaseFirestore

class AdminDatabaseService {
    
    static let shared = AdminDatabaseService()
    let firestore = Firestore.firestore()
    
    private init() {
        
    }
    
    func checkUserIsAdmin(uid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        firestore.collection("admins").whereField("uid", isEqualTo: uid)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    if querySnapshot!.documents.isEmpty {
                        completion(.success(false))
                    } else {
                        completion(.success(true))
                    }
                }
            }
    }
}
