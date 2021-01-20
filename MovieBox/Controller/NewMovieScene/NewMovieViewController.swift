//
//  NewMovieViewController.swift
//  MovieBox
//
//  Created by Димас on 09.11.2020.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class NewMovieViewController: UIViewController {
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var sloganTextField: UITextField!
    @IBOutlet weak var videoLabel: UILabel!
    @IBOutlet weak var savingActivityIndicator: UIActivityIndicatorView!
    
    var videoURL: URL?
    let databaseService = MovieDatabaseService.shared
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieImageView.layer.cornerRadius = 50
        movieImageView.layer.borderWidth = 0.5
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.image"]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        savingActivityIndicator.startAnimating()
        guard let image = movieImageView.image else { return }
        databaseService.saveMovie(title: titleTextField.text!, genre: genreTextField.text!, year: yearTextField.text!, country: countryTextField.text!, slogan: sloganTextField.text!, image: image, videoURL: videoURL!) { (result) in
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
    
    func checkAvailabilityToSave() {
        if !titleTextField.text!.isEmpty {
            if !genreTextField.text!.isEmpty {
                if !yearTextField.text!.isEmpty {
                    if !countryTextField.text!.isEmpty {
                        if !sloganTextField.text!.isEmpty {
                            if movieImageView.image != nil {
                                if videoLabel.text != "No video" {
                                    navigationItem.rightBarButtonItem!.isEnabled = true
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
        navigationItem.rightBarButtonItem!.isEnabled = false
    }
}
