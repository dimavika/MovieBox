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
    @IBOutlet weak var genreTextField: UITextField!
    let databaseService = DatabaseService.shared
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieImageView.layer.cornerRadius = 50
        movieImageView.layer.borderWidth = 0.5
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        databaseService.saveMovie(title: titleTextField.text!, genre: genreTextField.text!)
        self.navigationController?.popViewController(animated: true)
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
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        movieImageView.image = image
    }
}
