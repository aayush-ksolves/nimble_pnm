//
//  SwitchCell.swift
//  Nimble PNM
//
//  Created by ksolves on 24/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var switchOutlet: UISwitch!
}
