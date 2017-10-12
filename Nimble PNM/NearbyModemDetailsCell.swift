//
//  NearbyModemDetailsCell.swift
//  Nimble PNM
//
//  Created by KSolves on 12/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit


class NearbyModemDetailsCell: UITableViewCell {
    
    @IBOutlet weak var labelMacAddress: UILabel!
    
    @IBOutlet weak var imageViewSeverity: UIImageView!
    
    @IBOutlet weak var labelBW: UILabel!
    
    @IBOutlet weak var labelChannels: UILabel!
    
    @IBOutlet weak var labelMTC: UILabel!
    
    @IBOutlet weak var labelMRLevel: UILabel!
    
    @IBOutlet weak var labelDelay: UILabel!
    
    @IBOutlet weak var labelTDR: UILabel!
    
    @IBOutlet weak var labelVTDR: UILabel!
    
    @IBOutlet weak var labelSignature: UILabel!
    
    @IBOutlet weak var labelLatitude: UILabel!
    
    @IBOutlet weak var labelLongitude: UILabel!
    
    @IBOutlet weak var labelAddress: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        imageViewSeverity.contentMode = .scaleAspectFit
    }
    
    
}
