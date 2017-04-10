//
//  RadioCell.swift
//  Yelp
//
//  Created by Anisha Jain on 4/9/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol RadioCellDelegate {
    @objc optional func radioCell(radioCell: RadioCell, didChangeValue value: Bool)
}

class RadioCell: UITableViewCell {

    @IBOutlet weak var radioLabel: UILabel!
    @IBOutlet weak var onButton: UIButton!
    @IBOutlet weak var cellContainer: UIView!
    
    var filter: (String?, Bool)? = nil {
        didSet {
            radioLabel.text = filter?.0
            onButton.isSelected = (filter?.1) ?? false
        }
    }
    
    weak var delegate: RadioCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellContainer.layer.borderWidth = 1
        cellContainer.layer.borderColor = UIColor.gray.cgColor
        cellContainer.layer.cornerRadius = 4
        
        onButton.setImage(#imageLiteral(resourceName: "checked"), for: UIControlState.selected)
        onButton.setImage(#imageLiteral(resourceName: "unchecked"), for: UIControlState.normal)
        onButton.addTarget(self, action: #selector(onRadioValueChanged(_:)), for: UIControlEvents.touchUpInside)
    }

    func onRadioValueChanged(_ sender: UIButton) {
        print("radio value changed: ", sender.isSelected)
        if(!sender.isSelected) {
            sender.isSelected = !sender.isSelected
            delegate?.radioCell?(radioCell: self, didChangeValue: sender.isSelected)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
