//
//  LoginViewController.swift
//  MovieBox
//
//  Created by Димас on 16.10.2020.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.configure(color: UIColor(.white),
                               font: UIFont.boldSystemFont(ofSize: 20),
                               cornerRadius: 55/2,
                               borderColor: Constants.tintColor,
                               backgroundColor: Constants.tintColor,
                               borderWidth: 1.0)
        
        signUpButton.configure(color: UIColor(.black),
                               font: UIFont.boldSystemFont(ofSize: 20),
                               cornerRadius: 55/2,
                               borderColor: Constants.borderColor,
                               backgroundColor: UIColor(.white),
                               borderWidth: 1.0)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.textColor = Constants.tintColor
        
        subtitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        subtitleLabel.textColor = .black
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let signInVC = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        signInVC.modalPresentationStyle = .fullScreen
        self.present(signInVC, animated: true)
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let signUpVC = storyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        signUpVC.modalPresentationStyle = .fullScreen
        self.present(signUpVC, animated: true)
    }

}
