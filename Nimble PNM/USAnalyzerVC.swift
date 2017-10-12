//
//  USAnalyzerVC.swift
//  Nimble PNM
//
//  Created by ksolves on 17/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class USAnalyzerVC: BaseVC,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {

    
    @IBOutlet weak var buttonOutletScan: UIButton!
    @IBOutlet weak var textfieldSelectUpstreamPort: UITextField!
    @IBOutlet weak var textfieldSelectCMTS: UITextField!
    @IBOutlet weak var btnOutletLogout: UIButton!
    var bundleCMTSList : [CMTSLISTDS] = []
    var bundleUpstreamPortList : [UpstreamPortListDS] = []
    var pickerView : UIPickerView!
    var selectedIndex : Int = 0;
    var pickerHolder : CustomPickerView!
    var activeTextfield : UITextField!
    let pickerLabelCMTS = "Select CMTS"
    let pickerLabelUpstreamPort = "Select Upstream Port"
    
    var selectedCMTS = CMTSLISTDS()
    var selectedUpstream = UpstreamPortListDS()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureUIComponents()
        self.loadCMTSList()
        
        
    }
    
    func configureUIComponents(){
        self.configurePicker()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.addLayers()
    }
    
    
    func addLayers(){
        self.textfieldSelectCMTS.addBorder(withColor: COLOR_BORDER_GRAY_MODIFIED, withWidth: 1.0);
        self.textfieldSelectUpstreamPort.addBorder(withColor: COLOR_BORDER_GRAY_MODIFIED, withWidth: 1.0);
    }
    
    
    func configurePicker(){
        //Configuring Picker
        pickerHolder = Bundle.main.loadNibNamed("CustomPickerView", owner: self, options: nil)?[0] as! CustomPickerView
        pickerHolder.buttonOutletDone.addTarget(self, action: #selector(buttonPickerDonePressed(_:)), for: .touchUpInside)
        pickerHolder.buttonOutletCancel.addTarget(self, action: #selector(buttonPickerCancelPressed(_:)), for: .touchUpInside)
        
        pickerView = pickerHolder.pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.textfieldSelectCMTS.inputView = pickerHolder
        self.textfieldSelectUpstreamPort.inputView = pickerHolder
    }

    func buttonPickerDonePressed(_ sender: UIButton){
        selectedIndex = self.pickerView.selectedRow(inComponent: 0)
        
        if activeTextfield == textfieldSelectCMTS{
            if selectedIndex != -1 && bundleCMTSList.count > 0{
                let relevantRecord = self.bundleCMTSList[selectedIndex]
                self.selectedCMTS = relevantRecord
                
                self.textfieldSelectCMTS.text = relevantRecord.name
                self.textfieldSelectUpstreamPort.text = ""
                self.loadPortList(forCMTS: relevantRecord.id)
            }
            self.textfieldSelectCMTS.resignFirstResponder()
            
        }else if activeTextfield == textfieldSelectUpstreamPort{
            if selectedIndex != -1 && bundleUpstreamPortList.count > 0{
                let relevantRecord = self.bundleUpstreamPortList[selectedIndex]
                selectedUpstream = relevantRecord
                
                self.textfieldSelectUpstreamPort.text = relevantRecord.interfaceName
            }
            self.textfieldSelectUpstreamPort.resignFirstResponder()
            
        }else{
            // Do Nothing
        }
        
        
    }
    
    func buttonPickerCancelPressed(_ sender: UIButton){
        if activeTextfield == textfieldSelectCMTS{
            self.textfieldSelectCMTS.resignFirstResponder()
            
        }else if activeTextfield == textfieldSelectUpstreamPort{
            self.textfieldSelectUpstreamPort.resignFirstResponder()
            
        }else{
            //Do Nothing
        }
        
        
    }
    
    
    
    func loadCMTSList(){
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_US_ANALYZER_CMTS_LIST, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_US_CMTS_LIST, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                
                let dataArray = responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSArray
                
                self.bundleCMTSList.removeAll()
                for eachRecord in dataArray{
                    let castedRecord = eachRecord as! NSDictionary
                    var tempRecord = CMTSLISTDS()
                    
                    tempRecord.id = String(describing:castedRecord.value(forKey: RESPONSE_PARAM_US_CMTS_ID)!)
                    tempRecord.name = String(describing:castedRecord.value(forKey: RESPONSE_PARAM_US_CMTS_NAME)!)
                    
                    self.bundleCMTSList.append(tempRecord)
                }
                
                if self.bundleCMTSList.count > 0{
                    //Setting value for Text field
                    self.loadPortList(forCMTS: self.bundleCMTSList[0].id)
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
    
    func loadPortList(forCMTS cmtsID:String){
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_US_ANALYZER_CMTS_PORT, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_US_PORT_LIST, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                let relevantDataArray = (((responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSArray)[0] as! NSDictionary).value(forKey: RESPONSE_PARAM_DATA) as! NSArray)
                
                
                self.bundleUpstreamPortList.removeAll()
                for eachRecord in relevantDataArray{
                    var tempRecord = UpstreamPortListDS()
                    let castedRecord = (((eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_UPSTREAM) as! NSArray)[0]) as! NSDictionary
                    tempRecord.id = String(describing: castedRecord.value(forKey: RESPONSE_PARAM_ID)!)
                    tempRecord.interfaceName = castedRecord.value(forKey: RESPONSE_PARAM_INTERFACE_NAME) as! String
                    
                    self.bundleUpstreamPortList.append(tempRecord)
                    
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
    
    //MARK: UITextfield Delegates and Datasource
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == textfieldSelectCMTS{
            activeTextfield = textField
            pickerHolder.labelPickerHeading.text = pickerLabelCMTS
            self.pickerView.reloadAllComponents()
            
        }else if textField == textfieldSelectUpstreamPort{
            activeTextfield = textField
            pickerHolder.labelPickerHeading.text = pickerLabelUpstreamPort
            self.pickerView.reloadAllComponents()
            
        }else{
            // Do Nothing
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == textfieldSelectUpstreamPort || textField == textfieldSelectCMTS{
            return false
            
        }else{
            return true
            
        }
    }
    
    //MARK: UIPickerView Delegates and Datasources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if activeTextfield == textfieldSelectCMTS{
            return self.bundleCMTSList[row].name
            
        }else if activeTextfield == textfieldSelectUpstreamPort{
            return self.bundleUpstreamPortList[row].interfaceName
            
        }else{
            return ""
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if activeTextfield == textfieldSelectCMTS{
            return self.bundleCMTSList.count
            
        }else if activeTextfield == textfieldSelectUpstreamPort{
            return self.bundleUpstreamPortList.count
            
        }else{
            return 0
        }
    }
    
    func validate() -> Bool{
        var message = ""
        
        if textfieldSelectCMTS.text == ""{
            message = ALERT_MSG_US_ANALYZER_BLANK_CMTS
            
        }else if textfieldSelectUpstreamPort.text == ""{
            message = ALERT_MSG_US_ANALYZER_BLANK_UPSTREAM
            
        }else{
            message = ""
            
        }
        
        if message == ""{
            return true
            
        }else{
            self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: message, withButtonTitle: ALERT_BUTTON_OK)
            return false
        }
    }
    
    @IBAction func buttonActionScan(_ sender: Any) {
        if validate(){
            self.performSegue(withIdentifier: "segue-to-us-analyzer-graph", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue-to-us-analyzer-graph"{
            let destinationController = segue.destination  as! USAnalyzerGraphVC
            destinationController.bundleLoadingData = ["cmts": selectedCMTS ,"upstream": selectedUpstream]
        }
    }
    
    @IBAction func btnActionLogout(_ sender: Any) {
        self.performLogout()
    }
}


struct CMTSLISTDS{
    var id = ""
    var name = ""
}


struct UpstreamPortListDS{
    var id = ""
    var interfaceName = ""
}







