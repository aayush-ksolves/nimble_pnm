//
//  WorkOrderVC.swift
//  Nimble PNM
//
//  Created by ksolves on 25/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class WorkOrderVC: BaseVC, UITableViewDataSource, UITableViewDelegate {

    fileprivate var bundleRecord: [WorkOrderDS] = []
    fileprivate var tempBundleRecord: [WorkOrderDS] = []
    
    //Status Definitions
    let STATUS_FIXED = "FIXED"
    let STATUS_OPEN = "OPEN"
    let STATUS_PROGRESS = "IN PROGRESS"
    let STATUS_CLOSED = "CLOSED"
    
    let COLOR_FIXED = UIColor.green
    let COLOR_OPEN = UIColor.red
    let COLOR_IN_PROGRESS = UIColor.yellow
    let COLOR_CLOSED = UIColor.blue
    
    var isOpenSelected = true
    var isFixedSelected = true
    var isInProgressSelected = true
    var isClosedSelected = true
    
    let footerView = UIView()
    var selectedIndex = -1
    
    @IBOutlet weak var sementedControlTop: UISegmentedControl!
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadWorkOrderList()
    }
    
    func configureUIComponents(){
        tableViewWO.estimatedRowHeight = 150
        self.tableViewWO.rowHeight = UITableViewAutomaticDimension
        
        tableViewWO.backgroundColor = COLOR_WHITE_AS_GREY
        footerView.backgroundColor = COLOR_NONE
        
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
            
            self.bundleRecord.removeAll()
            if statusCode == 200{
                for eachRecord in dataArray{
                    var tempWORecord = WorkOrderDS()
                    
                    if String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_TYPE)!) != "node" {
                        
                        tempWORecord.status = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_STATUS)!).uppercased()
                        
                        tempWORecord.type = "Modem"
                        tempWORecord.orderNo = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_ID)!)
                        tempWORecord.assignedTo = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_ASSIGNED_TO)!)
                        tempWORecord.address = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_ADDRESS)!)
                        tempWORecord.assignedDate = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_CREATION_DATE)!)
                        tempWORecord.macAddress = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_MAC_ADDRESS)!)
                        tempWORecord.assignedBy = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_ASSIGNED_BY)!)
                        tempWORecord.customerName = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_CUST_NAME)!)
                        tempWORecord.contact = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_PHONE_NUMBER)!)
                        tempWORecord.cmtsId = String(describing:(eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_WO_CMTS_ID)!)
                        tempWORecord.technicianFeedback = (eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_TECHNICIAN_FEEDBACK)! as! NSArray
                        tempWORecord.photos = (eachRecord as! NSDictionary).value(forKey: RESPONSE_PARAM_PHOTOS)! as! NSArray
                        
                        if tempWORecord.status == self.STATUS_OPEN{
                            tempWORecord.sideBarColor = self.COLOR_OPEN
                            tempWORecord.numberOfSections = 1
                            
                        }else if tempWORecord.status == self.STATUS_PROGRESS{
                            tempWORecord.sideBarColor = self.COLOR_IN_PROGRESS
                            tempWORecord.numberOfSections = 2
                            
                        }else if tempWORecord.status == self.STATUS_CLOSED{
                            tempWORecord.sideBarColor = self.COLOR_CLOSED
                            tempWORecord.numberOfSections = 1
                            
                        }else if tempWORecord.status == self.STATUS_FIXED{
                            tempWORecord.sideBarColor = self.COLOR_FIXED
                            tempWORecord.numberOfSections = 2
                            
                        }else{
                            print("This shouldn't have happened")
                        }
                        
                        
                        self.bundleRecord.append(tempWORecord)
                    }
                    
                }
                
            self.tempBundleRecord = self.bundleRecord
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
        return tempBundleRecord.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return bundleRecord.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == tempBundleRecord.count - 1 {
            return 0
        }else {
            return 5
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellNo = indexPath.section
        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell_5") as! WO5LineCell
        let cellData = tempBundleRecord[cellNo]
        
        cell.labelOrderId.text = cellData.orderNo
        cell.labelType.text = cellData.type
        cell.labelAddress.text = cellData.address
        cell.labelAssignedDate.text = cellData.assignedDate
        cell.labelAssignedTo.text = cellData.assignedTo
        cell.labelSideBar.backgroundColor = cellData.sideBarColor
        
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.section
        self.performSegue(withIdentifier: "segue-to-work-order-details", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue-to-work-order-details"{
            
            let selectedIndexData = tempBundleRecord[selectedIndex]
            
            let destinationController = segue.destination as! WorkOrderModemDetails
            
            destinationController.exposedOrderID = selectedIndexData.orderNo
            
        }
    }
    
    
    @IBAction func btnActionLogout(_ sender: Any) {
        self.performLogout()
    }
    
    @IBAction func switchChangedForOpen(_ sender: Any) {
        let switchForOpen = sender as! UISwitch
        if switchForOpen.isOn{
            isOpenSelected = true
        }else{
            isOpenSelected = false
        }
        
        filterData()
    }
    
    @IBAction func switchChangedForFixed(_ sender: Any) {
        let switchForFixed = sender as! UISwitch
        if switchForFixed.isOn{
            isFixedSelected = true
        }else{
            isFixedSelected = false
        }
        
        filterData()
    }
    
    @IBAction func switchChangedProgress(_ sender: Any) {
        let switchForProgress = sender as! UISwitch
        if switchForProgress.isOn{
            isInProgressSelected = true
        }else{
            isInProgressSelected = false
        }
        
        filterData()
    }
    
    @IBAction func switchChangedForClosed(_ sender: Any) {
        let switchForClosed = sender as! UISwitch
        if switchForClosed.isOn{
            isClosedSelected = true
        }else{
            isClosedSelected = false
        }
        
        filterData()
    }
    
    func filterData() {
        
        tempBundleRecord.removeAll()
        
        for data in bundleRecord {
            
            if data.status == STATUS_OPEN && isOpenSelected{
                tempBundleRecord.append(data)
            } else if data.status == STATUS_FIXED && isFixedSelected{
                tempBundleRecord.append(data)
            } else if data.status == STATUS_CLOSED && isClosedSelected{
                tempBundleRecord.append(data)
            } else if data.status == STATUS_PROGRESS && isInProgressSelected{
                tempBundleRecord.append(data)
            } else {
                print("Dont append data")
            }
            
        }
        
        tableViewWO.reloadData()
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
    var assignedTo : String = ""
    var assignedBy : String = ""
    var customerName : String = ""
    var contact : String = ""
    var macAddress : String = ""
    var cmtsId : String = ""
    var numberOfSections = 1
    var technicianFeedback : NSArray!
    var photos: NSArray!
    var sideBarColor : UIColor = UIColor.white
}





