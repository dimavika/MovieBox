//
//  SignInVCExtension.swift
//  MovieBox
//
//  Created by Димас on 30.10.2020.
//

import Foundation
import Firebase
import GoogleSignIn

extension SignInViewController {
    
    func signIn(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                self.activityIndicator.stopAnimating()
                self.presentAlertController(title: "Incorrect account data", message: error.localizedDescription)
                return
            }
            
            self.activityIndicator.stopAnimating()
            self.openMainVC()
        }
    }
    
    func presentAlertController(title: String, message: String) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openMainVC() {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
}

extension SignInViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            self.activityIndicator.stopAnimating()
            presentAlertController(title: "Failed to sign in with Google", message: error.localizedDescription)
            return
        }

        guard let authentication = user.authentication else {
            self.activityIndicator.stopAnimating()
            presentAlertController(title: "Failed to sign in with Google", message: "There is not your fault. Probably something went wrong with Google authentication provider. Please try again later.")
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)

        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                self.activityIndicator.stopAnimating()
                self.presentAlertController(title: "Failed to retrieve user data from Google", message: error.localizedDescription)
                return
            }
            
            let user = Auth.auth().currentUser!
            let userProfileDatabaseService = UserProfileDatabaseService.shared
            
            userProfileDatabaseService.saveUser(uid: user.uid, username: user.displayName!, email: user.email!, photoURL: user.photoURL?.absoluteString ?? "No photo") { (result) in
                switch result {
                case .failure(_):
                    self.activityIndicator.stopAnimating()
                    self.openMainVC()
                case .success(_):
                    self.activityIndicator.stopAnimating()
                    self.openMainVC()
                }
            }
        }
    }
    
}
