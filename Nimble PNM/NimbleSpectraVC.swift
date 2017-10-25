//
//  NimbleSpectraVC.swift
//  Nimble PNM
//
//  Created by KSolves on 13/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class NimbleSpectraVC: BaseVC , UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    @IBOutlet weak var tableViewCMTSData: UITableView!
    @IBOutlet weak var textFieldSelectCMTS: UITextField!
    
    var pickerView : UIPickerView!
    
    fileprivate var bundleCMTS : [CMTSDataDS] = []
    var bundleDetails : NSDictionary = [:]
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        designPickerView()
        self.loadCMTS()
    }
    
    func designPickerView() {
        
        let pickerHolder = Bundle.main.loadNibNamed("CustomPickerView", owner: self, options: nil)?[0] as! CustomPickerView
        
        pickerHolder.labelPickerHeading.text = "Select CMTS"
        pickerHolder.buttonOutletDone.addTarget(self, action: #selector(buttonPickerDonePressed(_:)), for: .touchUpInside)
        pickerHolder.buttonOutletCancel.addTarget(self, action: #selector(buttonPickerCancelPressed(_:)), for: .touchUpInside)
        
        pickerView = pickerHolder.pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.textFieldSelectCMTS.inputView = pickerHolder
        
    }
    
    
    func loadCMTS() {
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username
            ] as [String : Any];
        
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_NIMBLE_SPECTRA_IMPAIR_COUNT, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_NS_IMPAIR_COUNT, sucessCompletionHadler: {
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
    
    
    func buttonPickerDonePressed(_ sender: UIButton){
        selectedIndex = self.pickerView.selectedRow(inComponent: 0)
        if selectedIndex != -1 && bundleCMTS.count > 0{
            let relevantRecord = self.bundleCMTS[selectedIndex]
            self.textFieldSelectCMTS.text = relevantRecord.name
        }
        
        self.textFieldSelectCMTS.resignFirstResponder()
    }
    
    func buttonPickerCancelPressed(_ sender: UIButton){
        
        self.textFieldSelectCMTS.resignFirstResponder()
    }
    
    
    @IBAction func btnActionLogout(_ sender: Any) {
        
        self.performLogout()
    }
    
    // Picker View Delegate & Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bundleCMTS.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let relevantRecord = bundleCMTS[row]
        return relevantRecord.name
    }
    
    
}

fileprivate struct CMTSDataDS {
    
    var name = ""
}





