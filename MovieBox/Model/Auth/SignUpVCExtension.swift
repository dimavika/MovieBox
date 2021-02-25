//
//  SignUpVCExtension.swift
//  MovieBox
//
//  Created by Димас on 12.02.2021.
//

import Foundation
import Firebase

extension SignUpViewController {
    
    func createAccount(username: String, email: String, password: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                self.activityIndicator.stopAnimating()
                
                let alert = UIAlertController(title: "Failed to create account", message: "\(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)

                return
            }
            
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                    changeRequest.displayName = username
                    changeRequest.commitChanges(completion: { (error) in
                        if error != nil {
                            self.activityIndicator.stopAnimating()
                            self.openMainVC()
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
                    })
                }
        }
    }
    
    func openMainVC(){
        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
