//
//  MovieTableViewCell.swift
//  MovieViewer
//
//  Created by Zekun Wang on 10/14/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initViews()
    }
    
    func initViews() {
//        backgroundColor = UIColor.clear
//        selectedBackgroundView = UIView(frame: frame)
//        selectedBackgroundView?.backgroundColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.8)
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        let fontSize: CGFloat = selected ? 34.0 : 17.0
//        self.textLabel?.font = self.textLabel?.font.withSize(fontSize)
//    }
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
}
