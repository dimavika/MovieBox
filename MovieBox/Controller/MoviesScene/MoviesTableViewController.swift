//
//  MoviesTableViewController.swift
//  MovieBox
//
//  Created by Димас on 02.11.2020.
//

import UIKit

class MoviesTableViewController: UITableViewController {
    
    let moviesDatabaseService = MovieDatabaseService.shared
    let reviewsDatabaseService = ReviewDatabaseService.shared
    var movies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        updateMovies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        updateMovies()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        
        let movie = movies[indexPath.row]
        
        cell.titleLabel.text = movie.title
        cell.genreLabel.text = movie.genre

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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movieToDelete = movies[indexPath.row]
            moviesDatabaseService.deleteMovie(id: movieToDelete.id, num: indexPath.row) { (result) in
                switch result {
                case .failure(let error):
                    print("Failed to delete movie cause: \(error)")
                case .success(let successMessage):
                    self.movies.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    print(successMessage)
                }
            }
            
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}

extension MoviesTableViewController {
    
    func updateMovies() {
        moviesDatabaseService.getAllMovies { result in
            switch result {
            case .success(let movies):
                self.movies = movies
                self.tableView.reloadData()
            case .failure(let error):
                print("Cannot get movies cause: \(error)")
            }
        }
    }
}
