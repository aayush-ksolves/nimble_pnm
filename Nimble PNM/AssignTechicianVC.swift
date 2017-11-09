//
//  AssignTechicianVC.swift
//  Nimble PNM
//
//  Created by KSolves on 10/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class AssignTechicianVC : BaseVC, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var exposedOrderId = ""
    var exposedCMTESID = ""
    
    // Outlets
    @IBOutlet weak var textFieldTechnicianName: UITextField!
    @IBOutlet weak var viewSubmit: UIView!
    @IBOutlet weak var tableViewAssignTechnician: UITableView!
    
    @IBOutlet weak var buttonSubmit: UIButton!
    
    @IBOutlet weak var viewTapper: UIView!
    
    fileprivate var bundleTechnician: [TechnicianDetailsDS] = []
    var selectedTechnicianId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadTechnicianList()
        self.configureUIComponents()
    }

    func configureUIComponents() {
        
        tableViewAssignTechnician.estimatedRowHeight = 65
        self.tableViewAssignTechnician.rowHeight = UITableViewAutomaticDimension
        
        tableViewAssignTechnician.backgroundColor = COLOR_WHITE_AS_GREY
        tableViewAssignTechnician.addBorder(withColor: COLOR_WHITE_AS_GREY, withWidth: 1)
        
        tableViewAssignTechnician.register(UINib(nibName: "AssignTechnicianCell", bundle: nil), forCellReuseIdentifier: "AssignTechnicianCell")
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.addTarget(self, action: #selector(showSubmitView))
        self.viewTapper.addGestureRecognizer(tapGesture)
        
        buttonSubmit.addTarget(self, action: #selector(buttonSubmitPressed), for: .touchUpInside)
        
        designTextField()
        showSubmitView()
    }
    
    func designTextField() {
        textFieldTechnicianName.delegate = self
        textFieldTechnicianName.addBorder(withColor: COLOR_BORDER_GRAY_MODIFIED, withWidth: 1)
    }
    
    func showTableViewTechList() {
        tableViewAssignTechnician.isHidden = false
        viewTapper.isHidden = false
        viewSubmit.isHidden = true
    }
    
    @objc func showSubmitView() {
        tableViewAssignTechnician.isHidden = true
        viewTapper.isHidden = true
        viewSubmit.isHidden = false
    }
    
    func loadTechnicianList(){
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_USERNAME: username,
                              REQ_PARAM_AUTH_KEY: authKey
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_WO_TECHNICIAN_LIST, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_FETCH_TECH_LIST, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            let dataArray = responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSArray
            
            self.bundleTechnician.removeAll()
            if statusCode == 200{
                for eachRecord in dataArray{
                    var tempTechRecord = TechnicianDetailsDS()
                    
                    let firstName = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_FIRST_NAME)!)
                    let lastName = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_LAST_NAME)!)
                    
                    tempTechRecord.name = "\(firstName) \(lastName)"
                    tempTechRecord.id = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_ID)!)
                    tempTechRecord.emailId = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_EMAIL_ID)!)
                    tempTechRecord.role = self.getTechnicianRole(userType: String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_USER_TYPE)!))
                    
                    let allowedCMTS = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_ALLOWED_CMTS)!)
                    
                    if allowedCMTS.contains(self.exposedCMTESID) {
                        self.bundleTechnician.append(tempTechRecord)
                    }
                    
                }
                
                self.setInitialTechnician()
                self.tableViewAssignTechnician.reloadData()
                
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
    
    func setInitialTechnician() {
        if bundleTechnician.count > 0 {
            textFieldTechnicianName.text = bundleTechnician[0].name
            selectedTechnicianId = bundleTechnician[0].emailId
        }
    }
    
    func getTechnicianRole(userType: String) -> String {
        
        if userType == "1" {
            return "Admin"
        }else if userType == "2" {
            return "Manager"
        }else if userType == "3" {
            return "Technician"
        } else {
            return ""
        }
    }
    
    @objc func buttonSubmitPressed() {
        
        let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_CONFIRM, message: ALERT_MSG_WO_REASSIGN, buttonTitle1: ALERT_BUTTON_NO, buttonTitle2: ALERT_BUTTON_YES, buttonStyle1: .destructive, buttonStyle2: .default, completionHandler1: {
            action in
            //Do Nothing
        }, completionHandler2: {
            action in
            
            self.performReassignWorkOrder()
        })
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func performReassignWorkOrder() {
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_USERNAME: username,
                              REQ_PARAM_AUTH_KEY: authKey,
                              REQ_PARAM_ORDER_ID: exposedOrderId,
                              REQ_PARAM_REASSIGN_TO: selectedTechnicianId,
                              REQ_PARAM_REASSIGN_BY: username,
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_WO_REASSIGN, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_REASSIGN_WO, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            self.bundleTechnician.removeAll()
            if statusCode == 200{
                
                self.navigationController?.popViewController(animated: false)
                
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
    
    //Table View data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bundleTechnician.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssignTechnicianCell") as! AssignTechnicianCell
        let cellData = bundleTechnician[row]
        
        cell.labelName.text = cellData.name
        cell.labelEmail.text = cellData.emailId
        cell.labelRole.text = cellData.role
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedRow = indexPath.row
        textFieldTechnicianName.text = bundleTechnician[selectedRow].name
        selectedTechnicianId = bundleTechnician[selectedRow].emailId
        showSubmitView()
    }
    
    // Textfield Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldTechnicianName.resignFirstResponder()
        showTableViewTechList()
    }
    
}

fileprivate struct TechnicianDetailsDS {
    var name : String = ""
    var id : String = ""
    var emailId : String = ""
    var role : String = ""
}





