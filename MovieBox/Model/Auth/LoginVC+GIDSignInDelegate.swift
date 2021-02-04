//
//  LoginVC+GIDSignInDelegate.swift
//  MovieBox
//
//  Created by Димас on 30.10.2020.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

extension LoginViewController: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Failed to log into Google with error: ", error.localizedDescription)
            return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)

        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Failed to retrieve user data from Google with error: ", error.localizedDescription)
                return
            }
            
            let user = Auth.auth().currentUser!
            let userProfileDatabaseService = UserProfileDatabaseService.shared
            
            userProfileDatabaseService.saveUser(uid: user.uid, username: user.displayName!, email: user.email!, photoURL: user.photoURL?.absoluteString ?? "No photo") { (result) in
                switch result {
                case .failure(let error):
                    print("\(error)")
                case .success(let successMessage):
                    print(successMessage)
                }
            }
            print("Successfully logged in Firebase with Google")
            self.openMainViewController()
        }
    }
}
