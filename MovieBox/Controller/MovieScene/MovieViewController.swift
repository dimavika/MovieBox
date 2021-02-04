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
import Kingfisher

class MovieViewController: UIViewController {

    var movieImage: UIImage?
    var movie: Movie?
    var reviews = [Review]()
    let movieDatabaseService = MovieDatabaseService.shared
    let reviewsDatabaseService = ReviewDatabaseService.shared
    let ratingDatabaseService = RatingDatabaseService.shared
    let adminDatabaseService = AdminDatabaseService.shared
    let userProfileDatabaseService = UserProfileDatabaseService.shared
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deleteMovieButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var sloganLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var newReviewTextField: UITextField!
    @IBOutlet weak var postReviewButton: UIButton!
    @IBOutlet weak var showReviewsButton: UIButton!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAvailabilityOfDeleteMovieButton()
        
        updateUserRating()
        didTouchRating()
        
        movieImageView.layer.cornerRadius = 10
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self
//        reviewsTableView.estimatedRowHeight = 100
        titleLabel.text = "\(movie!.title) (\(movie!.year))"
        genreLabel.text = movie!.genre
        countryLabel.text = movie!.country
        sloganLabel.text = "\"\(movie!.slogan)\""
        descriptionLabel.text = movie!.description
        movieImageView.image = movieImage
    }
    
    @IBAction func postReviewButtonPressed(_ sender: UIButton) {
        let user = Auth.auth().currentUser!
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDate = formatter.string(from: date)
        reviewsDatabaseService.saveReview(text: newReviewTextField.text!, uid: user.uid, date: currentDate, movieId: movie!.id) { (result) in
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
        if showReviewsButton.currentTitle! == "Show reviews" {
            descriptionLabel.isHidden = true
            showReviewsButton.setTitle("Hide reviews", for: .normal)
            reviewsTableView.isHidden = false
            newReviewTextField.isHidden = false
            postReviewButton.isHidden = false
        } else {
            descriptionLabel.isHidden = false
            showReviewsButton.setTitle("Show reviews", for: .normal)
            reviewsTableView.isHidden = true
            newReviewTextField.isHidden = true
            postReviewButton.isHidden = true
        }
    }
    
    @IBAction func deleteMovieButtonPressed(_ sender: UIButton) {
        activityIndicator.startAnimating()
        movieDatabaseService.deleteMovie(id: movie!.id) { (result) in
            switch result {
            case .failure(let error):
                self.activityIndicator.stopAnimating()
                print("Failed to delete movie cause: \(error)")
            case .success(let successMessage):
                self.reviewsDatabaseService.deleteAllReviewsForCurrentMovie(forMovieId: self.movie!.id) { (result) in
                    switch result {
                    case .success( _):
                        self.ratingDatabaseService.deleteAllRatingsForCurrentMovie(forMovieId: self.movie!.id) { (result) in
                            switch result {
                            case .success( _):
                                self.activityIndicator.stopAnimating()
                                self.navigationController?.popViewController(animated: true)
                            case .failure(let error):
                                print("\(error)")
                            }
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                }
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
}

extension MovieViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewTableViewCell
        
        let review = reviews[indexPath.row]
        
        userProfileDatabaseService.getUserByUid(uid: review.uid) { (result) in
            switch result {
            case .failure(let error):
                cell.nicknameLabel.text = "Unknown"
                print("\(error)")
            case .success(let user):
                cell.nicknameLabel.text = user.username
                if !(user.photoURL == "No photo") {
                    cell.userPhotoImageView.kf.setImage(with: URL(string: user.photoURL))
                }
            }
        }
        cell.reviewTextLabel.text = review.text
        cell.dateLabel.text = review.date
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let reviewToDelete = reviews[indexPath.row]
//            reviewsDatabaseService.deleteReview(id: reviewToDelete.id) { (result) in
//                switch result {
//                case .failure(let error):
//                    print("Failed to delete review cause: \(error)")
//                case .success(let successMessage):
//                    self.reviews.remove(at: indexPath.row)
//                    tableView.deleteRows(at: [indexPath], with: .fade)
//                    print(successMessage)
//                }
//            }
//
//        }
//    }
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
        let user = Auth.auth().currentUser!
        ratingDatabaseService.getUserRatingForCurrentMovie(movieId: movie!.id, uid: user.uid) { (result) in
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
        let user = Auth.auth().currentUser!
        ratingView.didTouchCosmos = { rating in
            self.ratingDatabaseService.saveRating(movieId: self.movie!.id, value: Int(rating), uid: user.uid) { (result) in
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
