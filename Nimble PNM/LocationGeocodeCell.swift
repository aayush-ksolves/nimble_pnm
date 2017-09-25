//
//  LocationGeocodeCell.swift
//  Nimble PNM
//
//  Created by ksolves on 11/09/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class LocationGeocodeCell: UITableViewCell {

    @IBOutlet weak var btnOutletModify: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var labelLatLong: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
