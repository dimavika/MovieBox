//
//  SignUpViewController.swift
//  MovieBox
//
//  Created by Димас on 08.10.2020.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {

        activityIndicator.startAnimating()
        
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let userName = userNameTextField.text
        else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                self.activityIndicator.stopAnimating()
                print(error.localizedDescription)
                return
            }
            
            print("Successfully logged into Firebase with User Email")
            
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                    changeRequest.displayName = userName
                    changeRequest.commitChanges(completion: { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                            self.activityIndicator.stopAnimating()
                        }
                        let user = Auth.auth().currentUser!
                        let userProfileDatabaseService = UserProfileDatabaseService.shared
                        
                        userProfileDatabaseService.saveUser(uid: user.uid, username: user.displayName!, email: user.email!, photoURL: user.photoURL?.absoluteString ?? "No photo") { (result) in
                            switch result {
                            case .failure(let error):
                                self.activityIndicator.stopAnimating()
                                print("\(error)")
                            case .success(let successMessage):
                                self.activityIndicator.stopAnimating()
                                self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                                print(successMessage)
                            }
                        }
                    })
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
