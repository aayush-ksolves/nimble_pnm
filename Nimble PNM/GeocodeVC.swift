//
//  GeocodeVC.swift
//  Nimble PNM
//
//  Created by ksolves on 11/09/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class GeocodeVC: BaseVC, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, BarCodeScannerDelegate {
    @IBOutlet weak var labelHeading: UILabel!

    @IBOutlet weak var textFieldMacAddress: UITextField!
    @IBOutlet weak var tableViewGeocode: UITableView!
    let headerLocation = "Location"
    let headerAddress = "Address"
    let headerContact = "Contact"
    
    var bundleAddress  = AddressDS()
    var bundleContact = ContactDS()
    var bundleLocation = LocationDS()
    
    let imageScanBarcode = UIImage(named: "barcode")
    
    let barcodeScanner  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BarCodeScannerVC") as! BarCodeScannerVC
    
    let placeholderAddressStreet :String = "Street Address"
    let placeholderAddressCity :String = "City"
    let placeholderAddressState :String = "State"
    let placeholderAddressCountry :String = "Country"
    let placeholderAddressZip :String = "Zipcode"
    
    let placeholderContactFirst :String = "First Name"
    let placeholderContactLast :String = "Last Name"
    let placeholderContactPhone :String = "Phone Number"
    let placeholderContactAccount :String = "Account Number"
    let placeholderContactNode :String = "Node Name"
    
    let illusionForTextfields : CGFloat = 8.0
    
    @IBOutlet weak var btnOutletSave: UIButton!
    
    @IBAction func btnActionSave(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUIComponents()

        
        
        
    }
    
    func configureUIComponents(){
        
        self.labelHeading.text = TXT_LBL_GEOCODING_HEAD
        
        self.textFieldMacAddress.placeIllusion(ofPixels: illusionForTextfields)
        //Preparing Button To Insert in the Right Of Text field
        let buttonScanBarcode = UIButton(frame: CGRect(x: 0, y: 8, width: 40, height: 24));
        buttonScanBarcode.addTarget(self, action: #selector(buttonScanBarcodePressed(_:)), for: .touchUpInside)
        buttonScanBarcode.setImage(imageScanBarcode, for: .normal)
        buttonScanBarcode.imageView?.contentMode = .scaleAspectFit
        
        self.textFieldMacAddress.rightViewMode = .always
        self.textFieldMacAddress.rightView = buttonScanBarcode
        
        
        //Regitering Nibs
        let nibNameForAddress = UINib(nibName: "AddressGeocodeCell", bundle: nil)
        let nibNameForLocation = UINib(nibName: "LocationGeocodeCell", bundle: nil)
        let nibNameForContact = UINib(nibName: "ContactGeocodeCell", bundle: nil)
        
        self.tableViewGeocode.register(nibNameForAddress, forCellReuseIdentifier: "addresscell")
        self.tableViewGeocode.register(nibNameForLocation, forCellReuseIdentifier: "locationcell")
        self.tableViewGeocode.register(nibNameForContact, forCellReuseIdentifier: "contactcell")
        
    }
    
    func scanningCompleteWithDataString(dataString: String) {
        self.textFieldMacAddress.text = dataString
        
    }
    
    
    func scanningFailedDueToReason(reasonCode: Int!) {
        print("Scanning Failed Due To Reason code \(reasonCode!)")
    }
    
    func buttonScanBarcodePressed(_ sender: UIButton){
        barcodeScanner.delegate = self
        self.present(barcodeScanner, animated: true, completion: nil)
    }

    
    
    //MARK: UITable View Delegates and Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("ViewHeaderViewTableGeocode", owner: self, options: nil)?[0] as! HeaderViewTableGeocode
        headerView.backgroundColor = COLOR_WHITE_AS_GREY

        
        if section == 0{
            headerView.labelTitleInHeader.text = headerLocation
            
        }else if section == 1{
            headerView.labelTitleInHeader.text = headerAddress
            
        }else if section == 2{
            headerView.labelTitleInHeader.text = headerContact
            
        }else{
            return UIView()
        }
        
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2{
            return 4.0
            
        }else{
            return 15.0

        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        if section == 0{
            return 40.0
            
        }else if section == 1{
            return 120.0
            
        }else if section == 2{
            return 120.0
            
        }else{
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.addShadow(withColor: COLOR_BORDER_GRAY_MODIFIED)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        
        if section == 0{
            let cell = tableViewGeocode.dequeueReusableCell(withIdentifier: "locationcell") as! LocationGeocodeCell
            cell.btnOutletModify.addTarget(self, action: #selector(btnModifyLatLngPressed(_:)), for: .touchUpInside)
            cell.labelLatLong.backgroundColor = COLOR_NONE
            
            
            
            return cell
            
        }else if section == 1{
            let cell = tableViewGeocode.dequeueReusableCell(withIdentifier: "addresscell") as! AddressGeocodeCell
            cell.textfieldAddressCity.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldAddressState.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldAddressStreet.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldAddressCountry.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldAddressZipcode.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            
            cell.textfieldAddressCity.placeholder = placeholderAddressCity
            cell.textfieldAddressState.placeholder = placeholderAddressState
            cell.textfieldAddressStreet.placeholder = placeholderAddressStreet
            cell.textfieldAddressCountry.placeholder = placeholderAddressCountry
            cell.textfieldAddressZipcode.placeholder = placeholderAddressZip
            
            cell.textfieldAddressCity.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldAddressState.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldAddressStreet.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldAddressCountry.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldAddressZipcode.placeIllusion(ofPixels: illusionForTextfields)
            
            for eachView in cell.subviews{
                if eachView.isKind(of: UITextField.self){
                    let textfield = (eachView as! UITextField)
                    textfield.placeIllusion(ofPixels: illusionForTextfields)
                    textfield.delegate = self
                    
                }
            }
            

            
            
            
            return cell
            
        }else if section == 2{
            let cell = tableViewGeocode.dequeueReusableCell(withIdentifier: "contactcell") as! ContactGeocodeCell
            cell.textfieldContactPhone.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldContactLastName.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldContactNodeName.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldContactFirstName.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldContactAccountNumber.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            
            cell.textfieldContactPhone.placeholder = placeholderContactPhone
            cell.textfieldContactLastName.placeholder = placeholderContactLast
            cell.textfieldContactNodeName.placeholder = placeholderContactNode
            cell.textfieldContactFirstName.placeholder = placeholderContactFirst
            cell.textfieldContactAccountNumber.placeholder = placeholderContactAccount
            
            cell.textfieldContactPhone.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldContactLastName.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldContactNodeName.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldContactFirstName.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldContactAccountNumber.placeIllusion(ofPixels: illusionForTextfields)
            
            return cell
            
        }else{
            return UITableViewCell()
        }
    }
    
    func btnModifyLatLngPressed(_ sender:UIButton){
        self.performSegue(withIdentifier: "segue-to-modify-lat-lng", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue-to-modify-lat-lng"{
            let destinationController = segue.destination as! MappingInGeocodeVC
            destinationController.currentSelectedlatitude = 28.35
            destinationController.currrentSelectedLongitude = 77.3
            
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    
    
    
}





struct AddressDS{
    var streetAddress = ""
    var city = ""
    var state = ""
    var country = ""
    var zipcode = ""
    
    
}

struct ContactDS{
    var firstName = ""
    var lastName = ""
    var phoneNumber = ""
    var accountNumber = ""
    var nodeName = ""
    
}


struct LocationDS{
    var latitude = ""
    var longitude = ""
}






