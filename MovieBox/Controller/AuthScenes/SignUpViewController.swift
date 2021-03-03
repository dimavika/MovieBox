//
//  SignUpViewController.swift
//  MovieBox
//
//  Created by Димас on 08.10.2020.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    private let borderColor: UIColor = UIColor(red: 220.0/255.0, green: 221.0/255.0, blue: 229.0/255.0, alpha: 1.0)
    private let tintColor = UIColor(red: 237.0/255.0, green: 101.0/255.0, blue: 106.0/255.0, alpha: 1.0)
    private let signUpButtonColor = UIColor(red: 57.0/255.0, green: 77.0/255.0, blue: 141.0/255.0, alpha: 1.0)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameTextField: TextField!
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var confirmPasswordTextField: TextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.tintColor = tintColor
        
        titleLabel.textColor = tintColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        usernameTextField.configure(color: UIColor(.black),
                                 font: UIFont.systemFont(ofSize: 16),
                                 cornerRadius: 55/2,
                                 borderColor: borderColor,
                                 backgroundColor: UIColor(.white),
                                 borderWidth: 1.0)
        usernameTextField.clipsToBounds = true
        emailTextField.configure(color: UIColor(.black),
                                 font: UIFont.systemFont(ofSize: 16),
                                 cornerRadius: 55/2,
                                 borderColor: borderColor,
                                 backgroundColor: UIColor(.white),
                                 borderWidth: 1.0)
        emailTextField.clipsToBounds = true
        passwordTextField.configure(color: UIColor(.black),
                                 font: UIFont.systemFont(ofSize: 16),
                                 cornerRadius: 55/2,
                                 borderColor: borderColor,
                                 backgroundColor: UIColor(.white),
                                 borderWidth: 1.0)
        passwordTextField.clearsOnBeginEditing = false
        passwordTextField.clipsToBounds = true
        confirmPasswordTextField.configure(color: UIColor(.black),
                                 font: UIFont.systemFont(ofSize: 16),
                                 cornerRadius: 55/2,
                                 borderColor: borderColor,
                                 backgroundColor: UIColor(.white),
                                 borderWidth: 1.0)
        confirmPasswordTextField.clearsOnBeginEditing = false
        confirmPasswordTextField.clipsToBounds = true
        
        signUpButton.configure(color: UIColor(.white),
                               font: UIFont.boldSystemFont(ofSize: 20),
                               cornerRadius: 55/2,
                               borderColor: borderColor,
                               backgroundColor: signUpButtonColor,
                               borderWidth: 1.0)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        activityIndicator.startAnimating()
        
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let username = usernameTextField.text,
            let confirmedPassword = confirmPasswordTextField.text,
            email != "",
            password != "",
            username != "",
            confirmedPassword != "",
            password == confirmedPassword
        else {
            activityIndicator.stopAnimating()
            AlertPresenter.presentAlertController(self, title: "Incorrect account data", message: "Check if you entered all the account data or the email and password confirmation are entered correctly.")
            return
        }
        
        createAccount(username: username, email: email, password: password)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
}
