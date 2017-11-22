//
//  USAnalyzerSettingVC.swift
//  Nimble PNM
//
//  Created by ksolves on 24/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit
import Foundation

class USAnalyzerSettingVC: BaseVC,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate,UIPickerViewDataSource {

    @IBOutlet weak var bottomConstraintTableView: NSLayoutConstraint!
    var pickerHolder : CustomPickerView!
    var pickerView : UIPickerView!
    @IBOutlet weak var tableViewAnalyzerSetting: UITableView!
    
    let bundlePicker : [String] = ["IP Address","Mac Address","Customer Name"]
    let bundleType = ["ipAddress","mac_address","customer_name"]
    let bundleFirstSectionEntities = ["Show Live","Show Max","Show Min","Show Ingress"]
    let bundleSecondSectionEntities = ["Start","Stop","Polling"]
    
    var selectedIndex = 1
    var selectedType: String!
    var globalTextfieldForOptions : UITextField!
    var globalTextfieldForFilterText : UITextField!
    
    var globalLabelValueStartFreq = UILabel()
    var globalLabelValueStopFreq = UILabel()
    var globalLabelValuePolling = UILabel()
    
    var valueStartFreq = "5"
    var valueStopFreq = "42"
    var valuePolling = 1
    
    var exposedMacAddress = ""
    var stringForMacAddress = ""
    
    var globalValueForSwitchLive = false
    var globalValueForSwitchMax = false
    var globalValueForSwitchMin = false
    var globalValueForSwitchIngress = false
    
    var USAnalyzerGraphVC : USAnalyzerGraphVC!
    var selectedUSPort : UpstreamPortListDS!
    var scrollViewList = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUIComponents()
        
    }
    
    func configureUIComponents(){
        
        tableViewAnalyzerSetting.register(UINib(nibName: "SwitchCell", bundle: nil) , forCellReuseIdentifier: "customswitch")
        tableViewAnalyzerSetting.register(UINib(nibName: "SliderCell", bundle: nil) , forCellReuseIdentifier: "customslider")
        tableViewAnalyzerSetting.register(UINib(nibName: "TextfieldCell", bundle: nil) , forCellReuseIdentifier: "textfieldcell")
        
        globalLabelValueStartFreq.text = valueStartFreq
        globalLabelValueStopFreq.text = valueStopFreq
        stringForMacAddress = exposedMacAddress
        selectedType = bundleType[selectedIndex]
        
        self.navigationItem.hidesBackButton = true
        self.addKeyboardObservers()
        self.configurePicker()
        
    }

    func configurePicker(){
        //Configuring Picker
        pickerHolder = Bundle.main.loadNibNamed("CustomPickerView", owner: self, options: nil)?[0] as! CustomPickerView
        pickerHolder.buttonOutletDone.addTarget(self, action: #selector(buttonPickerDonePressed(_:)), for: .touchUpInside)
        pickerHolder.buttonOutletCancel.addTarget(self, action: #selector(buttonPickerCancelPressed(_:)), for: .touchUpInside)
        
        pickerView = pickerHolder.pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerHolder.labelPickerHeading.text = "Filter by"
        
    }
    
    
    func addKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        //keyboardWillHide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    
    //Function Handling Keyboard Appearance
    @objc func keyboardWillShow(_ notification : NSNotification){
        
        if let keyboardSize = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
            bottomConstraintTableView.constant = keyboardSize.height - 49
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
            
            
        }
    }
    
    
    //Function handling keyboard dissappearance
    @objc func keyboardWillHide(_ notification : NSNotification){
        
        bottomConstraintTableView.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    
    
    @objc func buttonPickerDonePressed(_ sender: UIButton){
        selectedIndex = self.pickerView.selectedRow(inComponent: 0)
        if selectedIndex != -1{
            
            UIView.animate(withDuration: 0.0, animations: {
                //self.tableViewAnalyzerSetting.scrollToRow(at: IndexPath(row: 0, section: 2), at: .none, animated: true)
            }, completion: {
                
                (isfinished) in
                self.globalTextfieldForOptions.resignFirstResponder()
                let cell = self.tableViewAnalyzerSetting.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextfieldCell
                cell.textfieldMain.text = self.bundlePicker[self.selectedIndex]
                self.selectedType = self.bundleType[self.selectedIndex]
                
            })
        }

    }
    
    @objc func buttonPickerCancelPressed(_ sender: UIButton){
        globalTextfieldForOptions.resignFirstResponder()
    }


    //MARK: UITable View Delegates and Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return 4
        }else if section == 2{
            return 3
        }else if section == 0{
            return 1
        }else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        if section == 0{
            return 120.0
        }else{
            return UITableViewAutomaticDimension
        }
    }
    
 
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView:HeaderViewAnalyzerSettings = Bundle.main.loadNibNamed("HeaderViewAnalyzerSettings", owner: self, options: nil)![0] as! HeaderViewAnalyzerSettings
        if section == 0{
            headerView.labelHeading.text = "Search Filter"
            
        }else if section == 1{
            headerView.labelHeading.text = "Hold Line"
            
        }else if section == 2{
            headerView.labelHeading.text = "Frequency (MHz)"
            
        }else{
            
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cellNo = indexPath.row
        let sectionNo = indexPath.section
        
        if sectionNo == 1{
            let cellNo = indexPath.row
            let cell = tableView.dequeueReusableCell(withIdentifier: "customswitch") as! SwitchCell
            cell.labelValue.text = bundleFirstSectionEntities[cellNo]
            
            if cellNo == 0{
                cell.switchOutlet.tag = 1000
                cell.switchOutlet.setOn(globalValueForSwitchLive, animated: true)
                
            }else if cellNo == 1{
                cell.switchOutlet.tag = 1001
                cell.switchOutlet.setOn(globalValueForSwitchMax, animated: true)
                
            }else if cellNo == 2{
                cell.switchOutlet.tag = 1002
                cell.switchOutlet.setOn(globalValueForSwitchMin, animated: true)
                
            }else{
                cell.switchOutlet.tag = 1003
                cell.switchOutlet.setOn(globalValueForSwitchIngress, animated: true)
                
            }
            
            cell.switchOutlet.addTarget(self, action: #selector(switchValueAltered(_:)), for: .valueChanged)
            
            return cell
            
        }else if sectionNo == 2{
            let cellNo = indexPath.row
            
            
            if cellNo == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "customslider") as! SliderCell
                cell.labelSliderTitle.text = bundleSecondSectionEntities[cellNo]
                cell.sliderOutlet.removeTarget(self, action: nil, for: .valueChanged)
                
                cell.sliderOutlet.minimumValue = 5
                cell.sliderOutlet.maximumValue = 85
    
                cell.sliderOutlet.setValue((Float(valueStartFreq)!), animated: false)

                cell.labelSliderCurrentValue.text = valueStartFreq
                globalLabelValueStartFreq = cell.labelSliderCurrentValue
                
                cell.sliderOutlet.addTarget(self, action: #selector(sliderDidChangedForFirst(_:)), for: .valueChanged)
                
                return cell
                
            }else if cellNo == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "customslider") as! SliderCell
                cell.labelSliderTitle.text = bundleSecondSectionEntities[cellNo]
                cell.sliderOutlet.removeTarget(self, action: nil, for: .valueChanged)
                cell.sliderOutlet.minimumValue = 5
                cell.sliderOutlet.maximumValue = 85
                
                cell.sliderOutlet.setValue((Float(valueStopFreq)!), animated: false)
                
                cell.labelSliderCurrentValue.text = valueStopFreq
                globalLabelValueStopFreq = cell.labelSliderCurrentValue
                
                cell.sliderOutlet.addTarget(self, action: #selector(sliderDidChangedForSecond(_:)), for: .valueChanged)
                
                return cell
                
            }else if cellNo == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "customslider") as! SliderCell
                cell.labelSliderTitle.text = bundleSecondSectionEntities[cellNo]
                cell.sliderOutlet.removeTarget(self, action: nil, for: .valueChanged)
                cell.sliderOutlet.minimumValue = 1
                cell.sliderOutlet.maximumValue = 3
                
                cell.sliderOutlet.setValue((Float(valuePolling)), animated: false)
                
                cell.labelSliderCurrentValue.text = "\(valuePolling)"
                globalLabelValuePolling = cell.labelSliderCurrentValue
                
                cell.sliderOutlet.addTarget(self, action: #selector(sliderDidChangedForThird(_:)), for: .valueChanged)
                
                return cell
                
            }else {
                return UITableViewCell()
            }
            
            
        }else if sectionNo == 0{

            let cell = tableView.dequeueReusableCell(withIdentifier: "textfieldcell") as! TextfieldCell
            cell.textfieldMain.placeholder = "Filter By"
            cell.textfieldMain.delegate = self
            cell.textfieldMain.inputView = self.pickerHolder
            cell.textfieldMain.textAlignment = .center
            cell.textfieldMain.text = bundlePicker[selectedIndex]
            self.globalTextfieldForOptions = cell.textfieldMain
            
            cell.textfieldContent.delegate = self
            cell.textfieldContent.textAlignment = .center
            cell.textfieldContent.text = stringForMacAddress
            cell.textfieldContent.addTarget(self, action: #selector(changeValueForSearchFilter(_:)), for: .editingChanged)
            
            self.globalTextfieldForFilterText = cell.textfieldContent
            
            return cell
            
        }else{
            return UITableViewCell()
        }
        
    }
    
    
    @objc func switchValueAltered(_ sender : UISwitch){
        let tag = sender.tag
        let valueToSet = sender.isOn
        if tag == 1000{
            globalValueForSwitchLive = valueToSet
            
        }else if tag == 1001{
            globalValueForSwitchMax = valueToSet
            
        }else if tag == 1002{
            globalValueForSwitchMin = valueToSet
            
        }else if tag == 1003{
            globalValueForSwitchIngress = valueToSet
            
        }else{
            
        }
    }
    
    
    @objc func sliderDidChangedForFirst(_ sender: UISlider){
        valueStartFreq = "\(Int(sender.value))"
        globalLabelValueStartFreq.text = valueStartFreq
        
    }
    
    @objc func sliderDidChangedForSecond(_ sender: UISlider){
        valueStopFreq = "\(Int(sender.value))"
        globalLabelValueStopFreq.text = valueStopFreq
    }
    
    @objc func sliderDidChangedForThird(_ sender: UISlider){
        valuePolling = Int(roundf(sender.value))
        sender.setValue(Float(valuePolling), animated: true)
        globalLabelValuePolling.text = "\(valuePolling)"
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == globalTextfieldForOptions{
            return false
        }else{
            return true
        }
        
    }
    
    //MARK: UIPickerViewDelegates and Datasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.bundlePicker.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.bundlePicker[row]
    }
    
    //MARK: UITextfieldDelegates 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == globalTextfieldForFilterText {
            removeSuggestionList()
        }
    }
    

    @IBAction func btnActionCloseSetting(_ sender: Any) {
        closeSettingViewController()
    }
    
    
    @IBAction func buttonActionApplySettings(_ sender: UIButton) {
        
        if globalTextfieldForFilterText.text != "" {
            let tempArray = (globalTextfieldForFilterText.text!).components(separatedBy: "-")
            if tempArray.count > 0 {
                let macAddress = tempArray.last!.trimmingCharacters(in: .whitespaces)
                
                if UtilityHelper.isValidMacAddress(testStr: macAddress) {
                    USAnalyzerGraphVC.macAddressActive = macAddress
                    USAnalyzerGraphVC.isFirstTime = true
                }else {
                    self.displayAlertForValidMac()
                    return
                }
                
            }else {
                self.displayAlertForValidMac()
                return
            }
        }else {
            if exposedMacAddress != "" {
                USAnalyzerGraphVC.macAddressActive = ""
                USAnalyzerGraphVC.isFirstTime = true
            }
        }
        
        USAnalyzerGraphVC.valueStartParam = valueStartFreq
        USAnalyzerGraphVC.valueParamStop = valueStopFreq
        USAnalyzerGraphVC.valuePolling = valuePolling
        USAnalyzerGraphVC.shouldShowLiveData = globalValueForSwitchLive
        USAnalyzerGraphVC.shouldShowMaxData = globalValueForSwitchMax
        USAnalyzerGraphVC.shouldShowMinData = globalValueForSwitchMin
        USAnalyzerGraphVC.shouldShowIngressData = globalValueForSwitchIngress
        USAnalyzerGraphVC.shouldRefreshGraph = true
        
        closeSettingViewController()
    }
    
    func displayAlertForValidMac(){
        self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: "Please enter valid entry", withButtonTitle: ALERT_BUTTON_OK)
    }
    
    func closeSettingViewController(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.globalTextfieldForFilterText {
            if globalTextfieldForOptions.text == "" {
                self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: "Please select filter by option", withButtonTitle: ALERT_BUTTON_OK)
                
                return false
            }else {
                return true
            }
        }
        
        return true
    }
    
    
    @objc func changeValueForSearchFilter(_ textField: UITextField) {
        
        stringForMacAddress = textField.text!
        removeSuggestionList()
        
        if textField.text != "" {
            getSuggestionList(forString: textField.text!)
        }
    }
    
    func showSuggestionList(forData: NSArray) {
        
        let scrollViewWidth = Int(self.view.frame.size.width - 20)
        let maxHeight = 100
        let heightForOneSection = 30
        let finalHeight = min(maxHeight, heightForOneSection*forData.count)
        let xPosition = 10
        let yPosition = 120 - finalHeight
        var contentHeight = 0
        
        scrollViewList = UIScrollView(frame: CGRect(x: xPosition,y: yPosition,width: scrollViewWidth,height: finalHeight))
        scrollViewList.backgroundColor = COLOR_WHITE_AS_GREY
        
        for eachData in forData {
            let button = UIButton(frame: CGRect(x: 10,y: contentHeight,width:scrollViewWidth - 20,height: heightForOneSection))
            let dataDic = eachData as! NSDictionary
            
            button.setTitle((dataDic.value(forKey: "text") as! String), for: .normal)
            button.setTitleColor(UIColor.gray, for: .normal)
            button.backgroundColor = COLOR_NONE
            button.addTarget(self, action: #selector(buttonInSuggestionPressed(_:)), for: .touchUpInside)
            
            scrollViewList.addSubview(button)
            contentHeight += heightForOneSection
        }
        
        scrollViewList.contentSize = CGSize(width: scrollViewWidth, height: contentHeight)
        self.view.addSubview(scrollViewList)
    }
    
    @objc func buttonInSuggestionPressed(_ sender: UIButton) {
        let buttonTitle = sender.currentTitle!
        stringForMacAddress = buttonTitle
        globalTextfieldForFilterText.text = stringForMacAddress
        removeSuggestionList()
    }
    
    func removeSuggestionList() {
        scrollViewList.removeFromSuperview()
    }
    
    func getSuggestionList(forString string: String) {
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_AUTH_KEY : authKey,
                              REQ_PARAM_USERNAME : username,
                              REQ_PARAM_UPSTREAMPORT : selectedUSPort.id,
                              REQ_PARAM_LIKE: string,
                              REQ_PARAM_INTERFACE_NAME: selectedUSPort.interfaceName,
                              REQ_PARAM_PAGE: "1",
                              REQ_PARAM_TYPE : selectedType,
            ] as [String : Any];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderWithoutLoaderTo(url: SERVICE_URL_GET_MACS_BY_US_PORT, withParameters: dictParameters, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            
            if statusCode == 200{
                let dataArray = responseDict.value(forKey: RESPONSE_PARAM_DATA)! as! NSArray
                let dataListArray = (dataArray[0] as! NSDictionary).value(forKey: RESPONSE_PARAM_LIST)! as! NSArray
                
                if dataListArray.count > 1 {
                    self.showSuggestionList(forData: dataListArray)
                }
                
            }else if statusCode == 401{
                self.performLogoutAsSessionExpiredDetected()
            }else{
                
            }
            
        },failureCompletionHandler: {
            (errorTitle,errorMessage) in
            
        })
        
    }
    
}
