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
    
    let userProfileDatabaseService = UserProfileDatabaseService.shared
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var editUsernameButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.size.width / 2
        userProfileImageView.layer.borderWidth = 0.5
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
        updateUsername(username: usernameTextField.text!)
        
        editUsernameButton.setTitle("Edit", for: .normal)
        usernameTextField.isHidden = true
        submitButton.isHidden = true
    }
    
    @IBAction func usernameTextFieldDidChange(_ sender: UITextField) {
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
    
    private func updateUsername(username: String) {
        let user = Auth.auth().currentUser!
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = username
        changeRequest.commitChanges { (error) in
            if let error = error {
                self.activityIndicator.stopAnimating()
                print("\(error)")
            } else {
                self.userProfileDatabaseService.saveUser(uid: user.uid, username: username, email: user.email!, photoURL: user.photoURL!.absoluteString) { (result) in
                    switch result {
                    case .failure(let error):
                        print("\(error)")
                    case .success(_):
                        self.userNameLabel.text = username
                        self.activityIndicator.stopAnimating()
                        print("Username updated.")
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
            print("Failed to sign out with error: ", error.localizedDescription)
        }
    }
    
    private func sendPasswordReset() {
        let user = Auth.auth().currentUser!
        Auth.auth().sendPasswordReset(withEmail: user.email!) { (error) in
            if let error = error {
                print("\(error)")
            } else {
                let alert = UIAlertController(title: "Password Reset", message: "Email with link to reset your password was sent to your email: \(user.email!)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
