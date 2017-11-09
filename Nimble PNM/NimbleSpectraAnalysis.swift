//
//  NimbleSpectraAnalysis.swift
//  Nimble PNM
//
//  Created by KSolves on 24/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit
import Charts

class NimbleSpectraAnalysis : BaseVC, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var exposedMacAddress = ""
    var exposedTimestamp = ""
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
    var arrayLineChartData: [ChartDataEntry] = []
    fileprivate var arrayImpairmentFreq : [BarChartDataEntry] = []
    var arrayBarChartWidth: [Double] = []
    var arrayMacAddrerssPort: [String] = []
    
    var colorLineChart = UIColor(red: 0/255, green: 200/255, blue: 0/255, alpha: 1)
    var colorImpairment = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.5)
    var colorPortButtonBackground = COLOR_DARK_YELLOW
    
    var shouldShowImpairments = false
    var shouldShowPortButtons = true
    var isDataAvailable = true
    
    var footerView = UIView()
    var selectedPort = ""
    
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
        
        arrayMacAddrerssPort = exposedMacAddress.components(separatedBy: ":")
        shouldShowPortButtons = (arrayMacAddrerssPort.count > 1)
        
        if shouldShowPortButtons {
            showViewButtonContainer()
            self.initialPortButtonAction(portNo: arrayMacAddrerssPort[1])
        }else {
            hideViewButtonContainer()
            loadModemStatistics(portNo: "")
        }
        
        self.textFieldFilterByDate.text = exposedTimestamp.components(separatedBy: " ")[0]
    }
    
    func initialPortButtonAction(portNo: String){
        
        switch portNo {
        case "1":
            self.buttonPort1.sendActions(for: .touchUpInside)
        case "2":
            self.buttonPort2.sendActions(for: .touchUpInside)
        case "3":
            self.buttonPort3.sendActions(for: .touchUpInside)
        case "4":
            self.buttonPort4.sendActions(for: .touchUpInside)
        default:
            self.loadModemStatistics(portNo: "")
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if shouldShowPortButtons {
            if size.width > size.height {
                self.hideViewButtonContainer()
                
            } else {
                self.showViewButtonContainer()
            }
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
    
    @objc func buttonPickerDonePressed(_ sender: UIButton){
        let selectedTimestamp = self.pickerView.selectedRow(inComponent: 0)
        if selectedTimestamp != -1 && bundleTimestamp.count > 0{
            self.textFieldFilterByDate.text = self.bundleTimestamp[selectedTimestamp]
            self.exposedTimestamp = self.bundleTimestamp[selectedTimestamp]
            self.loadModemStatistics(portNo: selectedPort)
        }
        
        self.textFieldFilterByDate.resignFirstResponder()
    }
    
    @objc func buttonPickerCancelPressed(_ sender: UIButton){
        
        self.textFieldFilterByDate.resignFirstResponder()
    }
    
    func loadModemStatistics(portNo: String) {
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        var tempMacAddress = ""
        
        if portNo == ""{
            tempMacAddress = exposedMacAddress
        }else {
            tempMacAddress = arrayMacAddrerssPort[0]
            tempMacAddress.append(":")
            tempMacAddress.append(portNo)
        }
        
        let dictParameters = [REQ_PARAM_USERNAME: username,
                              REQ_PARAM_AUTH_KEY: authKey,
                              REQ_PARAM_TIMESTAMP: exposedTimestamp,
                              REQ_PARAM_CMTS_ID: exposedCMTSId,
                              REQ_PARAM_MAC_ADDRESS: tempMacAddress
        ];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_NIMBLE_SPECTRA_GET_CHART_DATA, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_FETCH_SPECTRA_DATA, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                
                if let dataDic = responseDict.value(forKey: RESPONSE_PARAM_DATA)! as? NSDictionary {
                    
                    // Initialising First cell Data
                    self.arrayLineChartData.removeAll()
                    
                    let dicResponseData = dataDic.value(forKey: RESPONSE_PARAM_RESPONSE_DATA)! as! NSDictionary
                    let arrayStatisticsData = dicResponseData.value(forKey: RESPONSE_PARAM_DATA)! as! NSArray
                    var lowestAmplitude: Double = 0
                    
                    for eachRecord in arrayStatisticsData {
                        let valueX = String(describing: (eachRecord as! NSArray)[0])
                        let valueY = String(describing: (eachRecord as! NSArray)[1])
                        let valueData = ChartDataEntry(x: Double(valueX)!,y: Double(valueY)!)
                        self.arrayLineChartData.append(valueData)
                        
                        if Double(valueY)! < lowestAmplitude {
                            lowestAmplitude = Double(valueY)!
                        }
                    }
                    
                    self.arrayImpairmentFreq.removeAll()
                    self.arrayBarChartWidth.removeAll()
                    
                    let dicImpairmentData = dataDic.value(forKey: RESPONSE_PARAM_IMPAIRMANT_DATA)! as! NSArray
                    
                    for eachData in dicImpairmentData {
                        
                        let highFreq = Double(String(describing: (eachData as! NSDictionary).value(forKey: RESPONSE_PARAM_HIGH_FREQ)!))!
                        let lowFreq = Double(String(describing: (eachData as! NSDictionary).value(forKey: RESPONSE_PARAM_LOW_FREQ)!))!
                        let valueX = lowFreq + (highFreq-lowFreq)/2
                        let impairmentRecord = BarChartDataEntry(x: valueX,y: lowestAmplitude)
                        
                        self.arrayBarChartWidth.append(highFreq-lowFreq)
                        self.arrayImpairmentFreq.append(impairmentRecord)
                    }
                    
                    self.shouldShowImpairments = true
                    // Initialising Second Cell Data
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
                    
                    // Initialising Picker Timestamps
                    self.bundleTimestamp.removeAll()
                    
                    let dateDic = dataDic.value(forKey: RESPONSE_PARAM_DATES)! as! NSDictionary
                    let timeStampArray = dateDic.allKeys as! [String]
                    let sortedTimeStampArray = timeStampArray.sorted()
                    
                    for timeStamp in sortedTimeStampArray {
                        self.bundleTimestamp.append(timeStamp)
                    }
                    
                    self.pickerView.reloadAllComponents()
                    self.isDataAvailable = true
                    
                }else {
                    self.arrayLineChartData.removeAll()
                    self.arrayImpairmentFreq.removeAll()
                    self.arrayBarChartWidth.removeAll()
                    self.isDataAvailable = false
                }
                
                self.tableViewSpectraAnalysis.reloadData()
                
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
    
    @objc func buttonPortPressed(_ sender: UIButton) {
        
        setAllButtonBackGroundClear()
        sender.backgroundColor = colorPortButtonBackground
        
        let tag = sender.tag
        selectedPort = "\(tag)"
        self.loadModemStatistics(portNo: "\(tag)")
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
            
            let lineData = LineChartDataSet(values: arrayLineChartData, label: "Amplitude")
            lineData.colors = [colorLineChart]
            lineData.circleRadius = 0.0

            let combinedChartData = CombinedChartData()
            
            if shouldShowImpairments {
                cell.buttonShowHideImpairments.setTitle("Hide Impairment", for: .normal)
                
                let impairmentData = BarChartDataSet(values: arrayImpairmentFreq, label: "Impairment")
                impairmentData.colors = [colorImpairment]

                let barChartData = BarChartData()
                barChartData.addDataSet(impairmentData)
                if arrayBarChartWidth.count > 0{
                    barChartData.barWidth = arrayBarChartWidth.max()!
                }

                combinedChartData.addDataSet(impairmentData)
                combinedChartData.barData = barChartData
            }else {
                cell.buttonShowHideImpairments.setTitle("Show Impairment", for: .normal)
            }
            
            let lineChartData = LineChartData()
            lineChartData.addDataSet(lineData)
            
            combinedChartData.addDataSet(lineData)
            combinedChartData.lineData = lineChartData
            
            if isDataAvailable {
                cell.combinedChartView.data = combinedChartData
            }else {
                cell.combinedChartView.data = nil
            }
            
            cell.combinedChartView.chartDescription?.text = ""
            cell.combinedChartView.noDataText = "No Spectra data available!"
            cell.combinedChartView.noDataTextColor = colorPortButtonBackground
            cell.combinedChartView.noDataFont = UIFont.systemFont(ofSize: 17)
            cell.combinedChartView.notifyDataSetChanged()
            cell.combinedChartView.legend.resetCustom()
            
            cell.buttonShowHideImpairments.addTarget(self, action: #selector(buttonShowHideImpairmentPressed(_:)), for: .touchUpInside)
            
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
    
    @objc func buttonShowHideImpairmentPressed(_ sender: UIButton) {
        shouldShowImpairments = !shouldShowImpairments
        tableViewSpectraAnalysis.reloadData()
    }
    
    
    @objc func buttonRescanPressed() {
        
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





