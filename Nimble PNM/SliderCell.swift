//
//  SliderCell.swift
//  Nimble PNM
//
//  Created by ksolves on 24/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class SliderCell: UITableViewCell {

    @IBOutlet weak var sliderOutlet: UISlider!
    @IBOutlet weak var labelSliderTitle: UILabel!
    @IBOutlet weak var labelSliderCurrentValue: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
