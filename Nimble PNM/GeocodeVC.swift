//
//  GeocodeVC.swift
//  Nimble PNM
//
//  Created by ksolves on 11/09/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit
import CoreLocation

class GeocodeVC: BaseVC, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, BarCodeScannerDelegate {
    @IBOutlet weak var labelHeading: UILabel!

    var exposedMacAddress : String = ""
    let initialLoaderText = "Getting your location ..."
    
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
    let illusionForBalancingLeftViewTextfields : CGFloat = 40.0
    
    @IBOutlet weak var btnOutletSave: UIButton!
    
    let TAG_CONTACT_FIRST = 2001
    let TAG_CONTACT_LAST = 2002
    let TAG_CONTACT_NODE_NAME = 2003
    let TAG_CONTACT_PHONE = 2004
    let TAG_CONTACT_ACCOUNT = 2005
    
    let TAG_ADDRESS_CITY = 1001
    let TAG_ADDRESS_STATE = 1002
    let TAG_ADDRESS_STREET = 1003
    let TAG_ADDRESS_COUNTRY = 1004
    let TAG_ADDRESS_ZIP = 1005
    
    
    var disableLatLngSection = false;
    var disableAddressContactSection = false;
    
    var bundleDataLatLong = LocationDS()
    var bundleDataAddress = AddressDS()
    var bundleDataContact = ContactDS()
    
    var currentLocation = CLLocationCoordinate2D()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APP_DELEGATE.presentLoader(withMessage: initialLoaderText)
        self.startHandlingLocationUpdate( isCrucial: true)
        self.configureUIComponents()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableViewGeocode.reloadData()
    }
    
    func configureUIComponents(){
        
        self.labelHeading.text = TXT_LBL_GEOCODING_HEAD
        
        self.textFieldMacAddress.placeIllusion(ofPixels: illusionForBalancingLeftViewTextfields)
        //Preparing Button To Insert in the Right Of Text field
        let buttonScanBarcode = UIButton(frame: CGRect(x: 0, y: 8, width: 40, height: 24));
        buttonScanBarcode.addTarget(self, action: #selector(buttonScanBarcodePressed(_:)), for: .touchUpInside)
        buttonScanBarcode.setImage(imageScanBarcode, for: .normal)
        buttonScanBarcode.imageView?.contentMode = .scaleAspectFit
        
        self.textFieldMacAddress.rightViewMode = .always
        self.textFieldMacAddress.rightView = buttonScanBarcode
        
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
//        tableViewGeocode.addSubview(refreshControl)
        
        //Regitering Nibs
        let nibNameForAddress = UINib(nibName: "AddressGeocodeCell", bundle: nil)
        let nibNameForLocation = UINib(nibName: "LocationGeocodeCell", bundle: nil)
        let nibNameForContact = UINib(nibName: "ContactGeocodeCell", bundle: nil)
        
        self.tableViewGeocode.register(nibNameForAddress, forCellReuseIdentifier: "addresscell")
        self.tableViewGeocode.register(nibNameForLocation, forCellReuseIdentifier: "locationcell")
        self.tableViewGeocode.register(nibNameForContact, forCellReuseIdentifier: "contactcell")
        
        if self.exposedMacAddress != ""{
            self.textFieldMacAddress.text = exposedMacAddress
        }
        
    }
    
//    func pullToRefresh(_ refreshControl: UIRefreshControl){
//        
//        getCurrentLocation()
//        refreshControl.endRefreshing()
//    }
    
    func getCurrentLocation() {
        
        if APP_DELEGATE.locationHelper.currentLocation != nil {
            
            currentLocation = APP_DELEGATE.locationHelper.currentLocation!
            
            bundleLocation.latitude = currentLocation.latitude
            bundleLocation.longitude = currentLocation.longitude
            
            if bundleLocation.latitude != 0  && bundleLocation.longitude != 0{
                APP_DELEGATE.hideLoader()
                self.stopHandlingUpdates()
            }
            
            tableViewGeocode.reloadData()
            
        }else {
            getCurrentLocation()
        }
        
    }
    
    func scanningCompleteWithDataString(dataString: String) {
        self.textFieldMacAddress.text = dataString
    }
    
    
    func scanningFailedDueToReason(reasonCode: Int!) {
        print("Scanning Failed Due To Reason code \(reasonCode!)")
    }
    
    @objc func buttonScanBarcodePressed(_ sender: UIButton){
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
            
            if disableLatLngSection{
                cell.isUserInteractionEnabled = false
            }else{
                cell.isUserInteractionEnabled = true
            }
            
            //Setting Value
            if bundleLocation.latitude != 0  && bundleLocation.longitude != 0{
                cell.labelLatLong.text = "\(bundleLocation.latitude),\(bundleLocation.longitude)"
            }else{
                cell.labelLatLong.text = ""
                getCurrentLocation()
            }
            
            return cell
            
        }else if section == 1{
            let cell = tableViewGeocode.dequeueReusableCell(withIdentifier: "addresscell") as! AddressGeocodeCell
            
            cell.textfieldAddressCity.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldAddressState.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldAddressStreet.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldAddressCountry.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldAddressZipcode.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            
            cell.textfieldAddressCity.delegate = self
            cell.textfieldAddressState.delegate = self
            cell.textfieldAddressStreet.delegate = self
            cell.textfieldAddressCountry.delegate = self
            cell.textfieldAddressZipcode.delegate = self
            
            cell.textfieldAddressCity.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldAddressState.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldAddressStreet.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldAddressCountry.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldAddressZipcode.placeIllusion(ofPixels: illusionForTextfields)
            
            cell.textfieldAddressCity.tag = TAG_ADDRESS_CITY
            cell.textfieldAddressState.tag = TAG_ADDRESS_STATE
            cell.textfieldAddressStreet.tag = TAG_ADDRESS_STREET
            cell.textfieldAddressCountry.tag = TAG_ADDRESS_COUNTRY
            cell.textfieldAddressZipcode.tag = TAG_ADDRESS_ZIP
            
            cell.textfieldAddressCity.placeholder = placeholderAddressCity
            cell.textfieldAddressState.placeholder = placeholderAddressState
            cell.textfieldAddressStreet.placeholder = placeholderAddressStreet
            cell.textfieldAddressCountry.placeholder = placeholderAddressCountry
            cell.textfieldAddressZipcode.placeholder = placeholderAddressZip
            
            if disableAddressContactSection{
                cell.isUserInteractionEnabled = false
            }else{
                cell.isUserInteractionEnabled = true
            }
            
            
            //Setting Value
            cell.textfieldAddressStreet.text = bundleAddress.streetAddress
            cell.textfieldAddressCity.text = bundleAddress.city
            cell.textfieldAddressState.text = bundleAddress.state
            cell.textfieldAddressCountry.text = bundleAddress.country
            cell.textfieldAddressZipcode.text = bundleAddress.zipcode
            

            
            return cell
            
        }else if section == 2{
            let cell = tableViewGeocode.dequeueReusableCell(withIdentifier: "contactcell") as! ContactGeocodeCell
            
            cell.textfieldContactPhone.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldContactLastName.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldContactNodeName.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldContactFirstName.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            cell.textfieldContactAccountNumber.backgroundColor = COLOR_WHITE_AS_GREY_LIGHT
            
            cell.textfieldContactPhone.delegate = self
            cell.textfieldContactLastName.delegate = self
            cell.textfieldContactNodeName.delegate = self
            cell.textfieldContactFirstName.delegate = self
            cell.textfieldContactAccountNumber.delegate = self
            
            cell.textfieldContactPhone.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldContactLastName.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldContactNodeName.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldContactFirstName.placeIllusion(ofPixels: illusionForTextfields)
            cell.textfieldContactAccountNumber.placeIllusion(ofPixels: illusionForTextfields)
            
            cell.textfieldContactPhone.tag = TAG_CONTACT_PHONE
            cell.textfieldContactLastName.tag = TAG_CONTACT_LAST
            cell.textfieldContactNodeName.tag = TAG_CONTACT_NODE_NAME
            cell.textfieldContactFirstName.tag = TAG_CONTACT_FIRST
            cell.textfieldContactAccountNumber.tag = TAG_CONTACT_ACCOUNT
            
            cell.textfieldContactPhone.placeholder = placeholderContactPhone
            cell.textfieldContactLastName.placeholder = placeholderContactLast
            cell.textfieldContactNodeName.placeholder = placeholderContactNode
            cell.textfieldContactFirstName.placeholder = placeholderContactFirst
            cell.textfieldContactAccountNumber.placeholder = placeholderContactAccount
            
            if disableAddressContactSection{
                cell.isUserInteractionEnabled = false
            }else{
                cell.isUserInteractionEnabled = true
            }
            
            //Setting Value
            cell.textfieldContactPhone.text = bundleContact.phoneNumber
            cell.textfieldContactLastName.text = bundleContact.lastName
            cell.textfieldContactNodeName.text = bundleContact.nodeName
            cell.textfieldContactFirstName.text = bundleContact.firstName
            cell.textfieldContactAccountNumber.text = bundleContact.accountNumber
            
            return cell
            
        }else{
            return UITableViewCell()
        }
    }
    @objc  
    func btnModifyLatLngPressed(_ sender:UIButton){
        self.performSegue(withIdentifier: "segue-to-modify-lat-lng", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue-to-modify-lat-lng"{
            let destinationController = segue.destination as! MappingInGeocodeVC
            destinationController.currentSelectedlatitude = bundleLocation.latitude
            destinationController.currrentSelectedLongitude = bundleLocation.longitude
            destinationController.GeocodeVC = self
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let tag = textField.tag
        
        if tag == TAG_ADDRESS_STREET{
            bundleAddress.streetAddress = textField.text!
            
        }else if tag == TAG_ADDRESS_CITY{
            bundleAddress.city = textField.text!
            
        }else if tag == TAG_ADDRESS_STATE{
            bundleAddress.state = textField.text!
            
        }else if tag == TAG_ADDRESS_COUNTRY{
            bundleAddress.country = textField.text!
            
        }else if tag == TAG_ADDRESS_ZIP{
            bundleAddress.zipcode = textField.text!
            
        }else if tag == TAG_CONTACT_FIRST{
            bundleContact.firstName = textField.text!
            
        }else if tag == TAG_CONTACT_LAST{
             bundleContact.lastName = textField.text!
            
        }else if tag == TAG_CONTACT_PHONE{
            bundleContact.phoneNumber = textField.text!
            
        }else if tag == TAG_CONTACT_ACCOUNT{
            bundleContact.accountNumber = textField.text!
            
        }else if tag == TAG_CONTACT_NODE_NAME{
            bundleContact.nodeName = textField.text!
            
        }else{
            //No Need to Handle
        }
        
        
    }
    
    //MARK : HELPER FUNCTIONS
    //0 for Latitude Lngitude Section
    //1 for Address/Contact Section
    func disableSection(sectionCode : Int){
        if sectionCode == 0{
            disableLatLngSection = true
         }else{
            disableAddressContactSection = true
        }
    }
    
    func validate() -> Bool{
        
        var message = ""
        if !UtilityHelper.isValidMacAddress(testStr: self.textFieldMacAddress.text!){
            message = ALERT_MSG_GEOCODE_ENTER_VALID_MAC
        }
        
        if message != ""{
            let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_APP_NAME, message: message, buttonTitle: ALERT_BUTTON_OK, completionHandler: nil)
            self.present(alert, animated: true, completion: nil)
            return false
        }else{
            return true
            
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    @IBAction func btnActionSave(_ sender: Any) {
        if validate(){
            let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
            let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
            
            let macAddress = self.textFieldMacAddress.text!
            
            let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                                  REQ_PARAM_USERNAME : username,
                                  REQ_PARAM_MAC_ADDRESS : macAddress,
                                  REQ_PARAM_GEO_FIRST_NAME : bundleContact.firstName,
                                  REQ_PARAM_GEO_LAST_NAME : bundleContact.lastName,
                                  REQ_PARAM_GEO_ACCOUNT : bundleContact.accountNumber,
                                  REQ_PARAM_GEO_ADDRESS : bundleAddress.streetAddress,
                                  REQ_PARAM_GEO_CITY : bundleAddress.city,
                                  REQ_PARAM_GEO_STATE : bundleAddress.state,
                                  REQ_PARAM_GEO_ZIP : bundleAddress.zipcode,
                                  REQ_PARAM_GEO_COUNTRY : bundleAddress.country,
                                  REQ_PARAM_GEO_PHONE : bundleContact.phoneNumber,
                                  REQ_PARAM_GEO_NODE : bundleContact.nodeName,
                                  REQ_PARAM_GEO_LAT : bundleLocation.latitude,
                                  REQ_PARAM_GEO_LNG : bundleLocation.longitude
            ] as [String : Any];
            
            self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_GEOCODE_SAVE, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_GEOCODE_SAVING, sucessCompletionHadler: {
                responseDict in
                
                let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
                let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
                
                if statusCode == 200{
                    
                    self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: statusMessage, withButtonTitle: ALERT_BUTTON_OK)
                    
                }else if statusCode == 401{
                    self.performLogoutAsSessionExpiredDetected()
                }else{
                    self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: statusMessage, withButtonTitle: ALERT_BUTTON_OK)
                }
                                
                
            },failureCompletionHandler: {
                (errorTitle,errorMessage) in
                self.displayAlert(withTitle: errorTitle, withMessage: errorMessage, withButtonTitle: ALERT_BUTTON_OK)
            })

        }
       
        
        
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
    var latitude: Double = 0
    var longitude: Double = 0
}






