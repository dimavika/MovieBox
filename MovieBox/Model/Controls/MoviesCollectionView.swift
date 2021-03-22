//
//  MoviesCollectionView.swift
//  MovieBox
//
//  Created by Димас on 16.02.2021.
//

import UIKit
import Kingfisher

class MoviesCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let reviewsDatabaseService = ReviewDatabaseService.shared
    let ratingDatabaseService = RatingDatabaseService.shared
    var movies = [Movie]()
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        register(PopularMoviesCollectionViewCell.self, forCellWithReuseIdentifier: PopularMoviesCollectionViewCell.reuseId)
        
        delegate = self
        dataSource = self
        
        translatesAutoresizingMaskIntoConstraints = false
        layout.minimumLineSpacing = Constants.galleryMinimumLineSpacing
        contentInset = UIEdgeInsets(top: 0, left: Constants.leftDistanceToView, bottom: 0, right: Constants.rightDistanceToView)
        
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularMoviesCollectionViewCell.reuseId, for: indexPath) as! PopularMoviesCollectionViewCell
        let movie = movies[indexPath.row]
        cell.movieImageView.kf.setImage(with: URL(string: movies[indexPath.row].imageUrl))
        if cell.movieImageView.image == nil {
            cell.movieImageView.image = UIImage(named: "def-movie-icon")
        }
        cell.titleLabel.text = movie.title
        cell.genreLabel.text = movie.genre
        ratingDatabaseService.getAverageRatingForMovie(movieId: movie.id) { (result) in
            switch result {
            case .failure(let error):
                cell.ratingLabel.text = "-"
                print("Cannot get average rating of movie named: \(movie.title) cause: \(error)")
            case .success(let ratingInfo):
                if ratingInfo.rating.isEqual(to: 0.0) {
                    cell.ratingLabel.textColor = .black
                    cell.ratingLabel.text = "-"
                } else {
                    if ratingInfo.rating <= 2.0 {
                        cell.ratingLabel.textColor = .red
                    } else if ratingInfo.rating < 4.0 {
                        cell.ratingLabel.textColor = .gray
                    } else {
                        cell.ratingLabel.textColor = .systemGreen
                    }
                    cell.ratingLabel.text = String(format: "%.1f", ratingInfo.rating)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = movies[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath) as! PopularMoviesCollectionViewCell

        let vc = findViewController()
        if let viewController = vc!.storyboard?.instantiateViewController(identifier: "MovieViewController") as? MovieViewController {
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
            vc!.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.galleryItemWidth, height: frame.height * 0.9)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
