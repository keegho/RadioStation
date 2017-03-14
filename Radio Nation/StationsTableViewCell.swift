//
//  StationsTableViewCell.swift
//  Radio Nation
//
//  Created by Kegham Karsian on 3/14/17.
//  Copyright © 2017 appologi. All rights reserved.
//

import UIKit

class StationsTableViewCell: UITableViewCell {

    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var numberOfListeners: UILabel!
    @IBOutlet var bgImage: UIImageView!
    @IBOutlet var countryFlagImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
