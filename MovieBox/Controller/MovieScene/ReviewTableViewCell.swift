//
//  ReviewTableViewCell.swift
//  MovieBox
//
//  Created by Димас on 30.12.2020.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    private let usernameColor = UIColor(red: 237.0/255.0, green: 101.0/255.0, blue: 106.0/255.0, alpha: 1.0)
    

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var reviewTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.frame.size.width / 2
        
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        usernameLabel.textColor = usernameColor
        reviewTextLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        reviewTextLabel.numberOfLines = 0
        dateLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        dateLabel.textColor = .gray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
