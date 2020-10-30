//
//  SignInVCExtension.swift
//  MovieBox
//
//  Created by Димас on 30.10.2020.
//

import Foundation
import Firebase

extension SignInViewController {
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                print(error.localizedDescription)
                
//                self.setContinueButton(enabled: true)
//                self.continueButton.setTitle("Continue", for: .normal)
                self.activityIndicator.stopAnimating()
                
                return
            }
            
            print("Successfully logged in with Email")
            self.openMainVC()
        }
    }
}
