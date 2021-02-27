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
    
    @IBOutlet weak var titleLabel: UILabel!
    var moviesCollectionView = MoviesCollectionView()
    
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
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = tintColor
        
        view.addSubview(moviesCollectionView)
        
        moviesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        moviesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        moviesCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        moviesCollectionView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        moviesCollectionView.reloadData()
        
        checkLoggedIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        updatePopularMoviesInThisMonth()
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
            case .failure(_):
                print("gg")
            case .success(let ratings):
                self.ratingsByLastMonth = ratings
                
                for rating in self.ratingsByLastMonth {
                    self.moviesDatabaseService.getMovieById(movieId: rating.movieId) { (result) in
                        switch result {
                        case .failure(_):
                            print("gg")
                        case .success(let movie):
                            if self.movieAndRatingsCount[movie] == nil {
                                self.movieAndRatingsCount[movie] = 1
                                let movieAndRatingsCountSortedByCount = self.movieAndRatingsCount.sorted(by: { $0.value > $1.value})
                                var moviesForCollectionView = [Movie]()
                                for item in movieAndRatingsCountSortedByCount {
                                    moviesForCollectionView.append(item.key)
                                }
                                self.moviesCollectionView.movies = Array(moviesForCollectionView.prefix(10))
                                self.moviesCollectionView.reloadData()
                            } else {
                                self.movieAndRatingsCount[movie]! += 1
                                let movieAndRatingsCountSortedByCount = self.movieAndRatingsCount.sorted(by: { $0.value > $1.value})
                                var moviesForCollectionView = [Movie]()
                                for item in movieAndRatingsCountSortedByCount {
                                    moviesForCollectionView.append(item.key)
                                }
                                self.moviesCollectionView.movies = Array(moviesForCollectionView.prefix(10))
                                self.moviesCollectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
}
