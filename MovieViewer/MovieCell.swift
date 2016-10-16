//
//  MovieCell.swift
//  MovieViewer
//
//  Created by Zekun Wang on 9/25/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet var scheduleImageView: UIImageView!
    @IBOutlet var releaseDateLabel: UILabel!
    @IBOutlet var starImageView: UIImageView!
    @IBOutlet var voteAverageLabel: UILabel!
    
    var movie: Movie! {
        didSet {
            if let posterPath = movie.posterPath {
                let posterURL = URL(string: AppConstants.imageUrlW342 + posterPath)
                let posterURLRequest = URLRequest(url: posterURL!)
                posterImageView.setImageWith(posterURLRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        self.posterImageView.alpha = 0
                        self.posterImageView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            self.posterImageView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        self.posterImageView.image = image
                    }
                    }, failure: nil)
            }
            
            titleLabel.text = movie.title
            overviewLabel.text = movie.overview
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd yyyy"
            releaseDateLabel.text = dateFormatter.string(from: movie.releaseDate)
            voteAverageLabel.text = String(movie.voteAverage)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Change icon color of image view
        scheduleImageView.image = scheduleImageView.image?.withRenderingMode(.alwaysTemplate)
        scheduleImageView.tintColor = UIColor.gray
        starImageView.image = starImageView.image?.withRenderingMode(.alwaysTemplate)
        starImageView.tintColor = UIColor.gray

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
