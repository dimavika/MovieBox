//
//  LoginViewController.swift
//  MovieBox
//
//  Created by Димас on 16.10.2020.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let borderColor: UIColor = UIColor(red: 220.0/255.0, green: 221.0/255.0, blue: 229.0/255.0, alpha: 1.0)
    private let tintColor = UIColor(red: 237.0/255.0, green: 101.0/255.0, blue: 106.0/255.0, alpha: 1.0)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.configure(color: UIColor(.white),
                               font: UIFont.boldSystemFont(ofSize: 20),
                               cornerRadius: 55/2,
                               borderColor: tintColor,
                               backgroundColor: tintColor,
                               borderWidth: 1.0)
        
        signUpButton.configure(color: UIColor(.black),
                               font: UIFont.boldSystemFont(ofSize: 20),
                               cornerRadius: 55/2,
                               borderColor: borderColor,
                               backgroundColor: UIColor(.white),
                               borderWidth: 1.0)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.textColor = tintColor
        
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
