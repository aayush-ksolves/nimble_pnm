//
//  WODetailsImageCollectionViewCell.swift
//  Nimble PNM
//
//  Created by KSolves on 10/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class WODetailsImageCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var buttonCross: UIButton!
    @IBOutlet weak var imageViewPhoto: UIImageView!
    
    override func awakeFromNib() {
        buttonCross.addCornerRadius(radius: 10)
        buttonCross.addBorder(withColor: UIColor.black, withWidth: 1)
        
    }
    
}
