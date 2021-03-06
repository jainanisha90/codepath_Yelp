//
//  SwitchCell.swift
//  Yelp
//
//  Created by Anisha Jain on 4/7/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    @objc optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    @IBOutlet weak var cellContainer: UIView!
    
    var filter: (String?, Bool)? = nil {
        didSet {
            switchLabel.text = filter?.0
            onSwitch.isOn = (filter?.1) ?? false
        }
    }
    
    weak var delegate: SwitchCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        cellContainer.layer.borderWidth = 1
        cellContainer.layer.borderColor = UIColor.gray.cgColor
        cellContainer.layer.cornerRadius = 4
        //contentView.layoutMargins = UIEdgeInsets.init(top: 20, left: 20, bottom: 4, right: 4)
        onSwitch.addTarget(self, action: #selector(onSwitchValueChanged(_:)), for: UIControlEvents.valueChanged)
    }

    func onSwitchValueChanged(_ sender: UISwitch) {
        print("Switch value changed: ", sender.isOn)
        delegate?.switchCell?(switchCell: self, didChangeValue: sender.isOn)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
