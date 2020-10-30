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
//        setContinueButton(enabled: false)
//        continueButton.setTitle("", for: .normal)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let userName = userNameTextField.text
        else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                print(error.localizedDescription)
                
//                self.setContinueButton(enabled: true)
//                self.continueButton.setTitle("Continue", for: .normal)
//                self.activityIndicator.stopAnimating()
                
                return
            }
            
            print("Successfully logged into Firebase with User Email")
            
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                    changeRequest.displayName = userName
                    changeRequest.commitChanges(completion: { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                            
    //                        self.setContinueButton(enabled: true)
    //                        self.continueButton.setTitle("Continue", for: .normal)
                            self.activityIndicator.stopAnimating()
                        }
                        
                        print("User display name changed!")
                        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    })
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    /*
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
