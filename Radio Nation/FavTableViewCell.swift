//
//  FavTableViewCell.swift
//  Radio Nation
//
//  Created by Kegham Karsian on 3/13/17.
//  Copyright © 2017 appologi. All rights reserved.
//

import UIKit

class FavTableViewCell: UITableViewCell {

    @IBOutlet var flagImageView: UIImageView!
    @IBOutlet var countryCodeLabel: UILabel!
    @IBOutlet var stationCategoryLabel: UILabel!
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var stationLabelName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
