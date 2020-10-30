//
//  SignInViewController.swift
//  MovieBox
//
//  Created by Димас on 08.10.2020.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func signInButtonPressed(_ sender: Any) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text
        else { return }
        
        signIn(email: email, password: password)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func openMainVC() {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
}
