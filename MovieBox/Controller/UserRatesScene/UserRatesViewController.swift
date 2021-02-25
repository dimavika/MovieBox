//
//  UserRatesViewController.swift
//  MovieBox
//
//  Created by Димас on 29.01.2021.
//

import UIKit
import FirebaseAuth

class UserRatesViewController: UIViewController {

    let moviesDatabaseService = MovieDatabaseService.shared
    let reviewsDatabaseService = ReviewDatabaseService.shared
    let ratingDatabaseService = RatingDatabaseService.shared
    var ratedMovies = [Movie]()
    var moviesNew = [
        [Movie](),
        [Movie](),
        [Movie](),
        [Movie](),
        [Movie]()
    ]
    let headerTitles = ["1/5", "2/5", "3/5", "4/5", "5/5"]
    
    @IBOutlet weak var ratedMoviesTableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.backgroundImage = UIImage()
        self.tabBarController?.tabBar.clipsToBounds = true
        
        ratedMoviesTableView.delegate = self
        ratedMoviesTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
//        switch sortSegmentedControl.selectedSegmentIndex {
//        case 0:
//            updateRatedMovies(sortType: true)
//        case 1:
//            updateRatedMovies(sortType: false)
//        default:
//            updateRatedMovies(sortType: true)
//        }
        updateRatedMovies(sortType: true)
    }
    
    @IBAction func sortSegmControlValueChanged(_ sender: UISegmentedControl) {
//        switch sortSegmentedControl.selectedSegmentIndex {
//        case 0:
//            updateRatedMovies(sortType: true)
//        case 1:
//            updateRatedMovies(sortType: false)
//        default:
//            updateRatedMovies(sortType: true)
//        }
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

extension UserRatesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return ratedMovies.count
        return moviesNew[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitles[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = ratedMovies[indexPath.row]
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
        
//        let movie = ratedMovies[indexPath.row]
        let movie = moviesNew[indexPath.section][indexPath.row]
        
        cell.titleLabel.text = movie.title
        cell.genreLabel.text = movie.genre
        cell.yearLabel.text = movie.year
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

extension UserRatesViewController {
    //MARK: TODO SMTH WRONG!
    private func updateRatedMovies(sortType: Bool) {
        ratedMovies.removeAll()
        for i in 0...4 {
            moviesNew[i].removeAll()
        }
        let user = Auth.auth().currentUser!
        ratingDatabaseService.getUserRatings(uid: user.uid) { (result) in
            switch result {
            case .failure(let error):
                print("Can't get user ratings cause: \(error)")
            case .success(let ratings):
//                if !ratings.isEmpty {
//                    if sortType {
//                        ratings.sort(by: { $0.value < $1.value })
//                    } else {
//                        ratings.sort(by: { $0.date.seconds < $1.date.seconds})
//                    }
                    
                    for rating in ratings {
                        self.moviesDatabaseService.getMovieById(movieId: rating.movieId) { (result) in
                            switch result {
                            case .failure(let error):
                                print("\(error)")
                            case.success(let movie):
                                for rating in ratings {
                                    if movie.id == rating.movieId {
                                        self.moviesNew[rating.value - 1].append(movie)
                                        self.ratedMoviesTableView.reloadData()
                                    }
                                }
//                                self.ratedMovies.append(movie)
                                
                            }
                        }
                    }
//                }
            }
        }
    }
}
