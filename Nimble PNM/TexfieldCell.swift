//
//  TexfieldCell.swift
//  Nimble PNM
//
//  Created by ksolves on 06/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class TextfieldCell: UITableViewCell {
    @IBOutlet weak var textfieldMain: UITextField!

    @IBOutlet weak var textfieldContent: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
