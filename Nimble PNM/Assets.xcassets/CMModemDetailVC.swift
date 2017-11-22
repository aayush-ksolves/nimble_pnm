 //
//  CMModelDetailVC.swift
//  Nimble PNM
//
//  Created by ksolves on 10/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit
import Charts

class CMModemDetailVC: BaseVC {
    
    //Orientation Type == 0 //For Potrait
    //Orientation Type == 1 //For Landscape
    var exposedMacAddress : String!

    @IBOutlet weak var viewContainerLabelsTapChart: UIView!
    @IBOutlet weak var viewContainerLabelsFreqChart: UIView!
    @IBOutlet weak var viewCombinedChart: CombinedChartView!
    @IBOutlet weak var viewChartICFR: LineChartView!
    @IBOutlet weak var constraintMDWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintDSWidth: NSLayoutConstraint!
    
    @IBOutlet weak var constraintDSHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintMDHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewMDInfo: UIView!
    @IBOutlet weak var viewDSInfo: UIView!
    
    @IBOutlet weak var scrollViewFrequency: UIScrollView!
    
    var screenSize: CGSize!
    
    @IBOutlet weak var labelMacAddress: UILabel!

    var totalMDrows : Int = 0
    var totalMDcoloumns : Int = 0
    var MinusHeadingForTableMD = 87.0
    var MinusHeadingForTableDS = 36.0
    

    @IBOutlet weak var constraintThirdSectionWidth: NSLayoutConstraint!
    

    let colorHeadings = COLOR_BLUE_IONIC_V1

    
    @IBOutlet weak var viewThirdSection: UIView!
    var totalDSrows : Int = 0
    var totalDScoloumns : Int = 0
    
    var tableHeaderDS : TableHeaderDS!
    var bundleDataDSTable : [DownstreamDetailDS] = []
    var bundleDataMDTable : [ModemDetailsDS] = []
    var arrayFrequency: [Double] = []
    var bundleICFRData: [LineChartDataSet] = []
    var bundleTapFreqChartData: [BarChartData] = []
    var tapChartThresholdData = LineChartData()
    let arrayColor = [COLOR_DARK_YELLOW, UIColor.blue, UIColor.green, UIColor.purple]
    
    let colorBackgroundSelected = COLOR_BLUE_IONIC_V1
    let colorBackgroundUnselected = COLOR_WHITE_AS_GREY
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUIComponents()
        self.getDetails(forModem: exposedMacAddress)
    }
    
    func configureUIComponents(){
        
        screenSize = self.view.frame.size
        labelMacAddress.text = exposedMacAddress
        viewMDInfo.isHidden = true
        viewDSInfo.isHidden = true
        scrollViewFrequency.isHidden = true
        
        self.viewChartICFR.xAxis.labelPosition = .bottom
        self.viewChartICFR.noDataText = "No Data Available!"
        self.viewChartICFR.chartDescription?.text = ""
        self.viewChartICFR.noDataFont = UIFont.systemFont(ofSize: 17)
        self.viewChartICFR.leftAxis.axisMinimum = -3
        self.viewChartICFR.leftAxis.axisMaximum = 3
        self.viewChartICFR.noDataTextColor = colorBackgroundSelected
        self.viewChartICFR.backgroundColor = UIColor.white
        self.viewChartICFR.rightAxis.drawLabelsEnabled = false
        
        self.viewCombinedChart.xAxis.labelPosition = .bottom
        self.viewCombinedChart.noDataText = "No Data Available!"
        self.viewCombinedChart.chartDescription?.text = ""
        self.viewCombinedChart.noDataFont = UIFont.systemFont(ofSize: 17)
        self.viewCombinedChart.xAxis.axisMinimum = 0
        self.viewCombinedChart.xAxis.axisMaximum = 25
        self.viewCombinedChart.noDataTextColor = colorBackgroundSelected
        self.viewCombinedChart.backgroundColor = UIColor.white
        self.viewCombinedChart.rightAxis.drawLabelsEnabled = false
        
        let icfrChartFrame = self.viewChartICFR.frame
        let icfrOrigin = icfrChartFrame.origin
        let icfrAxisYLabelFrame = CGRect(x: 0, y: icfrOrigin.y, width: icfrOrigin.x, height: icfrChartFrame.height)
        let icfrAxisYLabel = UtilityHelper.getRotatedLabelForAxisY(frame: icfrAxisYLabelFrame)
        icfrAxisYLabel.text = "DB"
        self.viewContainerLabelsFreqChart.addSubview(icfrAxisYLabel)
        
        let tapChartFrame = self.viewCombinedChart.frame
        let tapOrigin = tapChartFrame.origin
        let tapAxisYLabelFrame = CGRect(x: 0, y: tapOrigin.y, width: tapOrigin.x, height: tapChartFrame.height)
        let tapAxisYLabel = UtilityHelper.getRotatedLabelForAxisY(frame: tapAxisYLabelFrame)
        tapAxisYLabel.text = "Amplitude"
        self.viewContainerLabelsTapChart.addSubview(tapAxisYLabel)
        
        setTapChartThresholdGraphData()
    }
    
    func setTapChartThresholdGraphData() {
        
        var lineChartEntry : [ChartDataEntry] = []
        let arrValueY = [-15,-30,-30,-30,-30,-30,-35,-35,-35,-35,-35,-35,-35,-35,-35,-35]
        let arrValueX = getArrayFor(first: 9, last: 24, digitGap: 0.01)
        
        for valueX in arrValueX {
            lineChartEntry.append(ChartDataEntry(x: valueX ,y: Double(arrValueY[Int(valueX-9)])))
        }
        
        let lineDataSet = LineChartDataSet(values: lineChartEntry, label: "Threshold")
        lineDataSet.circleRadius = 0.0
        lineDataSet.colors = [UIColor.red]
        tapChartThresholdData.addDataSet(lineDataSet)
    }
    
    func getArrayFor(first: Double, last: Double, digitGap: Double) -> [Double] {
        var returnArr: [Double] = []
        var digit = first
        
        for _ in 0...Int((last - first)/digitGap) {
            returnArr.append(digit)
            digit += digitGap
        }
        
        return returnArr
    }
    
    //Handling Screen Orienatations and Table Plotting
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        screenSize = size
        
        coordinator.animate(alongsideTransition: {
            context in
           
            self.plotModemStatusTable()
            self.plotDownstreamTable()
            self.populateFrequencySection()
            
        }, completion: {
            context in

        })
        
    }
    
    
    func populateFrequencySection() {
        
        for eachSubview in self.scrollViewFrequency.subviews{
            eachSubview.removeFromSuperview()
        }
        
        let numberOfButtons = arrayFrequency.count + 1
        let minimumWidthOfButton = 80.0
        let horizontalGapping = 1.0
        var positionX = horizontalGapping
        let heightOfButton = 48.0
        let computedWidthOfButton = (Double(screenSize.width - 16))/Double(numberOfButtons)
        
        var finalWidthOfButton : Double!
        
        if computedWidthOfButton >= minimumWidthOfButton{
            finalWidthOfButton = computedWidthOfButton
        }else{
            finalWidthOfButton = minimumWidthOfButton
        }
        
        for index in -1..<numberOfButtons-1 {
            
            let buttonFreq = UIButton.init(frame: CGRect(x: positionX, y: 1, width: finalWidthOfButton, height: heightOfButton))
            buttonFreq.tag = index
            buttonFreq.backgroundColor = colorBackgroundUnselected
            buttonFreq.setTitleColor(UIColor.black, for: .normal)
            buttonFreq.addTarget(self, action: #selector(buttonFreqInScrollPressed(_:)), for: .touchUpInside)
            let attribute = [
                NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor : UIColor.black,
            ]
            
            if index == -1{
                buttonFreq.setAttributedTitle(NSAttributedString(string: "All", attributes: attribute), for: .normal)
                buttonFreq.sendActions(for: .touchUpInside)
                scrollViewFrequency.addSubview(buttonFreq)
                positionX += (finalWidthOfButton+horizontalGapping)
            }else {
                buttonFreq.setAttributedTitle(NSAttributedString(string: "\(arrayFrequency[index])MHz", attributes: attribute), for: .normal)
                
                if bundleICFRData[index].entryCount > 0 {
                    scrollViewFrequency.addSubview(buttonFreq)
                    positionX += (finalWidthOfButton+horizontalGapping)
                }
            }
        }
        
        scrollViewFrequency.contentSize = CGSize(width: positionX, height: heightOfButton)
        scrollViewFrequency.isHidden = false
    }
    
    @objc func buttonFreqInScrollPressed(_ sender: UIButton){
        
        setAllButtonBackgroundDefault()
        sender.backgroundColor = colorBackgroundSelected
        self.drawICFRFrequencyChart(forSection: sender.tag)
        self.drawTapFrequencyChart(forSection: sender.tag)
    }
    
    func setAllButtonBackgroundDefault() {
        
        var tempButton : UIButton!
        
        for eachSubview in self.scrollViewFrequency.subviews{
            tempButton = eachSubview as! UIButton
            tempButton.backgroundColor = colorBackgroundUnselected
        }
    }
    
    func drawICFRFrequencyChart(forSection section: Int) {
        
        let lineChartData = LineChartData()
        
        if section == -1 {
            for dataSet in bundleICFRData{
                lineChartData.addDataSet(dataSet)
            }
            
        }else {
            lineChartData.addDataSet(bundleICFRData[section])
        }
        
        self.viewChartICFR.data = lineChartData
        self.viewChartICFR.notifyDataSetChanged()
        self.viewChartICFR.legend.resetCustom()
        self.viewChartICFR.animate(xAxisDuration: 0.5)
        self.viewChartICFR.animate(yAxisDuration: 0.5)
    }

    func drawTapFrequencyChart(forSection section: Int) {
        
        let combinedChartData = CombinedChartData()
        
        combinedChartData.addDataSet(tapChartThresholdData.getDataSetByIndex(0))
        combinedChartData.lineData = tapChartThresholdData
        
        if section == -1 {
            let allBarData = BarChartData()
            for barChartSet in bundleTapFreqChartData{
                combinedChartData.addDataSet(barChartSet.getDataSetByIndex(0))
                allBarData.addDataSet(barChartSet.getDataSetByIndex(0))
            }
            
            allBarData.barWidth = 0.50
            combinedChartData.barData = allBarData
            
        }else {
            combinedChartData.addDataSet(bundleTapFreqChartData[section].getDataSetByIndex(0))
            combinedChartData.barData = bundleTapFreqChartData[section]
        }
        
        self.viewCombinedChart.data = combinedChartData
        self.viewCombinedChart.notifyDataSetChanged()
        self.viewCombinedChart.legend.resetCustom()
        self.viewCombinedChart.pinchZoomEnabled = false
        self.viewCombinedChart.doubleTapToZoomEnabled = false
        self.viewCombinedChart.animate(xAxisDuration: 0.5)
        self.viewCombinedChart.animate(yAxisDuration: 0.5)
    }
    
  
    func plotModemStatusTable(){

        viewMDInfo.isHidden = false

        for eachSubview in self.viewMDInfo.subviews{
            eachSubview.removeFromSuperview()
        }

        let paddingHorizontal = 1.0
        let gappingHorizontal = 1.0
        let paddingVertical = 1.0
        let gappingVertical = 1.0

        var variableX = paddingHorizontal
        var variableY = paddingVertical
        
        let widthHeadingCell = 120.0

        let minimumWidthOfCell = 80.0
        let computedWidthOfCell = (Double(screenSize.width - 16) - widthHeadingCell - (2 * paddingHorizontal) - (Double(totalMDcoloumns - 2) * Double(gappingHorizontal)))/Double(totalMDcoloumns - 1)

        var finalWidthOfCell : Double!

        if computedWidthOfCell >= minimumWidthOfCell{
            finalWidthOfCell = computedWidthOfCell
        }else{
            finalWidthOfCell = minimumWidthOfCell
        }

        let heightOfCell = 20.0

        var scrollContentWidthDeterminer = Double()

        for i in 0..<totalMDrows{

            for j in 0 ..< totalMDcoloumns{

                if i == 0 && j != 0 {
                    
                    let view = UIView(frame: CGRect(x: variableX, y: variableY, width: finalWidthOfCell, height: heightOfCell))
                    view.backgroundColor = UIColor.white
                    
                    let imageView = UIImageView(frame: CGRect(x: 2, y: 2, width: finalWidthOfCell - 4, height: heightOfCell - 4))
                    imageView.contentMode = .scaleAspectFit
                    imageView.backgroundColor = UIColor.white
                    imageView.image = UtilityHelper.getImageServerityFor(forType: bundleDataMDTable[i].arrayValues[j-1])
                    view.addSubview(imageView)
                    
                    variableX += finalWidthOfCell + gappingHorizontal

                    self.viewMDInfo.addSubview(view)
                    
                }else {
                    var labelForCell : UILabel!
                    //DataSource Usage Governance
                    
                    //Using Modem DS as datasource
                    
                    if j == 0{
                        labelForCell = UILabel(frame: CGRect(x: variableX, y: variableY, width: widthHeadingCell, height: heightOfCell))
                        labelForCell.text = " \(bundleDataMDTable[i].recordName)"
                        labelForCell.textAlignment = .left
                        labelForCell.font = UIFont.boldSystemFont(ofSize: SIZE_FONT_MEDIUM)
                        labelForCell.backgroundColor = colorHeadings
                        labelForCell.textColor = UIColor.white
                        variableX += widthHeadingCell + gappingHorizontal
                        
                    }else{
                        labelForCell = UILabel(frame: CGRect(x: variableX, y: variableY, width: finalWidthOfCell, height: heightOfCell))
                        
                        labelForCell.text = bundleDataMDTable[i].arrayValues[j-1].checkNullString()
                        labelForCell.textAlignment = .center
                        labelForCell.font = UIFont.systemFont(ofSize: SIZE_FONT_SMALL)
                        labelForCell.backgroundColor = UIColor.white
                        labelForCell.textColor = UIColor.black
                        variableX += finalWidthOfCell + gappingHorizontal
                    }
                    
                    self.viewMDInfo.addSubview(labelForCell)
                }

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
        UIView.animate(withDuration: 0.5, animations: {
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
                
                let tempDataArray = (responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSArray)
                let dataArray = self.sortArrayForChartData(array: tempDataArray)
                self.bundleDataMDTable.removeAll()
                
                self.totalMDrows = 9
                self.totalMDcoloumns = dataArray.count + 1;
                
                for i in 0..<9{
                    var tempRecord = ModemDetailsDS()
                    
                    if i == 0{
                        tempRecord.recordName = "Severity"
                        
                        for j in 0..<dataArray.count{
                            if !(String(describing: (dataArray[j] ).value(forKey: RESPONSE_PARAM_SEVERITY)!) == (NULL_STRING)) {
                                tempRecord.arrayValues.append(String(describing: (dataArray[j] ).value(forKey: RESPONSE_PARAM_SEVERITY)!))
                            }else {
                                self.totalMDcoloumns -= 1
                            }
                        }
                        
                    }else if i == 1{
                        tempRecord.recordName = "ICFR(db)"
                        
                        for j in 0..<dataArray.count{
                            if !(String(describing: (dataArray[j] ).value(forKey: RESPONSE_PARAM_SEVERITY)!) == (NULL_STRING)) {
                                tempRecord.arrayValues.append(String(describing: (dataArray[j] ).value(forKey: RESPONSE_PARAM_ICFR)!))
                            }
                        }
                        
                    }else if i == 2{
                        tempRecord.recordName = "MTC(dBc)"
                        
                        for j in 0..<dataArray.count{
                            if !(String(describing: (dataArray[j]).value(forKey: RESPONSE_PARAM_SEVERITY)!) == (NULL_STRING)) {
                                tempRecord.arrayValues.append(String(describing: (dataArray[j]).value(forKey: RESPONSE_PARAM_MTC)!))
                            }
                        }
                        
                    }else if i == 3{
                        tempRecord.recordName = "Delay(ns/MHz)"
                        
                        for j in 0..<dataArray.count{
                            if !(String(describing: (dataArray[j] ).value(forKey: RESPONSE_PARAM_SEVERITY)!) == (NULL_STRING)) {
                                tempRecord.arrayValues.append(String(format: "%.2f" ,(dataArray[j] ).value(forKey: RESPONSE_PARAM_DELAY)! as! Double))
                            }
                        }
                        
                    }else if i == 4{
                        tempRecord.recordName = "TDR(Feet)"
                        
                        for j in 0..<dataArray.count{
                            if !(String(describing: (dataArray[j] ).value(forKey: RESPONSE_PARAM_SEVERITY)!) == (NULL_STRING)) {
                                tempRecord.arrayValues.append(String(describing: (dataArray[j] ).value(forKey: RESPONSE_PARAM_TDR)!))
                            }
                        }
                        
                    }else if i == 5{
                        tempRecord.recordName = "vTDR(Feet)"
                        
                        for j in 0..<dataArray.count{
                            if !(String(describing: (dataArray[j] ).value(forKey: RESPONSE_PARAM_SEVERITY)!) == (NULL_STRING)) {
                                tempRecord.arrayValues.append(String(describing: (dataArray[j] ).value(forKey: RESPONSE_PARAM_VTDR)!))
                            }
                        }
                        
                    }else if i == 6{
                        tempRecord.recordName = "Corr"
                        
                        for j in 0..<dataArray.count{
                            if !(String(describing: (dataArray[j] ).value(forKey: RESPONSE_PARAM_SEVERITY)!) == (NULL_STRING)) {
                                tempRecord.arrayValues.append(String(describing: (dataArray[j] ).value(forKey: RESPONSE_PARAM_CORR)!))
                            }
                        }
                        
                    }else if i == 7{

                        tempRecord.recordName = "Freq(MHz)"
                        
                        for j in 0..<dataArray.count{
                            if !(String(describing: (dataArray[j] ).value(forKey: RESPONSE_PARAM_SEVERITY)!) == (NULL_STRING)) {
                                tempRecord.arrayValues.append(String(describing: (dataArray[j] ).value(forKey: RESPONSE_PARAM_FREQ)!))
                            }
                        }
                        
                    }else if i == 8{
                        tempRecord.recordName = "BW(MHz)"
                        
                        for j in 0..<dataArray.count{
                            if !(String(describing: (dataArray[j] ).value(forKey: RESPONSE_PARAM_SEVERITY)!) == (NULL_STRING)){
                                tempRecord.arrayValues.append(String(describing: (dataArray[j] ).value(forKey: RESPONSE_PARAM_BW)!))
                            }
                        }
                        
                    }
                    
                    self.bundleDataMDTable.append(tempRecord)
                }
                
                self.plotModemStatusTable()
                
                // Fetch Data for Charts
                self.arrayFrequency.removeAll()
                self.bundleICFRData.removeAll()
                self.bundleTapFreqChartData.removeAll()
                
                var tempVar = 0
                
                for eachData in dataArray {
                    
                    // Fetch Data for ICFR Chart
                    let bandwidth = Double(String(describing: (eachData ).value(forKey: RESPONSE_PARAM_BW)!))!
                    let freq = Double(String(describing: (eachData ).value(forKey: RESPONSE_PARAM_FREQ)!))!
                    var valueX = freq - bandwidth/2
                    let chartDataString = String(describing: (eachData ).value(forKey: RESPONSE_PARAM_PRE_EQ_FREQ_RSP_CHART_DATA)!)
                    
                    if let tempDic = UtilityHelper.convertToDictionary(text: chartDataString){
                        let arrayValueY = (tempDic.value(forKey: "y") as! NSArray) as! [String]
                        
                        let gap = bandwidth/Double(arrayValueY.count-1)
                        var tempFreqChartBundle: [ChartDataEntry] = []
                        
                        for value in arrayValueY {
                            let valueData = ChartDataEntry(x: Double(valueX),y: Double(value)!)
                            tempFreqChartBundle.append(valueData)
                            valueX += gap
                        }
                        
                        let lineData = LineChartDataSet(values: tempFreqChartBundle, label: "\(freq) MHz")
                        lineData.circleRadius = 0.0
                        lineData.colors = [self.arrayColor[tempVar]]
                        lineData.drawValuesEnabled = false
                        self.bundleICFRData.append(lineData)
                        self.arrayFrequency.append(freq)
                    }
                    
                    // Fetch Data for Tap Chart
                    let tapChartDataString = String(describing: (eachData ).value(forKey: RESPONSE_PARAM_PRE_EQ_TAP_CHART_DATA)!)
                    
                    
                    if let tempDic = UtilityHelper.convertToDictionary(text: tapChartDataString){
                        
                        let arrayTapChartValueY = ((tempDic.value(forKey: "y") as! NSArray) as! [String]).map { Double($0)!}
                        
                         var minY:Double = 0
                        
                        if arrayTapChartValueY.count > 0{
                            minY = arrayTapChartValueY.min()!.rounded(.down)
                        }
                        
                        var tempBundleBarDataEntry: [BarChartDataEntry] = []
                        tempBundleBarDataEntry.append(BarChartDataEntry(x: 0,yValues: [0,0]))
                        var tapValuex = 1
                        
                        for valueY in arrayTapChartValueY {
                            let barChartEntry = BarChartDataEntry(x: Double(tapValuex),yValues: [minY-valueY, valueY])
                            tempBundleBarDataEntry.append(barChartEntry)
                            tapValuex += 1
                        }
                        
                        let barData = BarChartDataSet(values: tempBundleBarDataEntry, label: "")
                        barData.stackLabels = ["\(freq)MHz",""]
                        barData.colors = [self.arrayColor[tempVar],COLOR_NONE]
                        
                        let barChartData = BarChartData()
                        barChartData.addDataSet(barData)
                        barChartData.barWidth = 0.50
                        barChartData.setDrawValues(false)
                        barChartData.highlightEnabled = false
                        
                        self.bundleTapFreqChartData.append(barChartData)
                    }
                    
                    tempVar += 1
                    
                    if tempVar >= self.arrayColor.count {
                        tempVar = 0
                    }
                }
                
                self.loadDSData(forModem: self.exposedMacAddress)
                
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
    
    
    func sortArrayForChartData(array: NSArray) -> [NSDictionary] {
        
        var returnArray: [NSDictionary] = []
        
        for record in array {
            returnArray.append(record as! NSDictionary)
        }
        
        for _ in 1...returnArray.count {
            for j in 1...returnArray.count - 1 {
                let freq1 = Double(String(describing: ((returnArray[j-1]).value(forKey: RESPONSE_PARAM_FREQ)!)))!
                let freq2 = Double(String(describing: ((returnArray[j]).value(forKey: RESPONSE_PARAM_FREQ)!)))!
                
                if freq1 > freq2 {
                    returnArray.swapAt(j, j-1)
                }
            }
        }
        
        return returnArray
    }
    
    
    func performRescan(forModem modemMac : String){
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username,
                              REQ_PARAM_MAC_ADDRESS : modemMac
            ] as [String : Any];
        
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_RE_SCAN_MODEM, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_RESCAN_MODEM, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                self.getDetails(forModem: self.exposedMacAddress)
                
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
                let tempTableHeaderDS = TableHeaderDS()
                
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
                    var tempRecord = DownstreamDetailDS()
                    
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
                self.populateFrequencySection()
                
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
                        labelForCell.text = bundleDataDSTable[i-1].frequency.checkNullString()
                        labelForCell.textAlignment = .center
                        
                    }else if j == 2{
                        labelForCell.text = bundleDataDSTable[i-1].power.checkNullString()
                        labelForCell.textAlignment = .center
                        
                    }else if j == 3{
                        labelForCell.text = bundleDataDSTable[i-1].mer.checkNullString()
                        labelForCell.textAlignment = .center
                        
                    }else if j == 4{
                        labelForCell.text = bundleDataDSTable[i-1].cmCorrCw.checkNullString()
                        labelForCell.textAlignment = .center
                        
                    }else if j == 5{
                        labelForCell.text = bundleDataDSTable[i-1].cmUnCorrCw.checkNullString()
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
    
    
    @IBAction func btnActionRescan(_ sender: Any) {
        self.performRescan(forModem: exposedMacAddress)
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

