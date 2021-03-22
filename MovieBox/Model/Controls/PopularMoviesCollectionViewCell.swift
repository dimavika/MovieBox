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
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 2
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
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(movieImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(genreLabel)
        contentView.addSubview(ratingLabel)
        
        backgroundColor = .white
        
        movieImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        movieImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        movieImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        movieImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 2/3.2).isActive = true
        
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        titleLabel.topAnchor.constraint(equalTo: movieImageView.bottomAnchor, constant: 5).isActive = true
        
        genreLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        genreLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7).isActive = true
        genreLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2, constant: 10).isActive = true
        
        ratingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        ratingLabel.centerYAnchor.constraint(equalTo: genreLabel.centerYAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 5
        self.layer.shadowRadius = 1.7
        layer.shadowOpacity = 0.45
        layer.shadowOffset = CGSize(width: 0, height: 1.75)
        
        self.clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


