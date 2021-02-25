//
//  NewMovieViewController.swift
//  MovieBox
//
//  Created by Димас on 09.11.2020.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import MultilineTextField

class NewMovieViewController: UIViewController {
    
    var videoURL: URL?
    let databaseService = MovieDatabaseService.shared
    
    private let borderColor: UIColor = UIColor(red: 220.0/255.0, green: 221.0/255.0, blue: 229.0/255.0, alpha: 1.0)
    private let tintColor = UIColor(red: 237.0/255.0, green: 101.0/255.0, blue: 106.0/255.0, alpha: 1.0)
    private let topButtonsColor = UIColor(red: 57.0/255.0, green: 77.0/255.0, blue: 141.0/255.0, alpha: 1.0)
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleTextField: TextField!
    @IBOutlet weak var yearTextField: TextField!
    @IBOutlet weak var genreTextField: TextField!
    @IBOutlet weak var countryTextField: TextField!
    @IBOutlet weak var sloganTextField: TextField!
    @IBOutlet weak var descriptionTextView: MultilineTextField!
    @IBOutlet weak var videoLabel: UILabel!
    @IBOutlet weak var savingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = tintColor
        
        saveButton.configure(color: UIColor(.gray),
                                 font: UIFont.boldSystemFont(ofSize: 15),
                                 cornerRadius: saveButton.bounds.height / 2,
                                 borderColor: borderColor,
                                 backgroundColor: .white,
                                 borderWidth: 1.0)
        photoButton.configure(color: UIColor(.white),
                                 font: UIFont.boldSystemFont(ofSize: 15),
                                 cornerRadius: photoButton.bounds.height / 2,
                                 borderColor: topButtonsColor,
                                 backgroundColor: topButtonsColor,
                                 borderWidth: 1.0)
        videoButton.configure(color: UIColor(.white),
                                 font: UIFont.boldSystemFont(ofSize: 15),
                                 cornerRadius: videoButton.bounds.height / 2,
                                 borderColor: topButtonsColor,
                                 backgroundColor: topButtonsColor,
                                 borderWidth: 1.0)
        
        titleTextField.configure(color: UIColor(.black),
                                 font: UIFont.systemFont(ofSize: 16),
                                 cornerRadius: titleTextField.bounds.height / 2,
                                 borderColor: borderColor,
                                 backgroundColor: UIColor(.white),
                                 borderWidth: 1.0)
        titleTextField.clipsToBounds = true
        yearTextField.configure(color: UIColor(.black),
                                 font: UIFont.systemFont(ofSize: 16),
                                 cornerRadius: yearTextField.bounds.height / 2,
                                 borderColor: borderColor,
                                 backgroundColor: UIColor(.white),
                                 borderWidth: 1.0)
        yearTextField.clipsToBounds = true
        genreTextField.configure(color: UIColor(.black),
                                 font: UIFont.systemFont(ofSize: 16),
                                 cornerRadius: genreTextField.bounds.height / 2,
                                 borderColor: borderColor,
                                 backgroundColor: UIColor(.white),
                                 borderWidth: 1.0)
        genreTextField.clipsToBounds = true
        countryTextField.configure(color: UIColor(.black),
                                 font: UIFont.systemFont(ofSize: 16),
                                 cornerRadius: countryTextField.bounds.height / 2,
                                 borderColor: borderColor,
                                 backgroundColor: UIColor(.white),
                                 borderWidth: 1.0)
        countryTextField.clipsToBounds = true
        sloganTextField.configure(color: UIColor(.black),
                                 font: UIFont.systemFont(ofSize: 16),
                                 cornerRadius: sloganTextField.bounds.height / 2,
                                 borderColor: borderColor,
                                 backgroundColor: UIColor(.white),
                                 borderWidth: 1.0)
        sloganTextField.clipsToBounds = true
        
        videoLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        movieImageView.layer.cornerRadius = movieImageView.frame.size.width / 2
        movieImageView.layer.borderColor = borderColor.cgColor
        movieImageView.layer.borderWidth = 1.0
        
//        descriptionTextView.isEditable = true
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.layer.borderColor = borderColor.cgColor
        descriptionTextView.layer.cornerRadius = descriptionTextView.frame.height / 4
        descriptionTextView.layer.borderWidth = 1.0
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.image"]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        savingActivityIndicator.startAnimating()
        guard let image = movieImageView.image else { return }
        databaseService.saveMovie(title: titleTextField.text!, genre: genreTextField.text!, year: yearTextField.text!, country: countryTextField.text!, slogan: sloganTextField.text!, description: descriptionTextView.text, image: image, videoURL: videoURL!) { (result) in
            switch result {
            case .success(let successMessage):
                self.savingActivityIndicator.stopAnimating()
                self.navigationController?.popViewController(animated: true)
                print(successMessage)
            case .failure(let error):
                self.savingActivityIndicator.stopAnimating()
                print(error)
            }
        }
    }
    
    @IBAction func videoButtonPressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.movie"]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func titleTextFieldDidChange(_ sender: UITextField) {
        checkAvailabilityToSave()
    }
    
    @IBAction func genreTextFieldDidChange(_ sender: UITextField) {
        checkAvailabilityToSave()
    }
    
    @IBAction func yearTextFieldDidChange(_ sender: UITextField) {
        checkAvailabilityToSave()
    }
    
    @IBAction func countryTextFieldDidChange(_ sender: UITextField) {
        checkAvailabilityToSave()
    }
    
    @IBAction func sloganTextFieldDidChange(_ sender: UITextField) {
        checkAvailabilityToSave()
    }
    
}

extension NewMovieViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            movieImageView.image = image
            checkAvailabilityToSave()
        } else
        if let url = info[.mediaURL] as? URL {
            videoURL = url
            videoLabel.text = "\(url)"
            checkAvailabilityToSave()
        } else { return }
    }
}

extension NewMovieViewController {
    
    @objc func keyboardWillChange(notification: NSNotification) {
        if notification.name == UIResponder.keyboardWillShowNotification {
            guard let userInfo = notification.userInfo else { return }
            var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            
            var contentInset:UIEdgeInsets = self.scrollView.contentInset
            contentInset.bottom = keyboardFrame.size.height + 20
            scrollView.contentInset = contentInset
        } else {
            let contentInset:UIEdgeInsets = UIEdgeInsets.zero
            scrollView.contentInset = contentInset
        }
    }
    
    private func checkAvailabilityToSave() {
        if !titleTextField.text!.isEmpty {
            if !genreTextField.text!.isEmpty {
                if !yearTextField.text!.isEmpty {
                    if !countryTextField.text!.isEmpty {
                        if !sloganTextField.text!.isEmpty {
                            if descriptionTextView.hasText {
                                if movieImageView.image != nil {
                                    if videoLabel.text != "No video" {
                                        navigationItem.rightBarButtonItem!.isEnabled = true
                                        saveButton.setTitleColor(.white, for: .normal)
                                        saveButton.backgroundColor = tintColor
                                        saveButton.layer.borderColor = tintColor.cgColor
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        navigationItem.rightBarButtonItem!.isEnabled = false
        saveButton.setTitleColor(.gray, for: .normal)
        saveButton.backgroundColor = .white
        saveButton.layer.borderColor = borderColor.cgColor
    }
}
