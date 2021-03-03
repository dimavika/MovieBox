//
//  ViewController.swift
//  MovieBox
//
//  Created by Димас on 08.10.2020.
//

import UIKit
import FirebaseAuth
import Kingfisher

class MainViewController: UIViewController {

    private let tintColor = UIColor(red: 237.0/255.0, green: 101.0/255.0, blue: 106.0/255.0, alpha: 1.0)
    
    let moviesDatabaseService = MovieDatabaseService.shared
    let ratingDatabaseService = RatingDatabaseService.shared
    let reviewsDatabaseService = ReviewDatabaseService.shared
    
    var ratingsByLastMonth = [Rating]()
    var movieAndRatingsCount = [Movie: Int]()
    var moviesAndAvgRating = [Movie: Double]()
    
    @IBOutlet weak var titleLabel: UILabel!
    var popularMoviesCollectionView = MoviesCollectionView()
    var topRatedMoviesCollectionView = MoviesCollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: tintColor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25)]
        self.navigationItem.backButtonTitle = "Home"
        self.tabBarController?.tabBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.backgroundImage = UIImage()
        self.tabBarController?.tabBar.clipsToBounds = true
        self.tabBarController?.tabBar.tintColor = tintColor
        
        let secondTitleLabel = UILabel()
        secondTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        secondTitleLabel.textColor = tintColor
        secondTitleLabel.text = "Top rated movies:"
        secondTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = tintColor
        
        view.addSubview(secondTitleLabel)
        view.addSubview(popularMoviesCollectionView)
        view.addSubview(topRatedMoviesCollectionView)
        
        popularMoviesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popularMoviesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        popularMoviesCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        popularMoviesCollectionView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.height - self.navigationController!.navigationBar.frame.size.height - self.tabBarController!.tabBar.frame.size.height) / 2.3).isActive = true
        popularMoviesCollectionView.reloadData()
        
        secondTitleLabel.topAnchor.constraint(equalTo: popularMoviesCollectionView.bottomAnchor).isActive = true
        secondTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        
        topRatedMoviesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topRatedMoviesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topRatedMoviesCollectionView.topAnchor.constraint(equalTo: secondTitleLabel.bottomAnchor).isActive = true
        topRatedMoviesCollectionView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.height - self.navigationController!.navigationBar.frame.size.height - self.tabBarController!.tabBar.frame.size.height) / 2.3).isActive = true
        topRatedMoviesCollectionView.reloadData()
        
        checkLoggedIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        updatePopularMoviesInThisMonth()
        updateTopRatedMovies()
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
    }
    
}

extension MainViewController {

    private func checkLoggedIn() {
        if Auth.auth().currentUser == nil {
            
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                loginViewController.modalPresentationStyle = .fullScreen
                self.present(loginViewController, animated: true)
            }
        }
    }
    
    private func updatePopularMoviesInThisMonth() {
        movieAndRatingsCount.removeAll()
        ratingDatabaseService.getAllRatingsByLastMonth { (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let ratings):
                self.ratingsByLastMonth = ratings
                
                for rating in self.ratingsByLastMonth {
                    self.moviesDatabaseService.getMovieById(movieId: rating.movieId) { (result) in
                        switch result {
                        case .failure(let error):
                            print(error.localizedDescription)
                        case .success(let movie):
                            if self.movieAndRatingsCount[movie] == nil {
                                self.movieAndRatingsCount[movie] = 1
                                let movieAndRatingsCountSortedByCount = self.movieAndRatingsCount.sorted(by: { $0.value > $1.value})
                                var moviesForCollectionView = [Movie]()
                                for item in movieAndRatingsCountSortedByCount {
                                    moviesForCollectionView.append(item.key)
                                }
                                self.popularMoviesCollectionView.movies = Array(moviesForCollectionView.prefix(10))
                                self.popularMoviesCollectionView.reloadData()
                            } else {
                                self.movieAndRatingsCount[movie]! += 1
                                let movieAndRatingsCountSortedByCount = self.movieAndRatingsCount.sorted(by: { $0.value > $1.value})
                                var moviesForCollectionView = [Movie]()
                                for item in movieAndRatingsCountSortedByCount {
                                    moviesForCollectionView.append(item.key)
                                }
                                self.popularMoviesCollectionView.movies = Array(moviesForCollectionView.prefix(10))
                                self.popularMoviesCollectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func updateTopRatedMovies() {
        moviesDatabaseService.getAllMovies { result in
            switch result {
            case .success(let movies):
                for movie in movies {
                    self.ratingDatabaseService.getAverageRatingForMovie(movieId: movie.id) { (result) in
                        switch result {
                        case .failure(let error):
                            print(error.localizedDescription)
                        case .success(let ratingInfo):
                            self.moviesAndAvgRating[movie] = ratingInfo.rating
                            let moviesSortedByRating = self.moviesAndAvgRating.sorted(by: { $0.value > $1.value })
                            var moviesForCollectionView = [Movie]()
                            for item in moviesSortedByRating {
                                moviesForCollectionView.append(item.key)
                            }
                            self.topRatedMoviesCollectionView.movies = Array(moviesForCollectionView.prefix(10))
                            self.topRatedMoviesCollectionView.reloadData()
                        }
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
