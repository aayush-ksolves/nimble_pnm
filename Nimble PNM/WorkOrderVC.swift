//
//  WorkOrderVC.swift
//  Nimble PNM
//
//  Created by ksolves on 25/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class WorkOrderVC: BaseVC, UITableViewDataSource, UITableViewDelegate {

    var bundleRecord = NSMutableArray()
    
    
    //Status Definitions
    let STATUS_COMPLETED = "completed"
    let STATUS_OPEN = "open"
    let STATUS_PROGRESS = "In Progress"
    let STATUS_CLOSED = "closed"
    
    
    //Outlet
    
    @IBOutlet weak var switchOutletOpen: UISwitch!
    @IBOutlet weak var switchOutletFixed: UISwitch!
    @IBOutlet weak var switchOutletProgress: UISwitch!
    @IBOutlet weak var switchOutletClosed: UISwitch!
    
    
    @IBOutlet weak var tableViewWO: UITableView!
    
   
    @IBOutlet weak var constraintTopTableView: NSLayoutConstraint!
    @IBOutlet weak var viewController: UIView!
    
    @IBOutlet weak var labelWOHeading: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUIComponents()
        self.loadWorkOrderList()
        
        
    }
    
    
    func configureUIComponents(){
        tableViewWO.estimatedRowHeight = 150
        self.tableViewWO.rowHeight = UITableViewAutomaticDimension
        
        self.labelWOHeading.text = TXT_LBL_WO_LIST_HEAD
        
        tableViewWO.register(UINib(nibName: "WO4LineCell", bundle: nil), forCellReuseIdentifier: "customcell_4")
        tableViewWO.register(UINib(nibName: "WO5LineCell", bundle: nil) , forCellReuseIdentifier: "customcell_5")
        
    }
    
    
    func loadWorkOrderList(){
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_USERNAME: username,
                               REQ_PARAM_AUTH_KEY: authKey
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_WO_LIST, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_FETCH_WO, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            let dataArray = responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSArray
            
            self.bundleRecord.removeAllObjects()
            if statusCode == 200{
                for eachRecord in dataArray{
                    var tempWORecord = WorkOrderDS()
                    tempWORecord.orderNo = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_ID)!)
                    tempWORecord.status = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_STATUS)!)
                    
                    if tempWORecord.status == self.STATUS_OPEN{
                       // tempWORecord.address = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_ADDRESS)!)
                        tempWORecord.assignedDate = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_CREATION_DATE)!)
                        tempWORecord.type = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_TYPE)!)
                        
                    }else if tempWORecord.status == self.STATUS_PROGRESS{
                        //tempWORecord.address = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_ADDRESS)!)
                        tempWORecord.assignedDate = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_CREATION_DATE)!)
                        tempWORecord.type = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_TYPE)!)
                        
                    }else if tempWORecord.status == self.STATUS_CLOSED{
                        //tempWORecord.address = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_ADDRESS)!)
                        tempWORecord.assignedDate = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_CREATION_DATE)!)
                        tempWORecord.type = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_TYPE)!)
                        
                    }else if tempWORecord.status == self.STATUS_COMPLETED{
                        //tempWORecord.address = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_ADDRESS)!)
                        tempWORecord.assignedDate = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_CREATION_DATE)!)
                        tempWORecord.type = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_TYPE)!)
                        
                    }else{
                        print("This shouldn't have happened")
                    }
                    
                    
                    self.bundleRecord.add(tempWORecord)
                }
            self.tableViewWO.reloadData()
            
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
    
    
    
    
    //MARK: UITable View Delegates And Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return bundleRecord.count
        return bundleRecord.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellNo = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell_4") as! WO4LineCell
        return cell;
        
    }
        
        
    @IBAction func btnActionLogout(_ sender: Any) {
        self.performLogout()
    }
    
    @IBAction func switchChangedForOpen(_ sender: Any) {
        let switchForOpen = sender as! UISwitch
        if switchForOpen.isOn{
            
        }else{
            
        }
        
    }
    
    @IBAction func switchChangedForFixed(_ sender: Any) {
        let switchForFixed = sender as! UISwitch
        if switchForFixed.isOn{
            
        }else{
            
        }
        
    }
    
    @IBAction func switchChangedProgress(_ sender: Any) {
        let switchForProgress = sender as! UISwitch
        if switchForProgress.isOn{
            
        }else{
            
        }
        
    }
    
    @IBAction func switchChangedForClosed(_ sender: Any) {
        let switchForClosed = sender as! UISwitch
        if switchForClosed.isOn{
            
        }else{
            
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: {
            context in
            if size.width > size.height{
                //Rotating To Landscape
                self.constraintTopTableView.constant = -88;
            }else{
                //Rotating To Potrait
                self.constraintTopTableView.constant = 16;
            }
        }, completion: {
            context in
            
        })
    }
    
    
    
    
}

fileprivate struct WorkOrderDS{
    var orderNo : String = ""
    var type : String = ""
    var status : String = ""
    var assignedDate : String = ""
    var address : String = ""
}





