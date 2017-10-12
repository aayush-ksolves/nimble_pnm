//
//  InstallCMVC.swift
//  Nimble PNM
//
//  Created by ksolves on 17/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class InstallCMVC: BaseVC,BarCodeScannerDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate {

    @IBOutlet weak var viewHolderBox: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var segmentedControlModemInstall: UISegmentedControl!
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var btnOutletLogout: UIButton!
    @IBOutlet weak var textfieldSelectMacAddress: UITextField!
    
    @IBOutlet weak var buttonOutletHelp: UIButton!
    
    let imageScanBarcode = UIImage(named: "barcode")
    
    let barcodeScanner  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BarCodeScannerVC") as! BarCodeScannerVC
    
    @IBOutlet weak var buttonOutletInstallModem: UIButton!
    @IBOutlet weak var buttonOutletComplete: UIButton!
    
    @IBOutlet weak var contraintTopInstallButton: NSLayoutConstraint!
    
    @IBOutlet weak var labelModemStatus: UILabel!
    @IBOutlet weak var contraintBottomInstallButton: NSLayoutConstraint!
    
    var bundleFailedModems = NSMutableArray()
    
    @IBOutlet weak var textfieldFailedMacAddress: UITextField!
    
    var pickerView : UIPickerView!
    var selectedIndex : Int = 0;
    //CODE Description
    //0 = Show Only Install Modem
    //1 = Show Modem Status and Install Modem
    //2 = Show Modem status, Install button and Complete button
    //3 = Show install button and Complete
    
    //Widget Code Description
    //0 = Install Modem
    //1 = Failed Modem
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.configureUIComponents()
    }
    
    

    func configureUIComponents(){
        
        self.labelHeading.text = TXT_LBL_CM_INSTALLER_HEAD
        
        //Preparing Button To Insert in the Right Of Text field
        let buttonScanBarcode = UIButton(frame: CGRect(x: 0, y: 8, width: 40, height: 24));
        buttonScanBarcode.addTarget(self, action: #selector(buttonScanBarcodePressed(_:)), for: .touchUpInside)
        buttonScanBarcode.setImage(imageScanBarcode, for: .normal)
        buttonScanBarcode.imageView?.contentMode = .scaleAspectFit
        
        self.textfieldSelectMacAddress.rightViewMode = .always
        self.textfieldSelectMacAddress.rightView = buttonScanBarcode
        
        self.viewHolderBox.addBorder(withColor: COLOR_BORDER_GRAY_MODIFIED, withWidth: 1.0)
        
        
        //Configuring Picker
        let pickerHolder = Bundle.main.loadNibNamed("CustomPickerView", owner: self, options: nil)?[0] as! CustomPickerView
        
        pickerHolder.labelPickerHeading.text = "Select Mac Address"
        pickerHolder.buttonOutletDone.addTarget(self, action: #selector(buttonPickerDonePressed(_:)), for: .touchUpInside)
        pickerHolder.buttonOutletCancel.addTarget(self, action: #selector(buttonPickerCancelPressed(_:)), for: .touchUpInside)
        
        pickerView = pickerHolder.pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.textfieldFailedMacAddress.inputView = pickerHolder
        
        self.segmentedControlModemInstall.selectedSegmentIndex = 0;
        self.activateNewInstall(withAnimation: false)
        
        
        
    }
    
    
    
    
    func buttonPickerDonePressed(_ sender: UIButton){
        selectedIndex = self.pickerView.selectedRow(inComponent: 0)
        if selectedIndex != -1 && bundleFailedModems.count > 0{
            let relevantRecord = self.bundleFailedModems[selectedIndex] as! FailedModemDS
            self.textfieldFailedMacAddress.text = relevantRecord.macAddress
            self.labelModemStatus.text = relevantRecord.age
            
            self.show(code: 2, withAnimation: true)
        }
        
        self.textfieldFailedMacAddress.resignFirstResponder()
        
    }
    
    func buttonPickerCancelPressed(_ sender: UIButton){
        
        self.textfieldFailedMacAddress.resignFirstResponder()
        
    }
    
    
    
    func installModem(withMacAddress mac : String,forWidgetCode widgetCode:Int){
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let formattedMacAddress = mac
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username,
                              REQ_PARAM_MAC_ADDRESS : formattedMacAddress
        
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_INSTALL_CABLE_MODEM, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_INSTALL_MODEMS, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                
                let dataReceived = (responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSArray)[0] as! NSDictionary
                let testPassedDn = dataReceived.value(forKey: RESPONSE_PARAM_TEST_PASSED_DN) as! Bool
                let testPassed = dataReceived.value(forKey: RESPONSE_PARAM_TEST_PASSED) as! Bool
                
                //Checking Other Values
                var alert : UIAlertController!
                if !(testPassedDn && testPassed){
                    alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_APP_NAME, message: ALERT_MSG_COMPLETE_SUCCESS_BUT_FAILED, buttonTitle1: ALERT_BUTTON_SHOW_DETAIL, buttonTitle2: ALERT_BUTTON_GEOCODE, buttonTitle3: ALERT_BUTTON_OK, buttonStyle1: UIAlertActionStyle.default, buttonStyle2: UIAlertActionStyle.default, buttonStyle3: UIAlertActionStyle.default, completionHandler1: {
                        action in
                        
                        
                        
                        self.performAfterInstallationShowDetailsProcedure(forWidgetCode: widgetCode,forDataBundle: dataReceived)
                        
                    }, completionHandler2: {
                        action in
                        self.performAfterInstallationGeocodeProcedure(forWidgetCode: widgetCode, macAddress : mac)
                        
                    }, completionHandler3: {
                        action in
                        self.performAfterInstallationOKProcedure(forWidgetCode: widgetCode)
                    })
                }else{
                    alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_APP_NAME, message: ALERT_MSG_INSTALL_CM_SUCCESS, buttonTitle: ALERT_BUTTON_OK, completionHandler: {
                        action in
                        
                        self.performAfterInstallationOKProcedure(forWidgetCode: widgetCode)
                        
                    })
                }
                
                
                
                
                self.present(alert, animated: true, completion: nil)
                
                
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
    
    func getModemInstallStatus(){
        
    }
    
    func performAfterInstallationOKProcedure(forWidgetCode widgetCode:Int){
        if widgetCode == 0{
            self.textfieldSelectMacAddress.text = "";
            self.show(code: 0)
            
        }else{
            self.textfieldFailedMacAddress.text = "";
            self.show(code: 3)
            self.loadFailedModemList(isBeingRefreshed: true)
        }
    }
    
    func performAfterInstallationShowDetailsProcedure(forWidgetCode widgetCode:Int, forDataBundle dataBundle:NSDictionary){
        self.performAfterInstallationOKProcedure(forWidgetCode: widgetCode)
        
        
        //Throw to New Screen with data Loaded from Firing Http Service To Load Modem Status in new screen
        self.performSegue(withIdentifier: "segue-to-modem-status", sender: dataBundle)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue-to-modem-status"{
            let destinationController = segue.destination as! ModemStatusVC
            destinationController.dataBundle = sender as! NSDictionary
            
        }else if segue.identifier == "segue-to-geocode"{
            let destinationController = segue.destination as! GeocodeVC
            destinationController.exposedMacAddress = sender as! String
            
        }
        
        
        
    }
    
    
    func performAfterInstallationGeocodeProcedure(forWidgetCode widgetCode:Int, macAddress:String){
        self.performAfterInstallationOKProcedure(forWidgetCode: widgetCode)
        
        self.performSegue(withIdentifier: "segue-to-geocode", sender: macAddress)
        
    }
    
    
    
    func getModemStatus(withMacAddress mac : String,withCMTSID cmtsID : String){
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let formattedMacAddress = UtilityHelper.getMacAddressFromTrivialString(mac: mac)
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username,
                              REQ_PARAM_MAC_ADDRESS : formattedMacAddress,
                              REQ_PARAM_CMTSID : cmtsID
                              
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_INSTALL_GET_MODEM_STATUS, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_GETTING_MODEM_STATUS, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
             
                
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
    
    
    func loadFailedModemList(isBeingRefreshed:Bool = false){
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                               REQ_PARAM_USERNAME : username
        ];
        
        var loaderMessage : String!
        
        if isBeingRefreshed{
            loaderMessage = LOADER_MSG_REFRESH_FAILED_MODEMS
        }else{
            loaderMessage = LOADER_MSG_FAILED_MODEMS
        }
        
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_INSTALL_LOAD_FAILED, withParameters: dictParameters, withLoaderMessage: loaderMessage, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                let dataArray = responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSArray
                
                self.bundleFailedModems.removeAllObjects()
                for eachModem in dataArray{
                    var tempFailedModem = FailedModemDS()
                    tempFailedModem.age = String(describing:(eachModem as! NSDictionary).value(forKey: RESPONSE_PARAM_AGE)!)
                    tempFailedModem.cmtsID = String(describing:(eachModem as! NSDictionary).value(forKey: RESPONSE_PARAM_CMTS_ID)!)
                    tempFailedModem.macAddress = String(describing:(eachModem as! NSDictionary).value(forKey: RESPONSE_PARAM_MAC_ADDRESS)!)
                    tempFailedModem.timestamp = String(describing:(eachModem as! NSDictionary).value(forKey: RESPONSE_PARAM_TIMESTAMP)!)
                    
                    self.bundleFailedModems.add(tempFailedModem)
                }
                
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
    
    
    func completeFailedModem(withMacAddress mac : String, withCTMSID cmtsID : String){
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username,
                              REQ_PARAM_MAC_ADDRESS : mac,
                              REQ_PARAM_CMTSID : cmtsID
            
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_INSTALL_COMPLETE_FAILED, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_COMPLETE_FAILED_MODEMS, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_APP_NAME, message: ALERT_MSG_COMPLETE_SUCCESS, buttonTitle: ALERT_BUTTON_OK, buttonStyle: UIAlertActionStyle.default, completionHandler: {
                    action in
                    self.textfieldFailedMacAddress.text = "";
                    self.show(code: 3)
                    self.loadFailedModemList(isBeingRefreshed: true)
                })
                self.present(alert, animated: true, completion: nil)
                
                
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
    
    //MARK: Bar Code Scanner Delegates
    func scanningCompleteWithDataString(dataString: String) {
        self.textfieldSelectMacAddress.text = dataString
        
    }
    
    
    func scanningFailedDueToReason(reasonCode: Int!) {
        print("Scanning Failed Due To Reason code \(reasonCode!)")
    }
    

    
    
    func show(code : Int, withAnimation animation:Bool = true){
        if code == 0{
            //Handle Hiding
            self.labelModemStatus.isHidden = true
            self.buttonOutletHelp.isHidden = true
            self.buttonOutletComplete.isHidden = true;
            
            self.contraintTopInstallButton.constant = 24
            self.contraintBottomInstallButton.constant = 24
            
            if animation{
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
                }, completion:{
                    finished in
                })
                
            }
            
        }else if code == 1{
            //Handling Hiding
            self.buttonOutletHelp.isHidden = true
            self.buttonOutletComplete.isHidden = true;
            
            
            self.contraintTopInstallButton.constant = 60;
            self.contraintBottomInstallButton.constant = 24;
            
            
            
            
            
        }else if code == 2{
            self.contraintTopInstallButton.constant = 60;
            self.contraintBottomInstallButton.constant = 60;
            
            if animation{
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
                }, completion:{
                    finished in
                    self.buttonOutletComplete.isHidden = false
                    self.buttonOutletHelp.isHidden = false;
                    self.labelModemStatus.isHidden = false
                })
                
            }
            
            
            
        }else if code == 3{
            
            self.labelModemStatus.isHidden = true
            
            
            self.contraintTopInstallButton.constant = 24;
            self.contraintBottomInstallButton.constant = 60;
            
            if animation{
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
                }, completion:{
                    finished in
                    self.buttonOutletComplete.isHidden = false
                    self.buttonOutletHelp.isHidden = false;
                })
                
            }
            
            
            
        }
        
    }

    func validate() -> Bool{
        var message = ""
        var tempMacAddress : String;
        
        if segmentedControlModemInstall.selectedSegmentIndex == 0{
            tempMacAddress = (self.textfieldSelectMacAddress.text?.trimmingCharacters(in: CharacterSet.controlCharacters))!
            self.textfieldSelectMacAddress.text = tempMacAddress
        }else{
            tempMacAddress = (self.textfieldFailedMacAddress.text?.trimmingCharacters(in: CharacterSet.controlCharacters))!
            self.textfieldFailedMacAddress.text = tempMacAddress
        }
        
        
        
        
        if ((tempMacAddress.characters.count) < 1){
            message = ALERT_MSG_INSTALL_BLANK_MAC
        }else if !UtilityHelper.isValidMacAddress(testStr: tempMacAddress){
            message = ALERT_MSG_INSTALL_VALID_MAC
        }
        
        
        if message != ""{
            self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: message, withButtonTitle: ALERT_BUTTON_OK)
            return false
            
        }else{
            return true
            
        }
        
        
        
    }

    
    @IBAction func btnActionLogout(_ sender: Any) {
        self.performLogout()
        
    }
    
    @IBAction func btnActionComplete(_ sender: Any) {
        if validate(){
            let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_APP_NAME, message: ALERT_MSG_COMPLETE_MODEM_CONFIRM, buttonTitle1: ALERT_BUTTON_CANCEL, buttonTitle2: ALERT_BUTTON_OK, buttonStyle1: .destructive, buttonStyle2: .default, completionHandler1: nil, completionHandler2: {
                action in
                let relevantRecord = self.bundleFailedModems[self.selectedIndex] as! FailedModemDS
                self.completeFailedModem(withMacAddress: relevantRecord.macAddress, withCTMSID: relevantRecord.cmtsID)
            })
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    
    @IBAction func btnActionHelp(_ sender: Any) {
        self.displayAlert(withTitle: ALERT_TITLE_INSTALL_CM_HELP, withMessage: ALERT_MSG_INSTALL_COMPLETE_MODEM, withButtonTitle: ALERT_BUTTON_OK)
    }
    
    @IBAction func segmentedControlModemTypeChangedAction(_ sender: Any) {
        self.view.endEditing(true)
        
        let control = sender as! UISegmentedControl
        
        if control.selectedSegmentIndex == 0{
            self.activateNewInstall()
            
        }else if control.selectedSegmentIndex == 1{
            self.activateFailedInstall()
            
        }else{
            //Will Not Occur
        }
        
    }
    func activateNewInstall(withAnimation animation:Bool = true){
        self.textfieldSelectMacAddress.isHidden = false
        self.textfieldFailedMacAddress.isHidden = true
        
        if animation{
            self.show(code: 0)
        }else{
            self.show(code: 0,withAnimation: false)
        }
        
        
    }
    
    
    func activateFailedInstall(withAnimation animation:Bool = true){
        self.textfieldSelectMacAddress.isHidden = true
        self.textfieldFailedMacAddress.isHidden = false
        
        if animation{
            self.show(code: 3)
        }else{
            self.show(code: 3,withAnimation: false)
        }
        
        self.loadFailedModemList()
        
    }
    
    
    @IBAction func btnActionInstallModem(_ sender: Any) {
        if validate(){
            if segmentedControlModemInstall.selectedSegmentIndex == 0{
                self.installModem(withMacAddress: self.textfieldSelectMacAddress.text!, forWidgetCode: 0)
            }else if segmentedControlModemInstall.selectedSegmentIndex == 1{
                self.installModem(withMacAddress: self.textfieldFailedMacAddress.text!, forWidgetCode: 1)
            }
            
        }
    }
    
    func buttonScanBarcodePressed(_ sender: UIButton){
        barcodeScanner.delegate = self
        self.present(barcodeScanner, animated: true, completion: nil)
    }
    
    
    //MARK: UITextfield Dlegates 
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textfieldFailedMacAddress == textField{
            return false
        }else{
            return true
            
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: UIPickerView Delegate and DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bundleFailedModems.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let relevantRecord = bundleFailedModems[row] as! FailedModemDS
        return relevantRecord.macAddress;
    }
    
    
    
}



fileprivate struct FailedModemDS{
    var cmtsID = ""
    var macAddress = ""
    var timestamp = ""
    var age = ""
    
}





