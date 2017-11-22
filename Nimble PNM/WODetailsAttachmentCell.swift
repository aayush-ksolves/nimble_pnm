//
//  WODetailsAttachmentCell.swift
//  Nimble PNM
//
//  Created by KSolves on 10/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class WODetailsAttachmentCell: UITableViewCell {
    
    @IBOutlet weak var labelNoAttachments: UILabel!
    @IBOutlet weak var buttonAddImage: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        buttonAddImage.contentMode = .scaleAspectFit
    }
    
}
