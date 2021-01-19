//
//  MovieViewController.swift
//  MovieBox
//
//  Created by Димас on 25.12.2020.
//

import UIKit
import AVKit
import FirebaseAuth
import Cosmos

class MovieViewController: UIViewController {

    var movieImage: UIImage?
    var movie: Movie?
    var reviews = [Review]()
    let movieDatabaseService = MovieDatabaseService.shared
    let reviewsDatabaseService = ReviewDatabaseService.shared
    let ratingDatabaseService = RatingDatabaseService.shared
    let adminDatabaseService = AdminDatabaseService.shared
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deleteMovieButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var newReviewTextField: UITextField!
    @IBOutlet weak var postReviewButton: UIButton!
    @IBOutlet weak var ratingView: CosmosView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAvailabilityOfDeleteMovieButton()
        
        updateUserRating()
        didTouchRating()
        
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self
        reviewsTableView.estimatedRowHeight = 100
        titleLabel.text = movie?.title
        genreLabel.text = movie?.genre
        movieImageView.image = movieImage
    }
    
    @IBAction func postReviewButtonPressed(_ sender: UIButton) {
        let username = Auth.auth().currentUser!.displayName!
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDate = formatter.string(from: date)
        reviewsDatabaseService.saveReview(text: newReviewTextField.text!, username: username, date: currentDate, movieId: movie!.id) { (result) in
            switch result {
            case .success(let successMessage):
                print(successMessage)
                self.reviewsDatabaseService.getAllReviewsForCurrentMovie(forMovieId: self.movie!.id) { (result) in
                    switch result {
                    case .success(let updatedReviews):
                        self.reviews = updatedReviews
                        self.reviewsTableView.reloadData()
                    case .failure(let error):
                        print("Failed to update reviews cause: \(error)")
                    }
                }
            case .failure(let error):
                print("Failed to save review cause: \(error)")
            }
        }
        newReviewTextField.text = ""
    }
    
    @IBAction func watchTrailerButtonPressed(_ sender: UIButton) {
        guard let url = URL(string: movie!.videoUrl) else { return }
        playTrailer(by: url)
    }
    
    @IBAction func showReviewsButtonPressed(_ sender: UIButton) {
        reviewsTableView.reloadData()
        reviewsTableView.isHidden = false
        newReviewTextField.isHidden = false
        postReviewButton.isHidden = false
    }
    
    @IBAction func deleteMovieButtonPressed(_ sender: UIButton) {
        activityIndicator.startAnimating()
        movieDatabaseService.deleteMovie(id: movie!.id) { (result) in
            switch result {
            case .failure(let error):
                self.activityIndicator.stopAnimating()
                print("Failed to delete movie cause: \(error)")
            case .success(let successMessage):
                self.reviewsDatabaseService.deleteAllReviewsForCurrentMovie(forMovieId: self.movie!.id)
                self.ratingDatabaseService.deleteAllRatingsForCurrentMovie(forMovieId: self.movie!.id)
                self.activityIndicator.stopAnimating()
                self.navigationController?.popViewController(animated: true)
                print(successMessage)
            }
        }
    }
    
    func playTrailer(by url: URL) {
        let player = AVPlayer(url: url)

        let vc = AVPlayerViewController()
        vc.player = player

        self.present(vc, animated: true) { vc.player?.play() }
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

extension MovieViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewTableViewCell
        
        let review = reviews[indexPath.row]
        
        cell.reviewTextLabel.text = review.text
        cell.nicknameLabel.text = review.username
        cell.dateLabel.text = review.date
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let reviewToDelete = reviews[indexPath.row]
            reviewsDatabaseService.deleteReview(id: reviewToDelete.id) { (result) in
                switch result {
                case .failure(let error):
                    print("Failed to delete review cause: \(error)")
                case .success(let successMessage):
                    self.reviews.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    print(successMessage)
                }
            }
            
        }
    }
}

extension MovieViewController {
    
    private func checkAvailabilityOfDeleteMovieButton() {
        let uid = Auth.auth().currentUser!.uid
        adminDatabaseService.checkUserIsAdmin(uid: uid) { (result) in
            switch result {
            case .failure(let error):
                print("Cannot get admin info cause: \(error)")
            case .success(let isAdmin):
                if isAdmin {
                    self.deleteMovieButton.isHidden = false
                }
            }
        }
    }
    
    private func updateUserRating() {
        let username = Auth.auth().currentUser!.displayName!
        ratingDatabaseService.getUserRatingForCurrentMovie(movieId: movie!.id, username: username) { (result) in
            switch result {
            case .success(let rating):
                if (!rating.isEmpty) {
                    self.ratingView.rating = Double(rating[0].value)
                }
            case .failure(let error):
                print("Can't ger user rate cause: \(error)")
            }
        }
    }
    
    private func didTouchRating() {
        let username = Auth.auth().currentUser!.displayName!
        ratingView.didTouchCosmos = { rating in
            self.ratingDatabaseService.saveRating(movieId: self.movie!.id, value: Int(rating), username: username) { (result) in
                switch result {
                case .success(let successMessage):
                    print(successMessage)
                case .failure(let error):
                    print("Can't save user rate cause: \(error)")
                }
            }
        }
    }
}
