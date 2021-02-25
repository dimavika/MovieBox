//
//  PopularMoviesCollectionViewCell.swift
//  MovieBox
//
//  Created by Димас on 15.02.2021.
//

import UIKit

class PopularMoviesCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "PopularMovieCell"
    
    let movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = #colorLiteral(red: 0.007841579616, green: 0.007844132371, blue: 0.007841020823, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let genreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(movieImageView)
        addSubview(titleLabel)
        addSubview(genreLabel)
        addSubview(ratingLabel)
        
        backgroundColor = .white
        
        // mainImageView constraints
        movieImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        movieImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        movieImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        movieImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 2/3).isActive = true
        
        // nameLabel constraints
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: movieImageView.bottomAnchor, constant: 12).isActive = true
        
        // smallDescriptionLabel constraints
        genreLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        genreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        genreLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2, constant: 10).isActive = true
        
        ratingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        ratingLabel.centerYAnchor.constraint(equalTo: genreLabel.centerYAnchor).isActive = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 5
        self.layer.shadowRadius = 9
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 5, height: 8)
        
        self.clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct Constants {
    static let leftDistanceToView: CGFloat = 40
    static let rightDistanceToView: CGFloat = 40
    static let galleryMinimumLineSpacing: CGFloat = 10
    static let galleryItemWidth = (UIScreen.main.bounds.width - Constants.leftDistanceToView - Constants.rightDistanceToView - (Constants.galleryMinimumLineSpacing / 2)) / 2
}