//
//  NimbleSpectraVC.swift
//  Nimble PNM
//
//  Created by KSolves on 13/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class NimbleSpectraVC: BaseVC , UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    
    @IBOutlet weak var tableViewCMTSData: UITableView!
    @IBOutlet weak var textFieldSelectCMTS: UITextField!
    
    var pickerView : UIPickerView!
    
    fileprivate var bundleCMTS : [CMTSDataDS] = []
    let CMTS_HEADINGS = ["FBC Modem Polled","Poll+","Poll-","Impairment Count","Suckouts","Adjacencies","Resonant Peak","Noise","Tilt","Wave","Rolloff","Event Count"]
    
    let CMTS_IMPAIRMENT_TYPES = [RESPONSE_PARAM_NS_FBC_MODEM_POLLED,RESPONSE_PARAM_NS_POLL_POS,RESPONSE_PARAM_NS_POLL_NEG,RESPONSE_PARAM_NS_IMPAIRMANT_COUNT,RESPONSE_PARAM_NS_SUCKOUT,RESPONSE_PARAM_NS_ADJACENCY,RESPONSE_PARAM_NS_RESONANT_PEAK,RESPONSE_PARAM_NS_NOISE,RESPONSE_PARAM_NS_TILT,RESPONSE_PARAM_NS_WAVE,RESPONSE_PARAM_NS_ROLLOFF,RESPONSE_PARAM_NS_EVENT_COUNT]
    
    var CMTS_VALUES: [Int] = []
    
    var selectedCMTS = -1
    var selectedSection = -1
    
    var footerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUIComponents()
        designPickerView()
        loadCMTS()
    }
    
    func configureUIComponents(){
        
        textFieldSelectCMTS.delegate = self
        
        tableViewCMTSData.estimatedRowHeight = 50
        self.tableViewCMTSData.rowHeight = UITableViewAutomaticDimension
        
        tableViewCMTSData.backgroundColor = UIColor.clear
        footerView.backgroundColor = UIColor.clear
        
        tableViewCMTSData.register(UINib(nibName: "CMTSDataCell", bundle: nil), forCellReuseIdentifier: "CMTSDataCell")
        
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
        
        let dictParameters = [REQ_PARAM_USERNAME: username,
                              REQ_PARAM_AUTH_KEY: authKey
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_NIMBLE_SPECTRA_GET_CMTS_LIST, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_FETCH_CMTS_LIST, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            self.bundleCMTS.removeAll()
            if statusCode == 200{
                
                let dataDic = responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSDictionary
                let totalKeys = dataDic.allKeys as! [String]
                
                for key in totalKeys{
                    
                    if key != "0" {
                        
                        let keyDataDic = dataDic.value(forKey: key) as! NSDictionary
                        
                        var tempWORecord = CMTSDataDS()
                        
                        tempWORecord.cmtsId = keyDataDic.value(forKey: RESPONSE_PARAM_NS_CMTS_ID) as! String
                        tempWORecord.name = keyDataDic.value(forKey: RESPONSE_PARAM_NS_CMTSNAME) as! String
                        tempWORecord.fbcModemPolled = keyDataDic.value(forKey: RESPONSE_PARAM_NS_FBC_MODEM_POLLED) as! Int
                        tempWORecord.pollPos = keyDataDic.value(forKey: RESPONSE_PARAM_NS_POLL_POS) as! Int
                        tempWORecord.pollNeg = keyDataDic.value(forKey: RESPONSE_PARAM_NS_POLL_NEG) as! Int
                        tempWORecord.impairmentCount = keyDataDic.value(forKey: RESPONSE_PARAM_NS_IMPAIRMANT_COUNT) as! Int
                        tempWORecord.suckOuts = keyDataDic.value(forKey: RESPONSE_PARAM_NS_SUCKOUT) as! Int
                        tempWORecord.adjacencies = keyDataDic.value(forKey: RESPONSE_PARAM_NS_ADJACENCY) as! Int
                        tempWORecord.resonantPeak = keyDataDic.value(forKey: RESPONSE_PARAM_NS_RESONANT_PEAK) as! Int
                        tempWORecord.noise = keyDataDic.value(forKey: RESPONSE_PARAM_NS_NOISE) as! Int
                        tempWORecord.tilt = keyDataDic.value(forKey: RESPONSE_PARAM_NS_TILT) as! Int
                        tempWORecord.wave = keyDataDic.value(forKey: RESPONSE_PARAM_NS_WAVE) as! Int
                        tempWORecord.rollOff = keyDataDic.value(forKey: RESPONSE_PARAM_NS_ROLLOFF) as! Int
                        tempWORecord.eventCount = keyDataDic.value(forKey: RESPONSE_PARAM_NS_EVENT_COUNT) as! Int
                        
                        self.bundleCMTS.append(tempWORecord)
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
    
    
    @objc func buttonPickerDonePressed(_ sender: UIButton){
        selectedCMTS = self.pickerView.selectedRow(inComponent: 0)
        if selectedCMTS != -1 && bundleCMTS.count > 0{
            let relevantRecord = self.bundleCMTS[selectedCMTS]
            self.textFieldSelectCMTS.text = relevantRecord.name
            self.tableViewCMTSData.reloadData()
            self.setCMTSData(forRow: selectedCMTS)
        }
        
        self.textFieldSelectCMTS.resignFirstResponder()
    }
    
    @objc func buttonPickerCancelPressed(_ sender: UIButton){
        
        self.textFieldSelectCMTS.resignFirstResponder()
    }
    
    func setCMTSData(forRow rowNo: Int) {
        
        let selectedCMTSData = bundleCMTS[rowNo]
        
        CMTS_VALUES.removeAll()
        CMTS_VALUES.append(selectedCMTSData.fbcModemPolled)
        CMTS_VALUES.append(selectedCMTSData.pollPos)
        CMTS_VALUES.append(selectedCMTSData.pollNeg)
        CMTS_VALUES.append(selectedCMTSData.impairmentCount)
        CMTS_VALUES.append(selectedCMTSData.suckOuts)
        CMTS_VALUES.append(selectedCMTSData.adjacencies)
        CMTS_VALUES.append(selectedCMTSData.resonantPeak)
        CMTS_VALUES.append(selectedCMTSData.noise)
        CMTS_VALUES.append(selectedCMTSData.tilt)
        CMTS_VALUES.append(selectedCMTSData.wave)
        CMTS_VALUES.append(selectedCMTSData.rollOff)
        CMTS_VALUES.append(selectedCMTSData.eventCount)
        
        tableViewCMTSData.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return CMTS_VALUES.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellNo = indexPath.section
        let cell = tableView.dequeueReusableCell(withIdentifier: "CMTSDataCell") as! CMTSDataCell
        
        cell.labelCMTSName.text = CMTS_HEADINGS[cellNo]
        cell.labelMACCount.text = "\(CMTS_VALUES[cellNo])"
        
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedSection = indexPath.section
        
        if CMTS_VALUES[selectedSection] > 0 {
            self.performSegue(withIdentifier: "segue-to-ns-details", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue-to-ns-details"{
            
            let selectedIndexData = bundleCMTS[selectedCMTS]
            let destinationController = segue.destination as! NimbleSpectraDetails
            
            destinationController.exposedSelectedCMTSName = selectedIndexData.name
            destinationController.exposedSelectedCMTSId = selectedIndexData.cmtsId
            destinationController.exposedSelectedCMTSProperty = CMTS_HEADINGS[selectedSection]
            destinationController.exposedCMTSImpairmentType = CMTS_IMPAIRMENT_TYPES[selectedSection]
            destinationController.exposedSelectedCMTSValue = CMTS_VALUES[selectedSection]
        }
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
    var cmtsId = ""
    var fbcModemPolled = 0
    var pollPos = 0
    var pollNeg = 0
    var impairmentCount = 0
    var suckOuts = 0
    var adjacencies = 0
    var resonantPeak = 0
    var noise = 0
    var tilt = 0
    var wave = 0
    var rollOff = 0
    var eventCount = 0
}





