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

    private let blueButtonColor = UIColor(red: 57.0/255.0, green: 77.0/255.0, blue: 141.0/255.0, alpha: 1.0)
    
    var movieImage: UIImage?
    var movie: Movie?
    var movieBoxRate: String?
    var movieBoxRateCount: String?
    var reviews = [Review]()
    let movieDatabaseService = MovieDatabaseService.shared
    let reviewsDatabaseService = ReviewDatabaseService.shared
    let ratingDatabaseService = RatingDatabaseService.shared
    let adminDatabaseService = AdminDatabaseService.shared
    let userProfileDatabaseService = UserProfileDatabaseService.shared
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var deleteMovieButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var sloganLabel: UILabel!
    @IBOutlet weak var myRateLabel: UILabel!
    @IBOutlet weak var movieBoxRateTitleLabel: UILabel!
    @IBOutlet weak var movieBoxRateLabel: UILabel!
    @IBOutlet weak var movieBoxRateCountLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var newReviewTextField: TextField!
    @IBOutlet weak var postReviewButton: UIButton!
    @IBOutlet weak var showReviewsButton: UIButton!
    @IBOutlet weak var watchTrailerButton: UIButton!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAvailabilityOfDeleteMovieButton()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = Constants.tintColor
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        titleLabel.textColor = Constants.tintColor
        yearLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        genreLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        countryLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        sloganLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        sloganLabel.textColor = .gray
        myRateLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        movieBoxRateTitleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        movieBoxRateLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        movieBoxRateLabel.textColor = .white
        movieBoxRateLabel.clipsToBounds = true
        movieBoxRateLabel.layer.cornerRadius = movieBoxRateLabel.frame.size.width / 2
        movieBoxRateCountLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        movieBoxRateCountLabel.textColor = .gray
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        
        deleteMovieButton.configure(color: UIColor(.white),
                                         font: UIFont.boldSystemFont(ofSize: 15),
                                         cornerRadius: deleteMovieButton.bounds.height / 2,
                                         borderColor: Constants.tintColor,
                                         backgroundColor: Constants.tintColor,
                                         borderWidth: 1.0)
        watchTrailerButton.configure(color: UIColor(.white),
                                         font: UIFont.boldSystemFont(ofSize: 15),
                                         cornerRadius: watchTrailerButton.bounds.height / 2,
                                         borderColor: blueButtonColor,
                                         backgroundColor: blueButtonColor,
                                         borderWidth: 1.0)
        showReviewsButton.configure(color: UIColor(.white),
                                         font: UIFont.boldSystemFont(ofSize: 15),
                                         cornerRadius: showReviewsButton.bounds.height / 2,
                                         borderColor: blueButtonColor,
                                         backgroundColor: blueButtonColor,
                                         borderWidth: 1.0)
        postReviewButton.configure(color: UIColor(.white),
                                   font: UIFont.boldSystemFont(ofSize: 15),
                                   cornerRadius: postReviewButton.bounds.height / 2,
                                   borderColor: Constants.tintColor,
                                   backgroundColor: Constants.tintColor,
                                   borderWidth: 1.0)
        
        newReviewTextField.configure(color: UIColor(.black),
                                         font: UIFont.systemFont(ofSize: 16),
                                         cornerRadius: newReviewTextField.bounds.height / 2,
                                         borderColor: Constants.borderColor,
                                         backgroundColor: UIColor(.white),
                                         borderWidth: 1.0)
        newReviewTextField.clipsToBounds = true
        
        self.hideKeyboardWhenTappedAround()
        
        updateUserRating()
        didTouchRating()
        
        movieImageView.layer.cornerRadius = 10
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self
        titleLabel.text = movie!.title
        yearLabel.text = movie!.year
        genreLabel.text = movie!.genre
        countryLabel.text = movie!.country
        sloganLabel.text = "\"\(movie!.slogan)\""
        descriptionLabel.text = movie!.description
        if ((movieBoxRate != nil) && (movieBoxRateCount != nil)) {
            if movieBoxRate == "-" {
                self.movieBoxRateLabel.backgroundColor = .gray
            } else {
                if Double(movieBoxRate!)! <= 2.0 {
                    self.movieBoxRateLabel.backgroundColor = .red
                } else if Double(movieBoxRate!)! < 4.0 {
                    self.movieBoxRateLabel.backgroundColor = .gray
                } else {
                    self.movieBoxRateLabel.backgroundColor = .systemGreen
                }
            }
            movieBoxRateLabel.text = movieBoxRate
            movieBoxRateCountLabel.text = movieBoxRateCount
        } else {
            updateMovieBoxRate()
        }
        
        if movieImage != nil {
            movieImageView.image = movieImage
        } else {
            movieImageView.kf.setImage(with: URL(string: movie!.imageUrl))
            if movieImageView.image == nil {
                movieImageView.image = UIImage(named: "def-movie-icon")
            }
        }
        
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
    
    @IBAction func postReviewButtonPressed(_ sender: UIButton) {
        let user = Auth.auth().currentUser!
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDate = formatter.string(from: date)
        reviewsDatabaseService.saveReview(text: newReviewTextField.text!, uid: user.uid, date: currentDate, movieId: movie!.id) { (result) in
            switch result {
            case .success(_):
                self.reviewsDatabaseService.getAllReviewsForCurrentMovie(forMovieId: self.movie!.id) { (result) in
                    switch result {
                    case .success(let updatedReviews):
                        self.reviews = updatedReviews
                        self.reviewsTableView.reloadData()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                AlertPresenter.presentAlertController(self, title: "Post review", message: error.localizedDescription)
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
                AlertPresenter.presentAlertController(self, title: "Delete movie", message: error.localizedDescription)
            case .success(_):
                self.reviewsDatabaseService.deleteAllReviewsForCurrentMovie(forMovieId: self.movie!.id) { (result) in
                    switch result {
                    case .success( _):
                        self.ratingDatabaseService.deleteAllRatingsForCurrentMovie(forMovieId: self.movie!.id) { (result) in
                            switch result {
                            case .success(_):
                                self.activityIndicator.stopAnimating()
                                self.navigationController?.popViewController(animated: true)
                            case .failure(let error):
                                print("\(error.localizedDescription)")
                            }
                        }
                    case .failure(let error):
                        print("\(error.localizedDescription)")
                    }
                }
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewTableViewCell
        
        let review = reviews[indexPath.row]
        
        userProfileDatabaseService.getUserByUid(uid: review.uid) { (result) in
            switch result {
            case .failure(_):
                cell.usernameLabel.text = "Unknown"
            case .success(let user):
                cell.usernameLabel.text = user.username
                if !(user.photoURL == "No photo") {
                    cell.userPhotoImageView.kf.setImage(with: URL(string: user.photoURL))
                }
            }
        }
        cell.reviewTextLabel.text = review.text
        cell.dateLabel.text = review.date
        
        return cell
    }
    
}

extension MovieViewController {
    
    @objc func keyboardWillChange(notification: NSNotification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            if (navigationController!.navigationBar.frame.origin.y >= 0) {
                navigationController?.navigationBar.frame.origin.y = navigationController!.navigationBar.frame.origin.y + tabBarController!.tabBar.frame.height - keyboardRect.height
                view.frame.origin.y = tabBarController!.tabBar.frame.height - keyboardRect.height
            }
        } else {
            navigationController?.navigationBar.frame.origin.y = navigationController!.navigationBar.frame.origin.y - tabBarController!.tabBar.frame.height + keyboardRect.height
            view.frame.origin.y = 0
        }
    }
    
    private func checkAvailabilityOfDeleteMovieButton() {
        let uid = Auth.auth().currentUser!.uid
        adminDatabaseService.checkUserIsAdmin(uid: uid) { (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
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
                print(error.localizedDescription)
            }
        }
    }
    
    private func didTouchRating() {
        let user = Auth.auth().currentUser!
        ratingView.didTouchCosmos = { rating in
            self.ratingDatabaseService.saveRating(movieId: self.movie!.id, value: Int(rating), uid: user.uid) { (result) in
                switch result {
                case .success(_):
                    self.updateMovieBoxRate()
                case .failure(let error):
                    AlertPresenter.presentAlertController(self, title: "Save rate", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func updateMovieBoxRate() {
        ratingDatabaseService.getAverageRatingForMovie(movieId: movie!.id) { (result) in
            switch result {
            case .failure(_):
                self.movieBoxRateLabel.text = "-"
                self.movieBoxRateLabel.backgroundColor = .gray
            case .success(let ratingInfo):
                if ratingInfo.rating.isEqual(to: 0.0) {
                    self.movieBoxRateLabel.text = "-"
                    self.movieBoxRateLabel.backgroundColor = .gray
                    self.movieBoxRateCountLabel.text = "0"
                } else {
                    if ratingInfo.rating <= 2.0 {
                        self.movieBoxRateLabel.backgroundColor = .red
                    } else if ratingInfo.rating < 4.0 {
                        self.movieBoxRateLabel.backgroundColor = .gray
                    } else {
                        self.movieBoxRateLabel.backgroundColor = .systemGreen
                    }
                    self.movieBoxRateLabel.text = String(format: "%.1f", ratingInfo.rating)
                    self.movieBoxRateCountLabel.text = "\(ratingInfo.count)"
                }
            }
        }
    }
}
