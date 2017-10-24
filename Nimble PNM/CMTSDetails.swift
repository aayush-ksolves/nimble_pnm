//
//  CMTSDetails.swift
//  Nimble PNM
//
//  Created by KSolves on 23/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit


class CMTSDetails : UITableViewCell {
    
    @IBOutlet weak var labelSideStrip: UILabel!
    @IBOutlet weak var labelMAC: UILabel!
    @IBOutlet weak var labelUpstream: UILabel!
    @IBOutlet weak var labelImpairment: UILabel!
    @IBOutlet weak var buttonStatistics: UIButton!
    @IBOutlet weak var labelDate: UILabel!
    
    override func awakeFromNib() {
        
        buttonStatistics.imageView?.contentMode = .scaleAspectFit
    }
    
}
