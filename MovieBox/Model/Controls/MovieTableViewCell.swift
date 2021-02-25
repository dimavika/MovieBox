//
//  MovieTableViewCell.swift
//  MovieBox
//
//  Created by Димас on 09.11.2020.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        yearLabel.textColor = .black
        yearLabel.font = UIFont.boldSystemFont(ofSize: 17)
        genreLabel.textColor = .gray
        genreLabel.font = UIFont.boldSystemFont(ofSize: 17)
        ratingLabel.textColor = .black
        ratingLabel.font = UIFont.boldSystemFont(ofSize: 19)
        ratingCountLabel.textColor = .gray
        ratingCountLabel.font = UIFont.boldSystemFont(ofSize: 17)
        countryLabel.textColor = .black
        countryLabel.font = UIFont.boldSystemFont(ofSize: 17)
        movieImageView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
