//
//  WO5LineCell.swift
//  Nimble PNM
//
//  Created by ksolves on 23/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class WO5LineCell: UITableViewCell {

    @IBOutlet weak var labelSideBar: UILabel!
    @IBOutlet weak var labelAssignedTo: UILabel!
    @IBOutlet weak var labelAssignedDate: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var labelOrderId: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
