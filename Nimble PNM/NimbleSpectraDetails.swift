//
//  NimbleSpectraDetails.swift
//  Nimble PNM
//
//  Created by KSolves on 23/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class NimbleSpectraDetails : BaseVC, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var exposedSelectedCMTSName = ""
    var exposedSelectedCMTSProperty = ""
    var exposedSelectedCMTSId = ""
    var exposedCMTSImpairmentType = ""
    
    @IBOutlet weak var tableViewCMTSDetails: UITableView!
    @IBOutlet weak var imageViewSearch: UIImageView!
    @IBOutlet weak var textFieldSearchMACAddress: UITextField!
    @IBOutlet weak var labelSelectedProperty: UILabel!
    @IBOutlet weak var labelCMTSName: UILabel!
    @IBOutlet weak var viewSearchMACAddress: UIView!
    
    fileprivate var bundleCMTSModem: [CMTSModemDataDS] = []
    fileprivate var tempBundleCMTSModem: [CMTSModemDataDS] = []
    
    var selectedModem = -1
    
    var footerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUIComponents()
        loadCMTSModem()
    }
    
    func configureUIComponents() {
        
        labelCMTSName.text = exposedSelectedCMTSName
        labelSelectedProperty.text = exposedSelectedCMTSProperty

        textFieldSearchMACAddress.delegate = self
        textFieldSearchMACAddress.addTarget(self, action: #selector(valueChangedInTextField(_:)), for: .editingChanged)
        
        tableViewCMTSDetails.estimatedRowHeight = 100
        self.tableViewCMTSDetails.rowHeight = UITableViewAutomaticDimension
        
        tableViewCMTSDetails.backgroundColor = UIColor.clear
        footerView.backgroundColor = UIColor.clear
        
        tableViewCMTSDetails.register(UINib(nibName: "CMTSDetails", bundle: nil), forCellReuseIdentifier: "CMTSDetails")
        
        imageViewSearch.contentMode = .scaleAspectFit
        viewSearchMACAddress.addBorder(withColor: COLOR_BORDER_GRAY_MODIFIED, withWidth: 1)
    }
    
    func loadCMTSModem() {
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_USERNAME: username,
                              REQ_PARAM_AUTH_KEY: authKey,
                              REQ_PARAM_IMPAIRMENT_TYPE: exposedCMTSImpairmentType,
                              REQ_PARAM_CMTS_ID: exposedSelectedCMTSId
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_NIMBLE_SPECTRA_GET_CMTS_MODEM_LIST, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_FETCH_MODEM, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                
                self.bundleCMTSModem.removeAll()
                
                let dataArray = responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSArray
                
                for eachData in dataArray {
                    
                    var tempModemData = CMTSModemDataDS()
                    
                    tempModemData.macAddress = String(describing: (eachData as! NSDictionary).value(forKey: RESPONSE_PARAM_MAC_ADDRESS)!)
                    tempModemData.timestamp = String(describing: (eachData as! NSDictionary).value(forKey: RESPONSE_PARAM_TIMESTAMP)!)
                    tempModemData.upstream = String(describing: (eachData as! NSDictionary).value(forKey: RESPONSE_PARAM_UPSTREAM)!)
                    tempModemData.impairment = String(describing: (eachData as! NSDictionary).value(forKey: RESPONSE_PARAM_NS_IMPAIRMANTS)!)
                    tempModemData.serverityVal = (eachData as! NSDictionary).value(forKey: RESPONSE_PARAM_SERVITY_VAL)! as! Int
                    
                    if tempModemData.serverityVal == 0 {
                        tempModemData.leftStripColor = UIColor.green
                    }else {
                        tempModemData.leftStripColor = UIColor.red
                    }
                    
                    if tempModemData.impairment == "" {
                        tempModemData.impairment = "None"
                    }
                    
                    self.bundleCMTSModem.append(tempModemData)
                }
                
                self.tempBundleCMTSModem = self.bundleCMTSModem
                self.tableViewCMTSDetails.reloadData()
                
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
        return tempBundleCMTSModem.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellNo = indexPath.section
        let cell = tableView.dequeueReusableCell(withIdentifier: "CMTSDetails") as! CMTSDetails
        let cellData = tempBundleCMTSModem[cellNo]
        
        cell.labelMAC.text = cellData.macAddress
        cell.labelDate.text = cellData.timestamp
        cell.labelUpstream.text = cellData.upstream
        cell.labelImpairment.text = cellData.impairment
        cell.labelSideStrip.backgroundColor = cellData.leftStripColor
        
        cell.buttonStatistics.tag = cellNo
        cell.buttonStatistics.addTarget(self, action: #selector(buttonStatisticsPressed(_:)), for: .touchUpInside)
        
        return cell;
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue-to-spectra-analysis"{
            
            let selectedIndexData = bundleCMTSModem[selectedModem]
            let destinationController = segue.destination as! NimbleSpectraAnalysis
            
            destinationController.exposedCMTSId = exposedSelectedCMTSId
            destinationController.exposedCMTSName = exposedSelectedCMTSName
            destinationController.exposedMacAddress = selectedIndexData.macAddress
            destinationController.exposedMTimestamp = selectedIndexData.timestamp
        }
    }
    
    func buttonStatisticsPressed(_ sender: UIButton) {
        
        selectedModem = sender.tag
        self.performSegue(withIdentifier: "segue-to-spectra-analysis", sender: self)
    }
    
    
    func valueChangedInTextField(_ textField: UITextField) {
        
        let newString = textField.text!
        print(newString)
        filterModemByMacAddress(macAddress: newString)
    }
    
    
    func filterModemByMacAddress(macAddress: String) {
        
        tempBundleCMTSModem.removeAll()
        
        if macAddress == "" {
            tempBundleCMTSModem = bundleCMTSModem
        }else {
            
            for eachData in bundleCMTSModem {
                
                if eachData.macAddress.contains(macAddress) {
                    tempBundleCMTSModem.append(eachData)
                }
            }
        }
        
        tableViewCMTSDetails.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func btnActionLogout(_ sender: Any) {
        
        self.performLogout()
    }
    
}

fileprivate struct CMTSModemDataDS {
    
    var macAddress = ""
    var upstream = ""
    var timestamp = ""
    var impairment = ""
    var serverityVal = 0
    var leftStripColor = UIColor.green
}


