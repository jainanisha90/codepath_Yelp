//
//  DistanceCell.swift
//  Yelp
//
//  Created by Anisha Jain on 4/9/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class DistanceCell: UITableViewCell {

    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var filter: (String?, Bool)? = nil {
        didSet {
            distanceLabel.text = filter?.0
        }
    }
    
    //weak var delegate: DistanceCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        cellContainer.layer.borderWidth = 1
        cellContainer.layer.borderColor = UIColor.gray.cgColor
        cellContainer.layer.cornerRadius = 4
    }

//    func onRadioValueChanged(_ sender: UIButton) {
//        print("radio value changed: ", sender.isSelected)
//        if(!sender.isSelected) {
//            sender.isSelected = !sender.isSelected
//            delegate?.distanceCell?(distanceCell: self, didChangeValue: sender.isSelected)
//        }
//    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
