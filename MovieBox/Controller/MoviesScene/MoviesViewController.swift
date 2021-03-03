//
//  MoviesViewController.swift
//  MovieBox
//
//  Created by Димас on 28.01.2021.
//

import UIKit
import FirebaseAuth
import Kingfisher

class MoviesViewController: UIViewController {

    private let borderColor: UIColor = UIColor(red: 220.0/255.0, green: 221.0/255.0, blue: 229.0/255.0, alpha: 1.0)
    private let tintColor = UIColor(red: 237.0/255.0, green: 101.0/255.0, blue: 106.0/255.0, alpha: 1.0)
    
    let moviesDatabaseService = MovieDatabaseService.shared
    let reviewsDatabaseService = ReviewDatabaseService.shared
    let ratingDatabaseService = RatingDatabaseService.shared
    let adminDatabaseService = AdminDatabaseService.shared
    var movies = [Movie]()
    var mostRecentMovies = [Movie]()
    var searchedMovies = [Movie]()
    var searching = false
    
    @IBOutlet var addBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var titleLabel: Label!
    @IBOutlet weak var searchTextField: TextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: tintColor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25)]
        self.tabBarController?.tabBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.backgroundImage = UIImage()
        self.tabBarController?.tabBar.clipsToBounds = true
        self.navigationItem.backButtonTitle = "Movies"
        
        addBarButtonItem.tintColor = tintColor
        
        titleLabel.textColor = tintColor
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        
        searchTextField.configure(color: .black,
                                  font: UIFont.systemFont(ofSize: 16),
                                  cornerRadius: searchTextField.bounds.height / 2,
                                  borderColor: borderColor,
                                  backgroundColor: .white,
                                  borderWidth: 1.0)
        searchTextField.clipsToBounds = true
        
        self.hideKeyboardWhenTappedAround()
        updateMovies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        checkAvailabilityOfAddButton()
        updateMovies()
    }
    
    @IBAction func searchTextFieldDidChange(_ sender: TextField) {
        titleLabel.isHidden = true
        searchedMovies.removeAll()
        if searchTextField.text?.count != 0 {
            for movie in movies {
                if movie.title.lowercased().starts(with: searchTextField.text!.lowercased()) {
                    searchedMovies.append(movie)
                }
            }
            searching = true
        } else {
            titleLabel.isHidden = false
            searching = false
        }
        
        moviesTableView.reloadData()
    }

}

extension MoviesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searching ? searchedMovies.count : mostRecentMovies.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedMovie: Movie
        if searching {
            selectedMovie = searchedMovies[indexPath.row]
        } else {
            selectedMovie = mostRecentMovies[indexPath.row]
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! MovieTableViewCell
            if let viewController = storyboard?.instantiateViewController(identifier: "MovieViewController") as? MovieViewController {
                viewController.movie = selectedMovie
                reviewsDatabaseService.getAllReviewsForCurrentMovie(forMovieId: selectedMovie.id) { (result) in
                    switch result {
                    case .success(let reviews):
                        viewController.reviews = reviews
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                viewController.movieImage = cell.movieImageView.image
                viewController.movieBoxRate = cell.ratingLabel.text
                viewController.movieBoxRateCount = cell.ratingCountLabel.text
                navigationController?.pushViewController(viewController, animated: true)
            }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        
        var movie: Movie
        if searching {
            movie = searchedMovies[indexPath.row]
        } else {
            movie = mostRecentMovies[indexPath.row]
        }
        
        cell.titleLabel.text = movie.title
        cell.yearLabel.text = movie.year
        cell.genreLabel.text = movie.genre
        cell.countryLabel.text = movie.country
        ratingDatabaseService.getAverageRatingForMovie(movieId: movie.id) { (result) in
            switch result {
            case .failure(_):
                cell.ratingLabel.backgroundColor = .gray
                cell.ratingLabel.text = "-"
            case .success(let ratingInfo):
                if ratingInfo.rating.isEqual(to: 0.0) {
                    cell.ratingLabel.backgroundColor = .gray
                    cell.ratingLabel.text = "-"
                    cell.ratingCountLabel.text = "0"
                } else {
                    if ratingInfo.rating <= 2.0 {
                        cell.ratingLabel.backgroundColor = .red
                    } else if ratingInfo.rating < 4.0 {
                        cell.ratingLabel.backgroundColor = .gray
                    } else {
                        cell.ratingLabel.backgroundColor = .systemGreen
                    }
                    cell.ratingLabel.text = String(format: "%.1f", ratingInfo.rating)
                    cell.ratingCountLabel.text = "\(ratingInfo.count)"
                }
            }
        }

        cell.imageActivityIndicator.startAnimating()
        //MARK: TODO DEFAULT PICTURE
        cell.movieImageView.kf.setImage(with: URL(string: movie.imageUrl))
        cell.imageActivityIndicator.stopAnimating()
        
        return cell
    }
}

extension MoviesViewController {
    
    private func updateMovies() {
        moviesDatabaseService.getAllMovies { result in
            switch result {
            case .success(let movies):
                self.movies = movies
                self.movies.sort(by: { $0.date.seconds > $1.date.seconds})
                self.mostRecentMovies = Array(self.movies.prefix(2))
                self.moviesTableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func checkAvailabilityOfAddButton() {
        let uid = Auth.auth().currentUser!.uid
        adminDatabaseService.checkUserIsAdmin(uid: uid) { (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let isAdmin):
                if !isAdmin {
                    self.navigationItem.setRightBarButton(nil, animated: false)
                } else {
                    self.navigationItem.setRightBarButton(self.addBarButtonItem, animated: true)
                }
            }
        }
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
        if searchTextField.text?.count == 0{
            titleLabel.isHidden = false
        }
    }
}
