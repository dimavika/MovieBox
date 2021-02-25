//
//  SignInViewController.swift
//  MovieBox
//
//  Created by Димас on 08.10.2020.
//

import UIKit
import Firebase
import GoogleSignIn

class SignInViewController: UIViewController {
    
    private let borderColor: UIColor = UIColor(red: 220.0/255.0, green: 221.0/255.0, blue: 229.0/255.0, alpha: 1.0)
    private let tintColor = UIColor(red: 237.0/255.0, green: 101.0/255.0, blue: 106.0/255.0, alpha: 1.0)
    private let googleButtonColor = UIColor(red: 57.0/255.0, green: 77.0/255.0, blue: 141.0/255.0, alpha: 1.0)
    private let backButtonColor = UIColor(red: 40.0/255.0, green: 46.0/255.0, blue: 79.0/255.0, alpha: 1.0)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorLabel: UILabel!
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.tintColor = tintColor
        
        titleLabel.textColor = tintColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
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
        
        separatorLabel.font = UIFont.boldSystemFont(ofSize: 14)
        separatorLabel.textColor = .black
        
        signInButton.configure(color: UIColor(.white),
                               font: UIFont.boldSystemFont(ofSize: 20),
                               cornerRadius: 55/2,
                               borderColor: tintColor,
                               backgroundColor: tintColor,
                               borderWidth: 1.0)
        googleButton.configure(color: UIColor(.white),
                               font: UIFont.boldSystemFont(ofSize: 20),
                               cornerRadius: 55/2,
                               borderColor: googleButtonColor,
                               backgroundColor: googleButtonColor,
                               borderWidth: 1.0)
        
        self.hideKeyboardWhenTappedAround()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    

    @IBAction func signInButtonPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            email != "",
            password != ""
        else {  activityIndicator.stopAnimating()
                let alert = UIAlertController(title: "Account data",
                                              message: "Please enter your email and password.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
        }
        
        signIn(email: email, password: password)
    }
    
    @IBAction func googleButtonPressed(_ sender: UIButton) {
        activityIndicator.startAnimating()
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
}
