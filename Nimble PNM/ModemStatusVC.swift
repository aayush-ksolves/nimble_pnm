//
//  ModemStatusVC.swift
//  Nimble PNM
//
//  Created by ksolves on 23/08/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

//Orientation Type == 0 //For Potrait
//Orientation Type == 1 //For Landscape

class ModemStatusVC: BaseVC {

    @IBOutlet weak var viewGovernerForHeight: UIView!
    @IBOutlet weak var viewBCTableHolder: UIView!
    
    @IBOutlet weak var constraintCententViewHeightForMainCV: NSLayoutConstraint!
    @IBOutlet weak var viewMSTableHolder: UIView!
    
    @IBOutlet weak var viewDSTableHolder: UIView!
    
    @IBOutlet weak var constraintMSTableContentViewWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var constraintDSTableContentViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var btnOutletLogout: UIButton!
    
    var MinusHeadingForTable = 36.0
    
    var dataBundle : NSDictionary!
    var bundleBirthCertificate : [BirthCertificateDS] = []
    var tableHeaderModemStatus : TableHeaderDS!
    var bundleDataDSTable : [DownstreamDS] = []
    var bundleDataMSTable : [ModemStatusDS] = []
    var tableHeaderDS : TableHeaderDS!
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.configureUIComponents()
        self.fireDataFetchingService()
    }
    
    var totalMSrows : Int = 0
    var totalMScoloumns : Int = 0
    
    var totalDSrows : Int = 0
    var totalDScoloumns : Int = 0
    
    
    
    
    
    @IBOutlet weak var constraintBCHeight: NSLayoutConstraint!

    @IBOutlet weak var constraintDownstreamHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintModemStatusHeight: NSLayoutConstraint!
    
    func configureUIComponents(){
        self.btnOutletLogout.imageView?.contentMode = .scaleAspectFit
        
        
        
    }
    
    
    //Hansling Screen Orienatations and Table Plotting
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("a")
        coordinator.animate(alongsideTransition: {
            context in
            
            
            
        }, completion: {
            context in
        print("c")
        })
        
        print("d")
        
    }
    
    func handleViewRotationToPotrait(){
        self.plotDownstreamTable(forOrientationType: 0)

    }
    
    
    func handleViewRotationToLandscape(){
        self.plotDownstreamTable(forOrientationType: 1)
        
    }
    
    func plotBirthCertificateTable(forOrientationType : Int){
        
        for eachSubview in self.viewBCTableHolder.subviews{
            eachSubview.removeFromSuperview()
        }
        
        let paddingHorizontal = 8.0
        let paddingVertical = 4.0
        let gappingVertical = 2.0
        
        let totalSpacing = 24.0
        let firstElementWidth: Double = Double((Double(self.viewBCTableHolder.frame.size.width) - totalSpacing)/3)
        let secondElementWidth: Double = (Double(self.viewBCTableHolder.frame.size.width) - firstElementWidth - totalSpacing)
        
        
        let constantX1 = paddingHorizontal
        let constantX2 = (2*paddingHorizontal) + Double(firstElementWidth)
        
        var variableY = paddingVertical
        
        //Y Will Change
        for eachRecord in bundleBirthCertificate{
            
            //Create Temporary label to determine size
           
            let sizeDeterminant = NSString(string: eachRecord.value).boundingRect(with: CGSize(width: CGFloat(secondElementWidth), height: CGFloat.greatestFiniteMagnitude) , options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: SIZE_FONT_SMALL)], context: nil)
            let heightToSet = ceil(Double(sizeDeterminant.height))
            
            let labelDefiner = UILabel(frame: CGRect(x: constantX1, y: variableY, width: firstElementWidth, height: heightToSet))
            let labelValue = UILabel(frame: CGRect(x: constantX2, y: variableY, width: secondElementWidth, height: heightToSet))
            
            labelDefiner.text = eachRecord.definer
            labelValue.text = eachRecord.value
            
            labelDefiner.font = UIFont.systemFont(ofSize: SIZE_FONT_SMALL)
            labelValue.font = UIFont.systemFont(ofSize: SIZE_FONT_SMALL)
            labelValue.numberOfLines = 0;
            
            labelValue.textAlignment = .left
                
                
            variableY += heightToSet + gappingVertical
            
            self.viewBCTableHolder.addSubview(labelDefiner)
            self.viewBCTableHolder.addSubview(labelValue)
        }
        
        let totalHeight = variableY + paddingVertical
        
        self.constraintBCHeight.constant = CGFloat(MinusHeadingForTable + totalHeight)
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
        })
        
        self.setMainScrollViewContentHeight()
        
        
    }
    
    
    func plotModemStatusTable(forOrientationType : Int){
        
        for eachSubview in self.viewMSTableHolder.subviews{
            eachSubview.removeFromSuperview()
        }
        
        let paddingHorizontal = 8.0
        var gappingHorizontal = 2.0
        let paddingVertical = 4.0
        let gappingVertical = 2.0
        
        
        var variableX = paddingHorizontal
        var variableY = paddingVertical
        
        let minimumWidthOfCell = 80.0
        let computedWidthOfCell = (Double(SCREEN_SIZE.width - 16) - (2 * paddingHorizontal) - (Double(totalMScoloumns - 1) * Double(gappingHorizontal)))/Double(totalMScoloumns)

        var finalWidthOfCell : Double!
        
        if computedWidthOfCell >= minimumWidthOfCell{
            finalWidthOfCell = computedWidthOfCell
            gappingHorizontal = 0
        }else{
            finalWidthOfCell = minimumWidthOfCell
        }
        
        let heightOfCell = 20.0
        
        var scrollContentWidthDeterminer = Double()
        
        
        
        for i in 0..<totalMSrows{
            
            
            
            for j in 0 ..< totalMScoloumns{
                
                var labelForCell : UILabel!
                //DataSource Usage Governance
                if i == 0{
                    //Using Table Header DS as datasource
                    labelForCell = UILabel(frame: CGRect(x: variableX, y: variableY, width: finalWidthOfCell, height: heightOfCell))
                    labelForCell.text = (tableHeaderModemStatus.values[j] as! String)
                    labelForCell.font = UIFont.systemFont(ofSize: SIZE_FONT_SMALL)
                    labelForCell.textAlignment = .center
                    labelForCell.backgroundColor = UIColor.gray
                    
                }else{
                    //Using Modem DS as datasource
                    labelForCell = UILabel(frame: CGRect(x: variableX, y: variableY, width: finalWidthOfCell, height: heightOfCell))
                    labelForCell.font = UIFont.systemFont(ofSize: SIZE_FONT_SMALL)
                    labelForCell.backgroundColor = UIColor.green
                    
                    if j == 0{
                        labelForCell.text = "\(bundleDataMSTable[i-1].recordName) (\(bundleDataMSTable[i-1].unit)) "
                        labelForCell.textAlignment = .left

                    }else{
                        labelForCell.text = bundleDataMSTable[i-1].entireFrequencyRecord[j-1].value
                        labelForCell.textAlignment = .center

                        
                    }
                    
                
                }
                self.viewMSTableHolder.addSubview(labelForCell)
                
                
                //Incrementing X
                variableX += finalWidthOfCell + gappingHorizontal
                scrollContentWidthDeterminer = variableX
                
            }
            
            //Incrementing Y and Adjusting X
            variableX = paddingHorizontal
            variableY += heightOfCell + gappingVertical
            
            
        }
        
        let totalHeight = variableY + paddingVertical
        let totalWidth = scrollContentWidthDeterminer + paddingHorizontal
        
        
        
        self.constraintMSTableContentViewWidth.constant = CGFloat(totalWidth)
        self.constraintModemStatusHeight.constant = CGFloat(MinusHeadingForTable + totalHeight)
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
        })
        
        self.setMainScrollViewContentHeight()

    }
    
    
    func plotDownstreamTable(forOrientationType : Int){
        for eachSubview in self.viewDSTableHolder.subviews{
            eachSubview.removeFromSuperview()
        }
        
        let paddingHorizontal = 8.0
        var gappingHorizontal = 2.0
        let paddingVertical = 4.0
        let gappingVertical = 2.0
        
        
        var variableX = paddingHorizontal
        var variableY = paddingVertical
        
        let minimumWidthOfCell = 80.0
        let computedWidthOfCell = (Double(SCREEN_SIZE.width - 16) - (2 * paddingHorizontal) - ( Double(totalDScoloumns - 1) * Double(gappingHorizontal)))/Double(totalDScoloumns)
        
        var finalWidthOfCell : Double!
        
        if computedWidthOfCell >= minimumWidthOfCell{
            finalWidthOfCell = computedWidthOfCell
            gappingHorizontal = 0
        }else{
            finalWidthOfCell = minimumWidthOfCell
        }
        
        let heightOfCell = 20.0
        
        var scrollContentWidthDeterminer = Double()
        
        
        
        for i in 0..<totalDSrows{
            
            for j in 0 ..< totalDScoloumns{
                
                var labelForCell : UILabel!
                //DataSource Usage Governance
                if i == 0{
                    //Using Table Header DS as datasource
                    labelForCell = UILabel(frame: CGRect(x: variableX, y: variableY, width: finalWidthOfCell, height: heightOfCell))
                    labelForCell.text = (tableHeaderDS.values[j] as! String)
                    labelForCell.font = UIFont.systemFont(ofSize: SIZE_FONT_SMALL)
                    labelForCell.textAlignment = .center
                    labelForCell.backgroundColor = UIColor.gray
                    
                }else{
                    //Using Modem DS as datasource
                    labelForCell = UILabel(frame: CGRect(x: variableX, y: variableY, width: finalWidthOfCell, height: heightOfCell))
                    labelForCell.font = UIFont.systemFont(ofSize: SIZE_FONT_SMALL)
                    labelForCell.backgroundColor = UIColor.green
                    
                    if j == 0{
                        labelForCell.text = "\(i)";
                        labelForCell.textAlignment = .center
                        
                    }else if j == 1{
                        labelForCell.text = bundleDataDSTable[j-1].frequency
                        labelForCell.textAlignment = .center
                        
                    }else if j == 2{
                        labelForCell.text = bundleDataDSTable[j-1].power
                        labelForCell.textAlignment = .center
                        
                    }else if j == 3{
                        labelForCell.text = bundleDataDSTable[j-1].mer
                        labelForCell.textAlignment = .center
                        
                    }else if j == 4{
                        labelForCell.text = bundleDataDSTable[j-1].cmCorrCw
                        labelForCell.textAlignment = .center
                        
                    }else if j == 5{
                        labelForCell.text = bundleDataDSTable[j-1].cmUnCorrCw
                        labelForCell.textAlignment = .center
                        
                    }
                    
                    
                }
                self.viewDSTableHolder.addSubview(labelForCell)
                
                
                //Incrementing X
                variableX += finalWidthOfCell + gappingHorizontal
                scrollContentWidthDeterminer = variableX
                
            }
            
            //Incrementing Y and Adjusting X
            variableX = paddingHorizontal
            variableY += heightOfCell + gappingVertical
            
            
        }
        
        let totalHeight = variableY + paddingVertical
        let totalWidth = scrollContentWidthDeterminer + paddingHorizontal
        
        
        
        self.constraintDSTableContentViewWidth.constant = CGFloat(totalWidth)
        self.constraintDownstreamHeight.constant = CGFloat(MinusHeadingForTable + totalHeight)
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
        })

        self.setMainScrollViewContentHeight()
        
        
    }
    
    func getOrientationCode() -> Int{
        if SCREEN_SIZE.width > SCREEN_SIZE.height{
            return 1
        }else{
            return 0
        }
    }
    
    
    func fireDataFetchingService(){
        //Extracting Value for Mac Address and CMTS ID
       // let cmtsID = dataBundle.value(forKey: RESPONSE_PARAM_CMTS_ID) as! String
        //let modemMac = dataBundle.value(forKey: RESPONSE_PARAM_MODEM_MAC) as! String
        
        let cmtsID = "e4da3b7f-bbce-2345-d777-2b0674a318d5"
        let modemMac = "002624829dc4"
        
        //self.getModemStatus(withMacAddress: modemMac, withCTMSID: cmtsID)
        
        totalDSrows = 6
        totalDScoloumns = 6
        //Creating First Record for the table
        var tempTableHeaderDS = TableHeaderDS()
        
        tempTableHeaderDS.values.add("Downstream")
        tempTableHeaderDS.values.add("Freq(MHz)")
        tempTableHeaderDS.values.add("Power(dBmV)")
        tempTableHeaderDS.values.add("MER(dB)")
        tempTableHeaderDS.values.add("CM Corr Cw(%)")
        tempTableHeaderDS.values.add("CM Un Corr Cw(%)")
        
        
        //Global Variable Assignment
        self.tableHeaderDS = tempTableHeaderDS

        for i in 0...4{
            var tempRecord = DownstreamDS()
            
            tempRecord.frequency = "\(i)"
            tempRecord.power = "\(i)"
            tempRecord.mer = "\(i)"
            tempRecord.cmCorrCw = "\(i)"
            tempRecord.cmUnCorrCw = "\(i)"
            
            self.bundleDataDSTable.append(tempRecord)
            
        }
        
        
        
        
        //self.plotDownstreamTable(forOrientationType: getOrientationCode())
        
        
        //self.getDownstreamData(withMacAddress: modemMac)
        
    }
    
    func getModemStatus(withMacAddress mac : String, withCTMSID cmtsID : String){
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username,
                              REQ_PARAM_MAC_ADDRESS : mac,
                              REQ_PARAM_CMTSID : cmtsID
            
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_INSTALL_GET_MODEM_STATUS, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_GETTING_MODEM_STATUS, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            
            if statusCode == 200{
                
                let relevantDataBundle = (responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSArray)[0] as! NSDictionary
                
                //Loading Values which determines the Birth Certificate Section values
                let birthCertificateDict = relevantDataBundle.value(forKey: RESPONSE_PARAM_BC) as! NSDictionary
                
                var temp1 = BirthCertificateDS()
                let relevantInfo1 = birthCertificateDict.value(forKey: RESPONSE_PARAM_MAC_ADDRESS) as! NSDictionary
                temp1.definer = String(describing: relevantInfo1.value(forKey: RESPONSE_PARAM_NAME)!)
                temp1.value = String(describing: relevantInfo1.value(forKey: RESPONSE_PARAM_VALUE)!)
                
                var temp2 = BirthCertificateDS()
                let relevantInfo2 = birthCertificateDict.value(forKey: RESPONSE_PARAM_FINAL_STATUS) as! NSDictionary
                temp2.definer = String(describing: relevantInfo2.value(forKey: RESPONSE_PARAM_NAME)!)
                temp2.value = String(describing: relevantInfo2.value(forKey: RESPONSE_PARAM_VALUE)!)
                
                
                var temp3 = BirthCertificateDS()
                let relevantInfo3 = birthCertificateDict.value(forKey: RESPONSE_PARAM_REASON) as! NSDictionary
                temp3.definer = String(describing: relevantInfo3.value(forKey: RESPONSE_PARAM_NAME)!)
                temp3.value = String(describing: relevantInfo3.value(forKey: RESPONSE_PARAM_VALUE)!)
                
                
                var temp4 = BirthCertificateDS()
                let relevantInfo4 = birthCertificateDict.value(forKey: RESPONSE_PARAM_INSTALLED_BY_USER) as! NSDictionary
                temp4.definer = String(describing: relevantInfo4.value(forKey: RESPONSE_PARAM_NAME)!)
                temp4.value = String(describing: relevantInfo4.value(forKey: RESPONSE_PARAM_VALUE)!)
                
                var temp5 = BirthCertificateDS()
                let relevantInfo5 = birthCertificateDict.value(forKey: RESPONSE_PARAM_INSTALLATION_DATE) as! NSDictionary
                temp5.definer = String(describing: relevantInfo5.value(forKey: RESPONSE_PARAM_NAME)!)
                temp5.value = String(describing: relevantInfo5.value(forKey: RESPONSE_PARAM_VALUE)!)
                
                //Adding Everything in the bundle
                self.bundleBirthCertificate.append(temp1)
                self.bundleBirthCertificate.append(temp2)
                self.bundleBirthCertificate.append(temp3)
                self.bundleBirthCertificate.append(temp4)
                self.bundleBirthCertificate.append(temp5)
                
                

                //Loading Values which determines the Modem status Section values
                let modemStatusArray = relevantDataBundle.value(forKey: RESPONSE_PARAM_DATA) as! NSArray
                self.totalMSrows = modemStatusArray.count + 1
                if modemStatusArray.count > 0{
                    self.totalMScoloumns = ((modemStatusArray[0] as! NSDictionary).value(forKey: RESPONSE_PARAM_FREQUENCIES) as! NSArray).count + 1
                }else{
                    self.totalMScoloumns = 1
                }
                
                //Creating First Record for the table
                var tempTableHeaderModemStatus = TableHeaderDS()
                let frequencyBundle = ((modemStatusArray[0] as! NSDictionary).value(forKey: RESPONSE_PARAM_FREQUENCIES) as! NSArray)
                
                tempTableHeaderModemStatus.values.add("Label")
                for eachFrequecy in frequencyBundle{
                    tempTableHeaderModemStatus.values.add(String(describing: (eachFrequecy as! NSDictionary).value(forKey: RESPONSE_PARAM_FREQ)!))
                }
                
                //Global Variable Assignment
                self.tableHeaderModemStatus = tempTableHeaderModemStatus
                
                
                //Filling Values For further assignment
                //Outer Iteration
                for eachRecord in modemStatusArray{
                    let castedRecord = (eachRecord as! NSDictionary)
                    var tempRecord = ModemStatusDS()
                    
                    let commonDict = castedRecord.value(forKey: RESPONSE_PARAM_COMMON) as! NSDictionary
                    let commonValue = String(describing: commonDict.value(forKey: RESPONSE_PARAM_VALUE)!)
                    let commonStatus = String(describing: commonDict.value(forKey: RESPONSE_PARAM_STATUS)!)
                    tempRecord.commonValue = commonValue
                    tempRecord.commonStatus = commonStatus
                    
                    let isVisible = castedRecord.value(forKey: RESPONSE_PARAM_IS_VISIBLE) as! Bool
                    let unit = String(describing: castedRecord.value(forKey: RESPONSE_PARAM_UNIT)!)
                    tempRecord.isVisible = isVisible
                    tempRecord.unit = unit
                    
                    let name = String(describing: castedRecord.value(forKey: RESPONSE_PARAM_NAME)!)
                    tempRecord.recordName = name
                    
                    let frequenciesArray = castedRecord.value(forKey: RESPONSE_PARAM_FREQUENCIES) as! NSArray
                    
                    //Inner Iteration
                    for eachFrequency in frequenciesArray{
                        let frequencyValue = String(describing: (eachFrequency as! NSDictionary).value(forKey: RESPONSE_PARAM_VALUE)!)
                        let frequencyStatus = String(describing: (eachFrequency as! NSDictionary).value(forKey: RESPONSE_PARAM_STATUS)!)
                        let tempFrequency = FrequencyDS(value: frequencyValue, status: frequencyStatus)
                        tempRecord.entireFrequencyRecord.append(tempFrequency)
                        
                    }
                    
                    self.bundleDataMSTable.append(tempRecord)
                    
                }
                
                //Prepare the Custom Table View
                let orientationCode = self.getOrientationCode()
                self.plotBirthCertificateTable(forOrientationType: orientationCode)
                self.plotModemStatusTable(forOrientationType: orientationCode)
                
                
                
                
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
    
    func getDownstreamData(withMacAddress mac : String){
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username,
                              REQ_PARAM_MAC_ADDRESS : mac,
                              REQ_PARAM_PURPOSE : "install_cm"
            
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_INSTALL_GET_DS_DATA, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_GETTING_DS_DATA, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                
                //Loading Values which determines the Modem status Section values
                let modemDSArray = (responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSArray)[0] as! NSArray
                self.totalDSrows = modemDSArray.count + 1
                self.totalMScoloumns = 6
                
                //Creating First Record for the table
                var tempTableHeaderDS = TableHeaderDS()
                
                tempTableHeaderDS.values.add("Downstream")
                tempTableHeaderDS.values.add("Freq(MHz)")
                tempTableHeaderDS.values.add("Power(dBmV)")
                tempTableHeaderDS.values.add("MER(dB)")
                tempTableHeaderDS.values.add("CM Corr Cw(%)")
                tempTableHeaderDS.values.add("CM Un Corr Cw(%)")
                
                
                //Global Variable Assignment
                self.tableHeaderDS = tempTableHeaderDS
                
                for eachRecord in modemDSArray{
                    let castedRecord = (eachRecord as! NSDictionary)
                    var tempRecord = DownstreamDS()
                    
                    let frequency = String(describing: castedRecord.value(forKey: RESPONSE_PARAM_FREQ)!)
                    let power = String(describing: castedRecord.value(forKey: RESPONSE_PARAM_POWER)!)
                    let mer = String(describing: castedRecord.value(forKey: RESPONSE_PARAM_MER)!)
                    let cmCorrCw = String(describing: castedRecord.value(forKey: RESPONSE_PARAM_CM_CORR)!)
                    let cmUnCorrCw = String(describing: castedRecord.value(forKey: RESPONSE_PARAM_CM_UNCORR)!)
                    
                    tempRecord.frequency = frequency
                    tempRecord.power = power
                    tempRecord.mer = mer
                    tempRecord.cmCorrCw = cmCorrCw
                    tempRecord.cmUnCorrCw = cmUnCorrCw
                    
                    self.bundleDataDSTable.append(tempRecord)
                    
                    //Prepare the Custom Table View
                    
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
    
    
    func setMainScrollViewContentHeight(){
        self.constraintCententViewHeightForMainCV.constant = self.viewGovernerForHeight.frame.size.height + self.viewGovernerForHeight.frame.origin.y + 8
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    
    
    
    
    
    
    @IBAction func btnActionLogout(_ sender: Any) {
        self.performLogout()
        
        
    }
}

struct BirthCertificateDS{
    var definer = ""
    var value = ""
}

struct ModemStatusDS{
    var recordName = String()
    var entireFrequencyRecord = [FrequencyDS]()
    var isVisible = Bool()
    var unit = String()
    var commonValue = String()
    var commonStatus = String()
}

struct FrequencyDS{
    var value = ""
    var status = ""
}

struct TableHeaderDS{
    var values = NSMutableArray()
}

struct DownstreamDS{
    var frequency = String()
    var power = String()
    var mer = String()
    var cmCorrCw = String()
    var cmUnCorrCw = String()
}

/*
 //MARK: UItable View Deleagtes And Datasource
 func numberOfSections(in tableView: UITableView) -> Int {
 return 1;
 }
 
 
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 if tableView == self.tableViewBirthCertificate{
 return 4
 }else if tableView == self.tableViewModemStatus{
 return 7
 }else if tableView == self.tableViewDSInformation{
 return 5
 }else{
 return 0
 }
 }
 
 
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 return UITableViewCell()
 }

 */
