//
//  UserProfileViewController.swift
//  MovieBox
//
//  Created by Димас on 21.10.2020.
//

import UIKit
import FirebaseAuth
import Kingfisher

class UserProfileViewController: UIViewController {
    
    private let borderColor: UIColor = UIColor(red: 220.0/255.0, green: 221.0/255.0, blue: 229.0/255.0, alpha: 1.0)
    private let tintColor = UIColor(red: 237.0/255.0, green: 101.0/255.0, blue: 106.0/255.0, alpha: 1.0)
    private let photoButtonColor = UIColor(red: 57.0/255.0, green: 77.0/255.0, blue: 141.0/255.0, alpha: 1.0)
    
    let userProfileDatabaseService = UserProfileDatabaseService.shared
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var editUsernameButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameTextField: TextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: tintColor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25)]
        self.tabBarController?.tabBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.backgroundImage = UIImage()
        self.tabBarController?.tabBar.clipsToBounds = true
        
        photoButton.configure(color: UIColor(.white),
                                         font: UIFont.boldSystemFont(ofSize: 15),
                                         cornerRadius: photoButton.bounds.height / 2,
                                         borderColor: photoButtonColor,
                                         backgroundColor: photoButtonColor,
                                         borderWidth: 1.0)
        editUsernameButton.configure(color: UIColor(.white),
                                         font: UIFont.boldSystemFont(ofSize: 15),
                                         cornerRadius: editUsernameButton.bounds.height / 2,
                                         borderColor: photoButtonColor,
                                         backgroundColor: photoButtonColor,
                                         borderWidth: 1.0)
        submitButton.configure(color: UIColor(.white),
                                         font: UIFont.boldSystemFont(ofSize: 15),
                                         cornerRadius: submitButton.bounds.height / 2,
                                         borderColor: photoButtonColor,
                                         backgroundColor: photoButtonColor,
                                         borderWidth: 1.0)
        changePasswordButton.configure(color: UIColor(.white),
                                         font: UIFont.boldSystemFont(ofSize: 15),
                                         cornerRadius: changePasswordButton.bounds.height / 2,
                                         borderColor: tintColor,
                                         backgroundColor: tintColor,
                                         borderWidth: 1.0)
        deleteAccountButton.configure(color: UIColor(.white),
                                         font: UIFont.boldSystemFont(ofSize: 15),
                                         cornerRadius: deleteAccountButton.bounds.height / 2,
                                         borderColor: tintColor,
                                         backgroundColor: tintColor,
                                         borderWidth: 1.0)
        signOutButton.configure(color: UIColor(.black),
                                         font: UIFont.boldSystemFont(ofSize: 18),
                                         cornerRadius: signOutButton.bounds.height / 2,
                                         borderColor: borderColor,
                                         backgroundColor: .white,
                                         borderWidth: 1.0)
        
        usernameTextField.configure(color: UIColor(.black),
                                         font: UIFont.systemFont(ofSize: 16),
                                         cornerRadius: usernameTextField.bounds.height / 2,
                                         borderColor: borderColor,
                                         backgroundColor: UIColor(.white),
                                         borderWidth: 1.0)
        usernameTextField.clipsToBounds = true
        
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 25)
        emailLabel.font = UIFont.boldSystemFont(ofSize: 16)
        emailLabel.textColor = .gray
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.size.width / 2
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let user = Auth.auth().currentUser!
        if !(user.photoURL == nil) {
            userProfileImageView.kf.setImage(with: user.photoURL)
        }
        userNameLabel.text = user.displayName!
        emailLabel.text = user.email!
    }
    
    

    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        signOut()
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func changePasswordButtonPressed(_ sender: UIButton) {
        sendPasswordReset()
    }
    
    @IBAction func editUserNameButtonPressed(_ sender: UIButton) {
        if editUsernameButton.currentTitle! == "Edit" {
            editUsernameButton.setTitle("Cancel", for: .normal)
            usernameTextField.text = userNameLabel.text
            usernameTextField.isHidden = false
            submitButton.isHidden = false
        } else {
            editUsernameButton.setTitle("Edit", for: .normal)
            usernameTextField.isHidden = true
            submitButton.isHidden = true
        }
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.image"]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        userProfileDatabaseService.updateUsername(username: usernameTextField.text!) { result in
            switch result {
            case .failure(let error):
                self.activityIndicator.stopAnimating()
                AlertPresenter.presentAlertController(self, title: "Failed to update username", message: error.localizedDescription)
            case .success(let username):
                self.userNameLabel.text = username
                self.activityIndicator.stopAnimating()
            }
        }
        
        editUsernameButton.setTitle("Edit", for: .normal)
        usernameTextField.isHidden = true
        submitButton.isHidden = true
    }
    
    @IBAction func usernameTextFieldDidChange(_ sender: TextField) {
        if !usernameTextField.text!.isEmpty {
            submitButton.isEnabled = true
        } else {
            submitButton.isEnabled = false
        }
    }
}

extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            userProfileImageView.image = image
            uploadUserPhoto(image: image)
        } else { return }
    }
}

extension UserProfileViewController {
    
    private func uploadUserPhoto(image: UIImage) {
        let user = Auth.auth().currentUser!
        userProfileDatabaseService.uploadUserProfilePhoto(imageId: user.uid, image: image) { (result) in
            switch result {
            case .failure(let error):
                print("\(error)")
            case .success(let URL):
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.photoURL = URL
                changeRequest.commitChanges { (error) in
                    if let error = error {
                        self.activityIndicator.stopAnimating()
                        print("\(error)")
                    } else {
                        self.userProfileDatabaseService.saveUser(uid: user.uid, username: user.displayName!, email: user.email!, photoURL: user.photoURL!.absoluteString) { (result) in
                            switch result {
                            case .failure(let error):
                                print("\(error)")
                            case .success(_):
                                print("User's photoURL updated.")
                            }
                        }
                        self.activityIndicator.stopAnimating()
                        print("User profile photo updated.")
                    }
                }
            }
        }
    }
    
    
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                loginViewController.modalPresentationStyle = .fullScreen
                self.present(loginViewController, animated: true)
                return
            }
        } catch let error {
            AlertPresenter.presentAlertController(self, title: "Failed to sign out", message: error.localizedDescription)
        }
    }
    
    private func sendPasswordReset() {
        let user = Auth.auth().currentUser!
        Auth.auth().sendPasswordReset(withEmail: user.email!) { (error) in
            if let error = error {
                print("\(error)")
            } else {
                AlertPresenter.presentAlertController(self, title: "Password Reset", message: "Email with link to reset your password was sent to your email: \(user.email!)")
            }
        }
    }
}
