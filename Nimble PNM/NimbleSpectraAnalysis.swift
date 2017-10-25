//
//  NimbleSpectraAnalysis.swift
//  Nimble PNM
//
//  Created by KSolves on 24/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class NimbleSpectraAnalysis : BaseVC, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var exposedMacAddress = ""
    var exposedMTimestamp = ""
    var exposedCMTSId = ""
    var exposedCMTSName = ""
    
    @IBOutlet weak var tableViewSpectraAnalysis: UITableView!
    @IBOutlet weak var buttonPort4: UIButton!
    @IBOutlet weak var buttonPort3: UIButton!
    @IBOutlet weak var buttonPort2: UIButton!
    @IBOutlet weak var buttonPort1: UIButton!
    @IBOutlet weak var constraintHeightViewButtonContainer: NSLayoutConstraint!
    @IBOutlet weak var viewButtonsContainer: UIView!
    @IBOutlet weak var textFieldFilterByDate: UITextField!
    
    fileprivate var bundleSpectraDetails = SpectraAnalysisDetailsDS()
    var pickerView : UIPickerView!
    var bundleTimestamp: [String] = []
    
    var footerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUIComponents()
    }
    
    func configureUIComponents() {
        
        buttonPort1.tag = 1
        buttonPort2.tag = 2
        buttonPort3.tag = 3
        buttonPort4.tag = 4
        
        buttonPort1.addTarget(self, action: #selector(buttonPortPressed(_:)), for: .touchUpInside)
        buttonPort2.addTarget(self, action: #selector(buttonPortPressed(_:)), for: .touchUpInside)
        buttonPort3.addTarget(self, action: #selector(buttonPortPressed(_:)), for: .touchUpInside)
        buttonPort4.addTarget(self, action: #selector(buttonPortPressed(_:)), for: .touchUpInside)
        
        tableViewSpectraAnalysis.backgroundColor = COLOR_WHITE_AS_GREY
        footerView.backgroundColor = UIColor.clear
        
        tableViewSpectraAnalysis.estimatedRowHeight = 150
        self.tableViewSpectraAnalysis.rowHeight = UITableViewAutomaticDimension
        
        tableViewSpectraAnalysis.register(UINib(nibName: "SpectraAnalysisChartCell", bundle: nil), forCellReuseIdentifier: "SpectraAnalysisChartCell")
        tableViewSpectraAnalysis.register(UINib(nibName: "SpectraAnalysisDetails", bundle: nil), forCellReuseIdentifier: "SpectraAnalysisDetails")
        
        designPickerView()
        loadModemStatistics()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if size.width > size.height {
            self.hideViewButtonContainer()
            
        } else {
            self.showViewButtonContainer()
        }
    }
    
    func hideViewButtonContainer() {
        
        constraintHeightViewButtonContainer.constant = 0
        viewButtonsContainer.isHidden = true
        
        UIView.animate(withDuration: 0.5, animations: {
            
        }, completion: {
            completed in
            
        })
    }
    
    func showViewButtonContainer() {
        
        constraintHeightViewButtonContainer.constant = 40
        
        UIView.animate(withDuration: 0.5, animations: {
            
        }, completion: {
            completed in
            
            self.viewButtonsContainer.isHidden = false
        })
    }
    
    func designPickerView() {
        
        let pickerHolder = Bundle.main.loadNibNamed("CustomPickerView", owner: self, options: nil)?[0] as! CustomPickerView
        
        pickerHolder.labelPickerHeading.text = ""
        pickerHolder.buttonOutletDone.addTarget(self, action: #selector(buttonPickerDonePressed(_:)), for: .touchUpInside)
        pickerHolder.buttonOutletCancel.addTarget(self, action: #selector(buttonPickerCancelPressed(_:)), for: .touchUpInside)
        
        pickerView = pickerHolder.pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.textFieldFilterByDate.inputView = pickerHolder
        
    }
    
    func buttonPickerDonePressed(_ sender: UIButton){
        let selectedTimestamp = self.pickerView.selectedRow(inComponent: 0)
        if selectedTimestamp != -1 && bundleTimestamp.count > 0{
            self.textFieldFilterByDate.text = self.bundleTimestamp[selectedTimestamp]
            self.tableViewSpectraAnalysis.reloadData()
        }
        
        self.textFieldFilterByDate.resignFirstResponder()
    }
    
    func buttonPickerCancelPressed(_ sender: UIButton){
        
        self.textFieldFilterByDate.resignFirstResponder()
    }
    
    func loadModemStatistics() {
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_USERNAME: username,
                              REQ_PARAM_AUTH_KEY: authKey,
                              REQ_PARAM_TIMESTAMP: exposedMTimestamp,
                              REQ_PARAM_CMTS_ID: exposedCMTSId,
                              REQ_PARAM_MAC_ADDRESS: exposedMacAddress
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_NIMBLE_SPECTRA_GET_CHART_DATA, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_FETCH_SPECTRA_DATA, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                
                let dataDic = responseDict.value(forKey: RESPONSE_PARAM_DATA)! as! NSDictionary
                
                var tempSpectraDetails = SpectraAnalysisDetailsDS()
                
                tempSpectraDetails.CMTSName = self.exposedCMTSName
                tempSpectraDetails.macAddress = String(describing: dataDic.value(forKey: RESPONSE_PARAM_MAC_ADDRESS)!)
                tempSpectraDetails.model = String(describing: dataDic.value(forKey: RESPONSE_PARAM_MODEM_NUMBER)!)
                tempSpectraDetails.IP = String(describing: dataDic.value(forKey: RESPONSE_PARAM_IP_ADDRESS)!)
                tempSpectraDetails.vendor = String(describing: dataDic.value(forKey: RESPONSE_PARAM_VENDOR)!)
                tempSpectraDetails.power = String(describing: dataDic.value(forKey: RESPONSE_PARAM_TOTAL_POWER)!)
                tempSpectraDetails.node = String(describing: dataDic.value(forKey: RESPONSE_PARAM_INTERFACE_NAME)!)
                tempSpectraDetails.pollTime = String(describing: dataDic.value(forKey: RESPONSE_PARAM_TIME_STAMP)!)
                
                self.bundleSpectraDetails = tempSpectraDetails
                
                self.bundleTimestamp.append("A")
                self.bundleTimestamp.append("B")
                self.bundleTimestamp.append("C")
                self.bundleTimestamp.append("D")
                
                self.buttonPort1.sendActions(for: .touchUpInside)
                
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
    
    func buttonPortPressed(_ sender: UIButton) {
        
        setAllButtonBackGroundClear()
        sender.backgroundColor = UIColor.yellow
        
        let tag = sender.tag
        
        if tag == 1 {
            actionButtonPort1Pressed()
        }else if tag == 2 {
            actionButtonPort2Pressed()
        }else if tag == 3 {
            actionButtonPort3Pressed()
        }else if tag == 4 {
            actionButtonPort4Pressed()
        }
        
    }
    
    func actionButtonPort1Pressed() {
        print("PORT 1 pressed")
        
        tableViewSpectraAnalysis.reloadData()
    }
    
    func actionButtonPort2Pressed() {
        print("PORT 2 pressed")
    }
    
    func actionButtonPort3Pressed() {
        print("PORT 3 pressed")
    }
    
    func actionButtonPort4Pressed() {
        print("PORT 4 pressed")
    }
    
    func setAllButtonBackGroundClear() {
        
        buttonPort1.backgroundColor = UIColor.clear
        buttonPort2.backgroundColor = UIColor.clear
        buttonPort3.backgroundColor = UIColor.clear
        buttonPort4.backgroundColor = UIColor.clear
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionNo = indexPath.section
        
        if sectionNo == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpectraAnalysisChartCell") as! SpectraAnalysisChartCell
            
            
            return cell
            
        } else if sectionNo == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpectraAnalysisDetails") as! SpectraAnalysisDetails
            let cellData = bundleSpectraDetails
            
            cell.labelCMTS.text = cellData.CMTSName
            cell.labelMAC.text = cellData.macAddress
            cell.labelModem.text = cellData.model
            cell.labelIP.text = cellData.IP
            cell.labelVendor.text = cellData.vendor
            cell.labelPower.text = cellData.power
            cell.labelNode.text = cellData.node
            cell.labelPollTime.text = cellData.pollTime
            
            cell.buttonRescan.addTarget(self, action: #selector(buttonRescanPressed), for: .touchUpInside)
            
            return cell;
            
        } else {
            
            let cell = UITableViewCell()
            
            return cell
        }
        
    }
    
    func buttonRescanPressed() {
        
    }
    
    
    @IBAction func btnActionLogout(_ sender: Any) {
        
        self.performLogout()
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bundleTimestamp.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return bundleTimestamp[row]
    }
    
}

fileprivate struct SpectraAnalysisDetailsDS {
    
    var CMTSName = ""
    var macAddress = ""
    var model = ""
    var IP = ""
    var vendor = ""
    var power = ""
    var node = ""
    var pollTime = ""
    
}




