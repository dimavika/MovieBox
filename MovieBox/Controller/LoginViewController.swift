//
//  LoginViewController.swift
//  MovieBox
//
//  Created by Димас on 16.10.2020.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }

    //MARK: Auth
    
    @IBAction func googleSignInButtonPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func emailSignInButtonPressed(_ sender: UIButton) {
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }
    
    func openMainViewController() {
        dismiss(animated: true)
    }

}
