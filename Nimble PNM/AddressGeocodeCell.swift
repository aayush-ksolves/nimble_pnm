//
//  AddressGeocodeCell.swift
//  Nimble PNM
//
//  Created by ksolves on 11/09/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class AddressGeocodeCell: UITableViewCell {

    
    @IBOutlet weak var textfieldAddressStreet: UITextField!
    
    
    @IBOutlet weak var textfieldAddressCity: UITextField!
    
    
    @IBOutlet weak var textfieldAddressState: UITextField!
    
    
    @IBOutlet weak var textfieldAddressCountry: UITextField!
    
    
    @IBOutlet weak var textfieldAddressZipcode: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
