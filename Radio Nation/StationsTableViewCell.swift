//
//  StationsTableViewCell.swift
//  Radio Nation
//
//  Created by Kegham Karsian on 3/14/17.
//  Copyright © 2017 appologi. All rights reserved.
//

import UIKit

class StationsTableViewCell: UITableViewCell {

    @IBOutlet var heartIcon: UIImageView!
    @IBOutlet var bitRateLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var numberOfListeners: UILabel!
    @IBOutlet var bgImage: UIImageView!
    @IBOutlet var countryFlagImageView: UIImageView!

    @IBOutlet var backgroundCellView: UIView!
    
//    var station: Radiostation! {
//        didSet {
//                self.updateUIView()
//                }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
 
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func updateUIView() {
//        
//        backgroundCellView.backgroundColor = UIColor(red: 47/255, green: 46/255, blue: 44/255, alpha: 1.0)
//        backgroundCellView.layer.masksToBounds = false
//        backgroundCellView.layer.cornerRadius = 3
//        backgroundCellView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
//        backgroundCellView.layer.shadowOffset = CGSize(width: 0, height: 0)
//        backgroundCellView.layer.shadowOpacity = 0.8
//    }

}
