//
//  MoviesViewController.swift
//  MovieBox
//
//  Created by Димас on 28.01.2021.
//

import UIKit
import FirebaseAuth

class MoviesViewController: UIViewController {

    let moviesDatabaseService = MovieDatabaseService.shared
    let reviewsDatabaseService = ReviewDatabaseService.shared
    let ratingDatabaseService = RatingDatabaseService.shared
    let adminDatabaseService = AdminDatabaseService.shared
    var movies = [Movie]()
    var searchedMovies = [Movie]()
    var searching = false
    
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        searchBar.delegate = self
        updateMovies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        checkAvailabilityOfAddButton()
        updateMovies()
    }
}

extension MoviesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searching ? searchedMovies.count : movies.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = movies[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! MovieTableViewCell
            if let viewController = storyboard?.instantiateViewController(identifier: "MovieViewController") as? MovieViewController {
                viewController.movie = selectedMovie
                reviewsDatabaseService.getAllReviewsForCurrentMovie(forMovieId: selectedMovie.id) { (result) in
                    switch result {
                    case .success(let reviews):
                        viewController.reviews = reviews
                    case .failure(let error):
                        print("Can't get reviews cause: \(error)")
                    }
                }
                viewController.movieImage = cell.movieImageView.image
                navigationController?.pushViewController(viewController, animated: true)
            }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        
        var movie: Movie
        if searching {
            movie = searchedMovies[indexPath.row]
        } else {
            movie = movies[indexPath.row]
        }
        
        cell.titleLabel.text = "\(movie.title) (\(movie.year))"
        cell.genreLabel.text = movie.genre
        cell.countryLabel.text = movie.country
        ratingDatabaseService.getAverageRatingForMovie(movieId: movie.id) { (result) in
            switch result {
            case .failure(let error):
                cell.ratingLabel.text = "-"
                print("Cannot get average rating of movie named: \(movie.title) cause: \(error)")
            case .success(let ratingInfo):
                if ratingInfo.rating.isEqual(to: 0.0) {
                    cell.ratingLabel.textColor = .black
                    cell.ratingLabel.text = "-"
                    cell.ratingCountLabel.text = "0"
                } else {
                    if ratingInfo.rating <= 2.0 {
                        cell.ratingLabel.textColor = .red
                    } else if ratingInfo.rating < 4.0 {
                        cell.ratingLabel.textColor = .gray
                    } else {
                        cell.ratingLabel.textColor = .systemGreen
                    }
                    cell.ratingLabel.text = String(format: "%.1f", ratingInfo.rating)
                    cell.ratingCountLabel.text = "\(ratingInfo.count)"
                }
            }
        }

        cell.imageActivityIndicator.startAnimating()
        moviesDatabaseService.downloadImage(forURL: movie.imageUrl) { result in
            switch result {
            case .success(let image):
                cell.movieImageView.image = image
                cell.imageActivityIndicator.stopAnimating()
            //MARK: TODO DEFAULT PICTURE
            case .failure(let error):
                print("No image cause: \(error)")
            }
        }
        
        return cell
    }
}

extension MoviesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedMovies.removeAll()
        for movie in movies {
            if movie.title.lowercased().starts(with: searchText.lowercased()) {
                searchedMovies.append(movie)
            }
        }
        searching = true
        moviesTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searching = false
        moviesTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if searching {
            if selectedScope == 0 {
                
            } else {
                searchedMovies.sort(by: {Int($0.year)! > Int($1.year)!})
            }
        } else {
            if selectedScope == 0 {
                
            } else {
                movies.sort(by: {Int($0.year)! > Int($1.year)!})
            }
        }
        moviesTableView.reloadData()
    }
}

extension MoviesViewController {
    
    private func updateMovies() {
        moviesDatabaseService.getAllMovies { result in
            switch result {
            case .success(let movies):
                self.movies = movies
                self.moviesTableView.reloadData()
            case .failure(let error):
                print("Cannot get movies cause: \(error)")
            }
        }
    }
    
    private func checkAvailabilityOfAddButton() {
        let uid = Auth.auth().currentUser!.uid
        adminDatabaseService.checkUserIsAdmin(uid: uid) { (result) in
            switch result {
            case .failure(let error):
                print("Cannot get admin info cause: \(error)")
            case .success(let isAdmin):
                if !isAdmin {
                    self.navigationItem.setRightBarButton(nil, animated: false)
                }
            }
        }
    }
}
