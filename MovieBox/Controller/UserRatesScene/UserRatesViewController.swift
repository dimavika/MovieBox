//
//  UserRatesViewController.swift
//  MovieBox
//
//  Created by Димас on 29.01.2021.
//

import UIKit
import FirebaseAuth

class UserRatesViewController: UIViewController {

    private let tintColor = UIColor(red: 237.0/255.0, green: 101.0/255.0, blue: 106.0/255.0, alpha: 1.0)
    
    let moviesDatabaseService = MovieDatabaseService.shared
    let reviewsDatabaseService = ReviewDatabaseService.shared
    let ratingDatabaseService = RatingDatabaseService.shared
    var ratedMovies = [
        ExpandableMovies(isExpanded: true, movies: [Movie]()),
        ExpandableMovies(isExpanded: false, movies: [Movie]()),
        ExpandableMovies(isExpanded: false, movies: [Movie]()),
        ExpandableMovies(isExpanded: false, movies: [Movie]()),
        ExpandableMovies(isExpanded: false, movies: [Movie]())
    ]
    let headerTitles = ["1/5", "2/5", "3/5", "4/5", "5/5"]
    
    @IBOutlet weak var ratedMoviesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: tintColor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25)]
        self.navigationItem.backButtonTitle = "My rates"
        self.tabBarController?.tabBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.backgroundImage = UIImage()
        self.tabBarController?.tabBar.clipsToBounds = true
        
        ratedMoviesTableView.delegate = self
        ratedMoviesTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        updateRatedMovies(sortType: true)
    }

}

extension UserRatesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ratedMovies.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !ratedMovies[section].isExpanded {
            return 0
        }
        
        return ratedMovies[section].movies.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 30))
        
        let button = UIButton()
        button.frame = CGRect.init(x: headerView.bounds.width - 50, y: 0, width: 30, height: 30)
        if ratedMovies[section].isExpanded {
            button.setImage(#imageLiteral(resourceName: "icons8-collapse-arrow-30"), for: .normal)
        } else {
            button.setImage(#imageLiteral(resourceName: "icons8-expand-arrow-50"), for: .normal)
        }
        button.tintColor = tintColor
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleOpenCloseSection), for: .touchUpInside)
        button.tag = section
        
        let label = UILabel()
        label.frame = CGRect.init(x: 30, y: 0, width: 50, height: 30)
        label.backgroundColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.text = headerTitles[section]
        
        headerView.addSubview(label)
        headerView.addSubview(button)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = ratedMovies[indexPath.section].movies[indexPath.row]
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
        
        let movie = ratedMovies[indexPath.section].movies[indexPath.row]
        
        cell.titleLabel.text = movie.title
        cell.genreLabel.text = movie.genre
        cell.yearLabel.text = movie.year
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

extension UserRatesViewController {
    
    @objc func handleOpenCloseSection(sender: UIButton) {
        let section = sender.tag
        
        var indexPaths = [IndexPath]()
        for row in ratedMovies[section].movies.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let isExpanded = ratedMovies[section].isExpanded
        ratedMovies[section].isExpanded = !isExpanded
        
        sender.setImage(isExpanded ? #imageLiteral(resourceName: "icons8-expand-arrow-50") : #imageLiteral(resourceName: "icons8-collapse-arrow-30"), for: .normal)
        
        if isExpanded {
            ratedMoviesTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            ratedMoviesTableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    private func updateRatedMovies(sortType: Bool) {
        for i in 0...4 {
            ratedMovies[i].movies.removeAll()
        }
        
        let user = Auth.auth().currentUser!
        ratingDatabaseService.getUserRatings(uid: user.uid) { (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let ratings):
                for rating in ratings {
                    self.moviesDatabaseService.getMovieById(movieId: rating.movieId) { (result) in
                        switch result {
                        case .failure(let error):
                            print(error.localizedDescription)
                        case.success(let movie):
                            for rating in ratings {
                                if movie.id == rating.movieId {
                                    self.ratedMovies[rating.value - 1].movies.append(movie)
                                    self.ratedMoviesTableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
