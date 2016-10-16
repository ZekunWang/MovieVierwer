//
//  personCollectionViewCell.swift
//  MovieViewer
//
//  Created by Zekun Wang on 10/15/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit

class PersonCollectionViewCell: UICollectionViewCell {
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var charDeptLabel: UILabel!
    
    var isCrew: Bool = false
    var person: Person! {
        didSet{
            let profileURL = URL(string: AppConstants.imageUrlW342 + person.profilePath)
            let placeHolder = UIImage(named: "default_profile_image")
            profileImageView.setImageWith(profileURL!, placeholderImage: placeHolder)
            profileImageView.layer.cornerRadius = 40

            nameLabel.text = person.name
            charDeptLabel.text = isCrew ? person.job : person.character
        }
    }
}
