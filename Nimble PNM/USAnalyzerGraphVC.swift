//
//  USAnalyzerGraphVC.swift
//  Nimble PNM
//
//  Created by ksolves on 06/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit
import Charts

class USAnalyzerGraphVC: BaseVC {
    
    @IBOutlet weak var viewGraphChart: CombinedChartView!
    @IBOutlet weak var labelUpstream: UILabel!
    @IBOutlet weak var labelCMTS: UILabel!
    @IBOutlet weak var buttonStartPause: UIButton!
    @IBOutlet weak var buttonSetting: UIButton!
    @IBOutlet weak var buttonEnableDisable: UIButton!
    
    @IBOutlet weak var viewContainerChartLabels: UIView!
    let imagePause = #imageLiteral(resourceName: "iconpause")
    let imagePlay = #imageLiteral(resourceName: "iconplay")
    let imageSettings = #imageLiteral(resourceName: "settingsblack")
    let imageEnable = #imageLiteral(resourceName: "icondisable")
    
    var bundleLoadingData : NSDictionary!
    var bundleLoadingSetting : NSDictionary = [:]
    var upstreamData = UpstreamPortListDS()
    var cmtsData = CMTSLISTDS()
    
    var macAddressBlank = "00 00 00 00 00 00"
    var macAddressActive = ""
    var valueStartParam = "5"
    var valueParamStop = "42"
    var valueParamIsSid = "1"
    var valueParamSid = "0"
    var valuePolling = 1
    
    let colorMax = UIColor(red: 187/255, green: 45/255, blue: 39/255, alpha: 1)
    let colorMin = UIColor(red: 84/255, green: 181/255, blue: 103/255, alpha: 1)
    let colorLive = UIColor(red: 10/255, green: 101/255, blue: 186/255, alpha: 1)
    let colorIngress = UIColor(red: 121/255, green: 124/255, blue: 128/255, alpha: 1)
    
    var CMDataFilterOnLive: LineChartDataSet!
    var CMDataFilterOffIngress: LineChartDataSet!
    var CMDataMax: LineChartDataSet!
    var CMDataMin: LineChartDataSet!
    var dataMinY: [Double] = []
    var dataMaxY: [Double] = []
    var dataIngressMax: [Double] = []
    
    var isFirstTime = true
    var isPaused = true
    var isEnabled = true
    var shouldRefreshGraph = false
    var isViewVisble = true
    
    var shouldShowLiveData = true
    var shouldShowMaxData = true
    var shouldShowMinData = true
    var shouldShowIngressData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureScreenView()
        initialiseButtons()
        initialiseData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        isViewVisble = true
        
        if macAddressActive == "" {
            macAddressActive = macAddressBlank
        }
        
        if shouldRefreshGraph {
            enablePort()
            shouldRefreshGraph = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        isViewVisble = false
    }
    
    func configureScreenView() {
        
        self.viewGraphChart.xAxis.labelPosition = .bottom
        self.viewGraphChart.leftAxis.axisMinimum = -60.0
        self.viewGraphChart.leftAxis.axisMaximum = 0.0
        self.viewGraphChart.noDataText = "No Data Available!"
        self.viewGraphChart.chartDescription?.text = ""
        self.viewGraphChart.noDataFont = UIFont.systemFont(ofSize: 15)
        self.viewGraphChart.noDataTextColor = colorLive
        self.viewGraphChart.backgroundColor = COLOR_WHITE_AS_GREY
        self.viewGraphChart.rightAxis.drawLabelsEnabled = false
        
        let framLabelAxisY = CGRect(x: 0, y: 0, width: viewGraphChart.frame.origin.x, height: viewGraphChart.frame.height)
        let labelAxisY = UtilityHelper.getRotatedLabelForAxisY(frame: framLabelAxisY)
        labelAxisY.text = "Amplitude(dBmV)"
        self.viewContainerChartLabels.addSubview(labelAxisY)
    }
    
    func initialiseData() {
        
        upstreamData = bundleLoadingData.value(forKey: "upstream") as! UpstreamPortListDS
        cmtsData = bundleLoadingData.value(forKey: "cmts") as! CMTSLISTDS
        
        labelCMTS.text = cmtsData.name
        labelUpstream.text = upstreamData.interfaceName
        macAddressActive = macAddressBlank
        
        enablePort()
    }
    
    func initialiseButtons(){
        
        buttonSetting.setTitle("Settings  ", for: .normal)
        buttonSetting.setImage(imageSettings, for: .normal)
        buttonSetting.imageView?.contentMode = .scaleAspectFit
        
        buttonEnableDisable.setImage(imageEnable, for: .normal)
        buttonEnableDisable.imageView?.contentMode = .scaleAspectFit
        
        buttonStartPause.addTarget(self, action: #selector(buttonPlayPausePressed), for: .touchUpInside)
        buttonSetting.addTarget(self, action: #selector(buttonSettingsPressed), for: .touchUpInside)
        buttonEnableDisable.addTarget(self, action: #selector(buttonEnableDisablePressed), for: .touchUpInside)
        
        setForPause()
        setForEnable()
    }
    
    func fetchGraphData() {
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username,
                              REQ_PARAM_MAC_ADDRESS : macAddressActive,
                              REQ_PARAM_START: valueStartParam,
                              REQ_PARAM_STOP: valueParamStop,
                              REQ_PARAM_IS_SID: valueParamIsSid,
                              REQ_PARAM_SID : valueParamSid,
                              REQ_PARAM_RES: cmtsData.res
                              
                              ] as [String : Any];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderWithoutLoaderTo(url: SERVICE_URL_GET_US_ANALYZER_DATA, withParameters: dictParameters, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                
                let dataString = responseDict.value(forKey: RESPONSE_PARAM_DATA) as! String
                let dataDic = UtilityHelper.convertToDictionary(text: dataString)!
                
                let dicFilterOn = dataDic.value(forKey: RESPONSE_PARAM_CM_FILTER_ON) as! NSDictionary
                let dicFilterOff = dataDic.value(forKey: RESPONSE_PARAM_CM_FILTER_OFF) as! NSDictionary
                let onDataArray = dicFilterOn.value(forKey: RESPONSE_PARAM_DATA) as! [NSArray]
                let offDataArray = dicFilterOff.value(forKey: RESPONSE_PARAM_DATA) as! [NSArray]
                
                var tempChartDataEntry : [ChartDataEntry] = []
                var tempChartDataEntryMax : [ChartDataEntry] = []
                var tempChartDataEntryMin : [ChartDataEntry] = []
                
                for index in 0..<onDataArray.count {
                    let valueX = Double(String(describing: onDataArray[index][0]))!
                    let valueY = Double(String(describing: onDataArray[index][1]))!
                    tempChartDataEntry.append(ChartDataEntry(x: valueX, y: valueY))
                    
                    if !self.isPaused  && self.dataMinY.count >= onDataArray.count && self.dataMaxY.count >= onDataArray.count{
                        
                        if self.dataMaxY[index] < valueY {
                            self.dataMaxY[index] = valueY
                        }
                        
                        if self.dataMinY[index] > valueY {
                            self.dataMinY[index] = valueY
                        }
                        
                        tempChartDataEntryMax.append(ChartDataEntry(x: valueX, y: self.dataMaxY[index]))
                        tempChartDataEntryMin.append(ChartDataEntry(x: valueX, y: self.dataMinY[index]))
                        
                    }else {
                        
                        if self.dataMinY.count < onDataArray.count {
                            self.dataMinY.append(valueY)
                        }
                        
                        if self.dataMaxY.count < onDataArray.count {
                            self.dataMaxY.append(valueY)
                        }
                    }
                    
                }
                
                let lineDataSet = LineChartDataSet(values: tempChartDataEntry, label: "Live")
                lineDataSet.circleRadius = 0.0
                lineDataSet.colors = [self.colorLive]
                self.CMDataFilterOnLive = lineDataSet
                
                if !self.isPaused {
                    let lineDataSetMax = LineChartDataSet(values: tempChartDataEntryMax, label: "Max")
                    lineDataSetMax.circleRadius = 0.0
                    lineDataSetMax.colors = [self.colorMax]
                    self.CMDataMax = lineDataSetMax
                    
                    let lineDataSetMin = LineChartDataSet(values: tempChartDataEntryMin, label: "Min")
                    lineDataSetMin.circleRadius = 0.0
                    lineDataSetMin.colors = [self.colorMin]
                    self.CMDataMin = lineDataSetMin
                    
                    var tempChartDataEntryOff : [ChartDataEntry] = []
                    
                    for index in 0..<offDataArray.count {
                        let valueX = Double(String(describing: offDataArray[index][0]))!
                        let valueY = Double(String(describing: offDataArray[index][1]))!
                        
                        if self.dataIngressMax.count >= offDataArray.count {
                            if self.dataIngressMax[index] < valueY {
                                self.dataIngressMax[index] = valueY
                            }
                            
                            tempChartDataEntryOff.append(ChartDataEntry(x: valueX, y: self.dataIngressMax[index]))
                            
                        }else {
                            self.dataIngressMax.append(valueY)
                        }
                    }
                    
                    let lineDataSetOff = LineChartDataSet(values: tempChartDataEntryOff, label: "Ingress")
                    lineDataSetOff.circleRadius = 0.0
                    lineDataSetOff.colors = [self.colorIngress]
                    self.CMDataFilterOffIngress = lineDataSetOff
                }
                
                if self.isPaused {
                    self.drawGraph()
                }else {
                    self.updateChart()
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
    
    
    func drawGraph() {
        
        let lineChartData = LineChartData()
        lineChartData.addDataSet(CMDataFilterOnLive)
        
        let combinedChartData = CombinedChartData()
        combinedChartData.addDataSet(CMDataFilterOnLive)
        combinedChartData.lineData = lineChartData
        
        self.viewGraphChart.data = combinedChartData
        self.viewGraphChart.notifyDataSetChanged()
        self.viewGraphChart.legend.resetCustom()
        
    }
    
    func updateChart() {
        
        let lineChartData = LineChartData()
        let combinedChartData = CombinedChartData()
        
        if shouldShowLiveData {
            lineChartData.addDataSet(CMDataFilterOnLive)
            combinedChartData.addDataSet(CMDataFilterOnLive)
        }
        
        if shouldShowMaxData {
            lineChartData.addDataSet(CMDataMax)
            combinedChartData.addDataSet(CMDataMax)
        }
        
        if shouldShowMinData {
            lineChartData.addDataSet(CMDataMin)
            combinedChartData.addDataSet(CMDataMin)
        }
        
        if shouldShowIngressData {
            lineChartData.addDataSet(CMDataFilterOffIngress)
            combinedChartData.addDataSet(CMDataFilterOffIngress)
        }
        
        combinedChartData.lineData = lineChartData
        
        self.viewGraphChart.data = combinedChartData
        self.viewGraphChart.notifyDataSetChanged()
        self.viewGraphChart.legend.resetCustom()
        
        if !isPaused && isViewVisble {
            self.fetchGraphData()
        }
    }
    
    
    @IBAction func btnActionLogout(_ sender: Any) {
        //self.performLogout()
        self.performLogout()
    }
    
    
    @objc func buttonPlayPausePressed(){
        if isPaused {
            setForPlay()
        }else {
            setForPause()
        }
    }
    
    func setForPlay(){
        isPaused = false
        
        buttonStartPause.setTitle("Pause  ", for: .normal)
        buttonStartPause.setImage(imagePause, for: .normal)
        buttonStartPause.imageView?.contentMode = .scaleAspectFit
        
        self.dataMaxY.removeAll()
        self.dataMinY.removeAll()
        self.dataIngressMax.removeAll()
        
        fireFetchGraphDataRequestPolling()
    }
    
    func setForPause(){
        isPaused = true
        
        buttonStartPause.setTitle("Start  ", for: .normal)
        buttonStartPause.setImage(imagePlay, for: .normal)
        buttonStartPause.imageView?.contentMode = .scaleAspectFit
    }
    
    func fireFetchGraphDataRequestPolling() {
        for _ in 1...valuePolling {
            fetchGraphData()
        }
        
        isPaused = false
    }

    @objc func buttonEnableDisablePressed(){
        if isEnabled {
            setForDisable()
            disablePort()
        }else {
            setForEnable()
            enablePort()
        }
    }
    
    func setForEnable(){
        isEnabled = true
        buttonEnableDisable.setTitle("Disable  ", for: .normal)
    }
    
    func setForDisable(){
        isEnabled = false
        buttonEnableDisable.setTitle("Enable  ", for: .normal)
    }
    
    @objc func buttonSettingsPressed(){
        self.performSegue(withIdentifier: "segue-to-us-analyzer-setting", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue-to-us-analyzer-setting"{
            
            let destinationController = segue.destination  as! USAnalyzerSettingVC
            destinationController.globalValueForSwitchLive = shouldShowLiveData
            destinationController.globalValueForSwitchMax = shouldShowMaxData
            destinationController.globalValueForSwitchMin = shouldShowMinData
            destinationController.globalValueForSwitchIngress = shouldShowIngressData
            destinationController.valueStartFreq = valueStartParam
            destinationController.valueStopFreq = valueParamStop
            destinationController.valuePolling = valuePolling
            destinationController.selectedUSPort = upstreamData
            destinationController.USAnalyzerGraphVC = self
            
            if macAddressActive != macAddressBlank{
                destinationController.exposedMacAddress = macAddressActive
            }
            
        }
    }
    
    func disablePort() {
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username,
                              REQ_PARAM_UPSTREAMPORT : upstreamData.id,
                              
                              ] as [String : Any];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_DISABLE_US_ANALYZER_PORT, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_DISABLE_PORT, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                
                if self.isFirstTime {
                    self.enablePort()
                    self.isFirstTime = false
                }else {
                    self.buttonStartPause.isEnabled = false
                }
                
                if !self.isPaused {
                    self.buttonPlayPausePressed()
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
    
    func enablePort() {
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username,
                              REQ_PARAM_UPSTREAMPORT : upstreamData.id,
                              REQ_PARAM_MAC_ADDRESS: macAddressActive,
                              REQ_PARAM_START: valueStartParam,
                              REQ_PARAM_STOP: valueParamStop,
                              REQ_PARAM_CMTSID : cmtsData.id,
                              REQ_PARAM_RES: cmtsData.res
                              ] as [String : Any];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_SET_US_ANALYZER_DATA, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_ENABLE_PORT, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                
                if self.isFirstTime {
                    self.disablePort()
                }else {
                    if self.isPaused {
                        self.fetchGraphData()
                    }else {
                        self.fireFetchGraphDataRequestPolling()
                    }
                }
                
                self.buttonStartPause.isEnabled = true
                
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
    

}
