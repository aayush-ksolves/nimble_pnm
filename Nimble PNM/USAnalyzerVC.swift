//
//  USAnalyzerVC.swift
//  Nimble PNM
//
//  Created by ksolves on 17/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class USAnalyzerVC: BaseVC,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableViewPorts: UITableView!
    @IBOutlet weak var viewTapper: UIView!
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
    
    var selectedCMTS = CMTSLISTDS()
    var selectedUpstream = UpstreamPortListDS()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureUIComponents()
        self.loadCMTSList()
        
    }
    
    func configureUIComponents(){
        
        shouldHideTableView(shouldHide: true)
        
        let tapRec = UITapGestureRecognizer.init(target: self, action: #selector(tappedOnTapperView))
        tapRec.numberOfTapsRequired = 1
        viewTapper.addGestureRecognizer(tapRec)
        
        tableViewPorts.estimatedRowHeight = 30
        self.tableViewPorts.rowHeight = UITableViewAutomaticDimension
        
        tableViewPorts.register(UINib(nibName: "USAnalyzerUpstreamPortCell", bundle: nil), forCellReuseIdentifier: "USAnalyzerUpstreamPortCell")
        
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
    }
    
    @objc func tappedOnTapperView() {
        shouldHideTableView(shouldHide: true)
    }

    @objc func buttonPickerDonePressed(_ sender: UIButton){
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
            
        }else{
            // Do Nothing
        }
        
    }
    
    @objc func buttonPickerCancelPressed(_ sender: UIButton){
        if activeTextfield == textfieldSelectCMTS{
            self.textfieldSelectCMTS.resignFirstResponder()
            
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
                    let isEnabled = String(describing:castedRecord.value(forKey: RESPONSE_PARAM_IS_ENABLED)!)
                    let isUSAEnabled = String(describing:castedRecord.value(forKey: RESPONSE_PARAM_USA_ENABLED)!)
                    
                    if isEnabled == "1" && isUSAEnabled == "1" {
                        var tempRecord = CMTSLISTDS()
                        
                        tempRecord.id = String(describing:castedRecord.value(forKey: RESPONSE_PARAM_US_CMTS_ID)!)
                        tempRecord.name = String(describing:castedRecord.value(forKey: RESPONSE_PARAM_US_CMTS_NAME)!)
                        
                        tempRecord.type = String(describing:castedRecord.value(forKey: RESPONSE_PARAM_TYPE)!)
                            
                        if tempRecord.type == "ArrisC4" {
                            tempRecord.res = "2048"
                        }
                        
                        self.bundleCMTSList.append(tempRecord)
                    }
                    
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
                              REQ_PARAM_USERNAME : username,
                              REQ_SPEC_ANALYZER_ENABLED : "1",
            
            ] as [String : Any];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_US_ANALYZER_CMTS_PORT, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_US_PORT_LIST, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                
                let dataArray = responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSArray
                var relevantDataArray : NSArray!
                
                for eachDic in dataArray {
                    let castedDic = eachDic as! NSDictionary
                    let responseCMTSId = castedDic.value(forKey: RESPONSE_PARAM_CMTS_ID) as! String
                    
                    if responseCMTSId == cmtsID {
                        relevantDataArray = castedDic.value(forKey: RESPONSE_PARAM_DATA) as! NSArray
                    }
                    
                }
                
                self.bundleUpstreamPortList.removeAll()
                for eachRecord in relevantDataArray{
                    
                    var tempRecord = UpstreamPortListDS()
                    let castedRecord = (((eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_UPSTREAMS) as! NSArray)[0]) as! NSDictionary
                    tempRecord.id = String(describing: castedRecord.value(forKey: RESPONSE_PARAM_ID)!)
                    tempRecord.interfaceName = castedRecord.value(forKey: RESPONSE_PARAM_INTERFACE_NAME) as! String
                    tempRecord.alias = castedRecord.value(forKey: RESPONSE_PARAM_ALIAS) as! String
                    tempRecord.frequency = castedRecord.value(forKey: RESPONSE_PARAM_FREQ) as! String
//                    tempRecord.startFreq = castedRecord.value(forKey: RESPONSE_PARAM_START_FREQ) as! String
//                    tempRecord.endFreq = castedRecord.value(forKey: RESPONSE_PARAM_END_FREQ) as! String
                    
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bundleUpstreamPortList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "USAnalyzerUpstreamPortCell") as! USAnalyzerUpstreamPortCell
        let cellData = bundleUpstreamPortList[row]
        
        cell.labelAlias.text = cellData.alias
        cell.labelFrequency.text = cellData.frequency
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = indexPath.row
        
        let relevantRecord = self.bundleUpstreamPortList[selectedRow]
        selectedUpstream = relevantRecord
        self.textfieldSelectUpstreamPort.text = relevantRecord.alias
        shouldHideTableView(shouldHide: true)
    }
    
    func shouldHideTableView(shouldHide: Bool){
        tableViewPorts.isHidden = shouldHide
        viewTapper.isHidden = shouldHide
        textfieldSelectUpstreamPort.resignFirstResponder()
    }
    
    //MARK: UITextfield Delegates and Datasource
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == textfieldSelectCMTS{
            activeTextfield = textField
            pickerHolder.labelPickerHeading.text = pickerLabelCMTS
            self.pickerView.reloadAllComponents()
            
        }else if textField == textfieldSelectUpstreamPort{
            
            if self.textfieldSelectCMTS.text == "" {
                
                self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: "Please select CMTS", withButtonTitle: ALERT_BUTTON_OK)
                
            }else {
                
                activeTextfield = textField
                tableViewPorts.reloadData()
                shouldHideTableView(shouldHide: false)
            }
            
            return false
            
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
            
        }else{
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if activeTextfield == textfieldSelectCMTS{
            return self.bundleCMTSList.count
            
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
    var res = "180"
    var type = ""
}


struct UpstreamPortListDS{
    var id = ""
    var interfaceName = ""
    var alias = ""
    var frequency = ""
//    var startFreq = ""
//    var endFreq = ""
}







