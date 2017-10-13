//
//  CMModelDetailVC.swift
//  Nimble PNM
//
//  Created by ksolves on 10/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class CMModemDetailVC: BaseVC {
    
    //Orientation Type == 0 //For Potrait
    //Orientation Type == 1 //For Landscape
    var exposedMacAddress : String!

    @IBOutlet weak var constraintMainContentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintMDWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintDSWidth: NSLayoutConstraint!
    
    @IBOutlet weak var constraintDSHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintMDHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewMDInfo: UIView!
    @IBOutlet weak var viewDSInfo: UIView!
    
    var screenSize: CGSize!
    
    @IBOutlet weak var labelMacAddress: UILabel!
    var totalMDrows : Int = 0
    var totalMDcoloumns : Int = 0
    var MinusHeadingForTableMD = 87.0
    var MinusHeadingForTableDS = 36.0
    
    let colorHeadings = COLOR_BLUE_IONIC_V1
    
    var totalDSrows : Int = 0
    var totalDScoloumns : Int = 0
    
    var tableHeaderDS : TableHeaderDS!
    var bundleDataDSTable : [DownstreamDS] = []
    var bundleDataMDTable : [ModemDetailsDS] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUIComponents()
        self.getDetails(forModem: exposedMacAddress)
        self.loadDSData(forModem: exposedMacAddress)
        
    }
    
    func configureUIComponents(){
        
        screenSize = self.view.frame.size
        labelMacAddress.text = exposedMacAddress
        viewMDInfo.isHidden = true
        viewDSInfo.isHidden = true
    }
    
    //Hansling Screen Orienatations and Table Plotting
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        screenSize = size
        
        coordinator.animate(alongsideTransition: {
            context in
           
            self.plotModemStatusTable()
            self.plotDownstreamTable()
            
        }, completion: {
            context in

        })
        
    }
    
    func handleViewRotationToPotrait(){
        //self.plotDownstreamTable(forOrientationType: 0)
        
    }
    
    
    func handleViewRotationToLandscape(){
        //self.plotDownstreamTable(forOrientationType: 1)
        
    }
  
    func plotModemStatusTable(){

        viewMDInfo.isHidden = false
        
        for eachSubview in self.viewMDInfo.subviews{
            eachSubview.removeFromSuperview()
        }

        let paddingHorizontal = 1.0
        var gappingHorizontal = 1.0
        let paddingVertical = 1.0
        let gappingVertical = 1.0


        var variableX = paddingHorizontal
        var variableY = paddingVertical
        
        let widthHeadingCell = 120.0

        let minimumWidthOfCell = 150.0
        let computedWidthOfCell = (Double(screenSize.width - 16) - (2 * paddingHorizontal) - (Double(totalMDcoloumns - 1) * Double(gappingHorizontal)))/Double(totalMDcoloumns)

        var finalWidthOfCell : Double!

        if computedWidthOfCell >= minimumWidthOfCell{
            finalWidthOfCell = computedWidthOfCell
            gappingHorizontal = 2
        }else{
            finalWidthOfCell = minimumWidthOfCell
        }

        let heightOfCell = 20.0

        var scrollContentWidthDeterminer = Double()

        for i in 0..<totalMDrows{

            for j in 0 ..< totalMDcoloumns{

                var labelForCell : UILabel!
                //DataSource Usage Governance
                
                //Using Modem DS as datasource

                if j == 0{
                    labelForCell = UILabel(frame: CGRect(x: variableX, y: variableY, width: widthHeadingCell, height: heightOfCell))
                    labelForCell.text = "\(bundleDataMDTable[i].recordName)"
                    labelForCell.textAlignment = .left
                    labelForCell.font = UIFont.boldSystemFont(ofSize: SIZE_FONT_MEDIUM)
                    labelForCell.backgroundColor = colorHeadings
                    labelForCell.textColor = UIColor.white
                    variableX += widthHeadingCell + gappingHorizontal

                }else{
                    labelForCell = UILabel(frame: CGRect(x: variableX, y: variableY, width: finalWidthOfCell, height: heightOfCell))
                    labelForCell.text = bundleDataMDTable[i].arrayValues[j-1]
                    labelForCell.textAlignment = .center
                    labelForCell.font = UIFont.systemFont(ofSize: SIZE_FONT_SMALL)
                    labelForCell.backgroundColor = UIColor.white
                    labelForCell.textColor = UIColor.black
                    variableX += finalWidthOfCell + gappingHorizontal
                }
                self.viewMDInfo.addSubview(labelForCell)

                //Incrementing X
                scrollContentWidthDeterminer = variableX
            }

            //Incrementing Y and Adjusting X
            variableX = paddingHorizontal
            variableY += heightOfCell + gappingVertical

        }

        let totalHeight = variableY
        let totalWidth = scrollContentWidthDeterminer

        self.constraintMDWidth.constant = CGFloat(totalWidth)
        self.constraintMDHeight.constant = CGFloat(MinusHeadingForTableMD + totalHeight)
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
        })

        //self.setMainScrollViewContentHeight()

    }



    
    func getOrientationCode() -> Int{
        if screenSize.width > screenSize.height{
            return 1
        }else{
            return 0
        }
    }
    
    
    func getDetails(forModem modemMac : String){
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username,
                              REQ_PARAM_MAC_ADDRESS : [modemMac]
        ] as [String : Any];
        
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_CM_ANALYZER_GET_MODEM_DATA, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_CM_ANALYZER_GET_MODEM_DATA, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            
            if statusCode == 200{
                let dataArray = (responseDict.value(forKey: "data") as! NSArray)
                
                self.bundleDataMDTable.removeAll()
                
                self.totalMDrows = 9
                self.totalMDcoloumns = dataArray.count + 1;
                
                for i in 0..<9{
                    var tempRecord = ModemDetailsDS()
                    
                    if i == 0{
                        tempRecord.recordName = "Severity"
                        
                        for j in 0..<dataArray.count{
                            tempRecord.arrayValues.append(String(describing: (dataArray[j] as! NSDictionary).value(forKey: RESPONSE_PARAM_SEVERITY)!))
                        }
                        
                    }else if i == 1{
                        tempRecord.recordName = "ICFR(db)"
                        
                        for j in 0..<dataArray.count{
                            tempRecord.arrayValues.append(String(describing: (dataArray[j] as! NSDictionary).value(forKey: RESPONSE_PARAM_ICFR)!))
                        }
                        
                    }else if i == 2{
                        tempRecord.recordName = "MTC(dBc)"
                        
                        for j in 0..<dataArray.count{
                            tempRecord.arrayValues.append(String(describing: (dataArray[j] as! NSDictionary).value(forKey: RESPONSE_PARAM_MTC)!))
                        }
                        
                    }else if i == 3{
                        tempRecord.recordName = "Delay(ns/MHz)"
                        
                        for j in 0..<dataArray.count{
                            tempRecord.arrayValues.append(String(describing: (dataArray[j] as! NSDictionary).value(forKey: RESPONSE_PARAM_DELAY)!))
                        }
                        
                    }else if i == 4{
                        tempRecord.recordName = "TDR(Feet)"
                        
                        for j in 0..<dataArray.count{
                            tempRecord.arrayValues.append(String(describing: (dataArray[j] as! NSDictionary).value(forKey: RESPONSE_PARAM_TDR)!))
                        }
                        
                    }else if i == 5{
                        tempRecord.recordName = "vTDR(Feet)"
                        
                        for j in 0..<dataArray.count{
                            tempRecord.arrayValues.append(String(describing: (dataArray[j] as! NSDictionary).value(forKey: RESPONSE_PARAM_VTDR)!))
                        }
                        
                    }else if i == 6{
                        tempRecord.recordName = "Corr"
                        
                        for j in 0..<dataArray.count{
                            tempRecord.arrayValues.append(String(describing: (dataArray[j] as! NSDictionary).value(forKey: RESPONSE_PARAM_CORR)!))
                        }
                        
                    }else if i == 7{
                        tempRecord.recordName = "Freq(MHz)"
                        
                        for j in 0..<dataArray.count{
                            tempRecord.arrayValues.append(String(describing: (dataArray[j] as! NSDictionary).value(forKey: RESPONSE_PARAM_FREQ)!))
                        }
                        
                    }else if i == 8{
                        tempRecord.recordName = "BW(MHz)"
                        
                        for j in 0..<dataArray.count{
                            tempRecord.arrayValues.append(String(describing: (dataArray[j] as! NSDictionary).value(forKey: RESPONSE_PARAM_BW)!))
                        }
                        
                    }
                    
                    self.bundleDataMDTable.append(tempRecord)
                    
                }
                
                self.plotModemStatusTable()
                
                
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
    
    func performRescan(forModem modemMac : String){
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username,
                              REQ_PARAM_MAC_ADDRESS : modemMac
            ] as [String : Any];
        
        
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_CM_ANALYZER_RE_SCAN_MODEM, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_CM_ANALYZER_RESCAN_MODEM, sucessCompletionHadler: {
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
    
    
    func loadDSData(forModem modemMac : String){
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username,
                              REQ_PARAM_MAC_ADDRESS : modemMac
            ] as [String : Any];
        
        
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_CM_ANALYZER_GET_DS_DATA, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_CM_ANALYZER_LOAD_DS_DATA, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                //Loading Values which determines the Modem status Section values
                let modemDSArray = (responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSArray)[0] as! NSArray
                self.totalDSrows = modemDSArray.count + 1
                self.totalDScoloumns = 6
                
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
                
                self.plotDownstreamTable()
                
                
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
    
    func plotDownstreamTable(){
        
        viewDSInfo.isHidden = false
        
        for eachSubview in self.viewDSInfo.subviews{
            eachSubview.removeFromSuperview()
        }
        
        let paddingHorizontal = 1.0
        let gappingHorizontal = 1.0
        let paddingVertical = 1.0
        let gappingVertical = 1.0
        
        
        var variableX = paddingHorizontal
        var variableY = paddingVertical
        
        let minimumWidthOfCell = 40.0
        let computedWidthOfCell = (Double(screenSize.width - 16) - (2 * paddingHorizontal) - (Double(totalDScoloumns - 1) * Double(gappingHorizontal)))/Double(totalDScoloumns)
        
        var finalWidthOfCell : Double!
        
        if computedWidthOfCell >= minimumWidthOfCell{
            finalWidthOfCell = computedWidthOfCell
        }else{
            finalWidthOfCell = minimumWidthOfCell
        }
        
        let heightOfCell = 20.0
        let heightOfHeaderCell = 60.0
        
        var scrollContentWidthDeterminer = Double()
        
        
        for i in 0..<totalDSrows{
            
            for j in 0 ..< totalDScoloumns{
                
                var labelForCell : UILabel!
                //DataSource Usage Governance
                if i == 0{
                    //Using Table Header DS as datasource
                    labelForCell = UILabel(frame: CGRect(x: variableX, y: variableY, width: finalWidthOfCell, height: heightOfHeaderCell))
                    labelForCell.text = (tableHeaderDS.values[j] as! String)
                    labelForCell.font = UIFont.boldSystemFont(ofSize: SIZE_FONT_MEDIUM)
                    labelForCell.textAlignment = .center
                    labelForCell.numberOfLines = 0
                    labelForCell.backgroundColor = colorHeadings
                    labelForCell.textColor = UIColor.white
                    
                }else{
                    //Using Modem DS as datasource
                    labelForCell = UILabel(frame: CGRect(x: variableX, y: variableY, width: finalWidthOfCell, height: heightOfCell))
                    labelForCell.font = UIFont.systemFont(ofSize: SIZE_FONT_SMALL)
                    labelForCell.backgroundColor = UIColor.white
                    
                    if j == 0{
                        labelForCell.text = "\(i)";
                        labelForCell.textAlignment = .center
                        
                    }else if j == 1{
                        labelForCell.text = bundleDataDSTable[i-1].frequency
                        labelForCell.textAlignment = .center
                        
                    }else if j == 2{
                        labelForCell.text = bundleDataDSTable[i-1].power
                        labelForCell.textAlignment = .center
                        
                    }else if j == 3{
                        labelForCell.text = bundleDataDSTable[i-1].mer
                        labelForCell.textAlignment = .center
                        
                    }else if j == 4{
                        labelForCell.text = bundleDataDSTable[i-1].cmCorrCw
                        labelForCell.textAlignment = .center
                        
                    }else if j == 5{
                        labelForCell.text = bundleDataDSTable[i-1].cmUnCorrCw
                        labelForCell.textAlignment = .center
                        
                    }
                    
                }
                
                self.viewDSInfo.addSubview(labelForCell)
                
                //Incrementing X
                variableX += finalWidthOfCell + gappingHorizontal
                scrollContentWidthDeterminer = variableX
                
            }
            
            //Incrementing Y and Adjusting X
            variableX = paddingHorizontal
            
            if i == 0 {
                variableY += heightOfHeaderCell + gappingVertical
            } else {
                variableY += heightOfCell + gappingVertical
            }
            
        }
        
        let totalHeight = variableY
        let totalWidth = scrollContentWidthDeterminer 
        
        self.constraintDSWidth.constant = CGFloat(totalWidth)
        self.constraintDSHeight.constant = CGFloat(MinusHeadingForTableDS + totalHeight)
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
        })
        
       // self.setMainScrollViewContentHeight()
        
        
    }
    
    
    
    
    
}

struct ModemDetailsDS{
    var recordName = ""
    var arrayValues : [String] = []
}


struct DownstreamDetailDS{
    var frequency = String()
    var power = String()
    var mer = String()
    var cmCorrCw = String()
    var cmUnCorrCw = String()
}

