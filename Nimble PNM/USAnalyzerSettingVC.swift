//
//  USAnalyzerSettingVC.swift
//  Nimble PNM
//
//  Created by ksolves on 24/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class USAnalyzerSettingVC: UIViewController,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate,UIPickerViewDataSource {

    @IBOutlet weak var bottomConstraintTableView: NSLayoutConstraint!
    var pickerHolder : CustomPickerView!
    var pickerView : UIPickerView!
    @IBOutlet weak var tableViewAnalyzerSetting: UITableView!
    
    let bundlePicker : [String] = ["IP Address","Mac Address","Name"]
    let bundleFirstSectionEntities = ["Live","Max","Min","Ingress"]
    let bundleSecondSectionEntities = ["Start","Stop"]
    
    var selectedIndex : Int!
    var globalTextfieldForOptions : UITextField!
    var globalTextfieldForFilterText : UITextField!
    
    var globalLabelValueForFirstSlider = UILabel()
    var globalLabelValueForSecondSlider = UILabel()
    
    
    var globalValueForSwitch1 = false
    var globalValueForSwitch2 = false
    var globalValueForSwitch3 = false
    var globalValueForSwitch4 = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUIComponents()
        
    }
    
    func configureUIComponents(){
        tableViewAnalyzerSetting.register(UINib(nibName: "SwitchCell", bundle: nil) , forCellReuseIdentifier: "customswitch")
        tableViewAnalyzerSetting.register(UINib(nibName: "SliderCell", bundle: nil) , forCellReuseIdentifier: "customslider")
        tableViewAnalyzerSetting.register(UINib(nibName: "TextfieldCell", bundle: nil) , forCellReuseIdentifier: "textfieldcell")
        
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
        
        globalLabelValueForFirstSlider.text = "0"
        globalLabelValueForSecondSlider.text = "0"
        
    }
    
    
    func addKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        //keyboardWillHide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    
    //Function Handling Keyboard Appearance
    func keyboardWillShow(_ notification : NSNotification){
        
        if let keyboardSize = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
            bottomConstraintTableView.constant = keyboardSize.height - 49
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
            
            
        }
    }
    
    
    //Function handling keyboard dissappearance
    func keyboardWillHide(_ notification : NSNotification){
        
        
        bottomConstraintTableView.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    
    
    func buttonPickerDonePressed(_ sender: UIButton){
        selectedIndex = self.pickerView.selectedRow(inComponent: 0)
        if selectedIndex != -1{
            
            UIView.animate(withDuration: 0.0, animations: {
                //self.tableViewAnalyzerSetting.scrollToRow(at: IndexPath(row: 0, section: 2), at: .none, animated: true)
            }, completion: {
                
                (isfinished) in
                self.globalTextfieldForOptions.resignFirstResponder()
                let cell = self.tableViewAnalyzerSetting.cellForRow(at: IndexPath(row: 0, section: 2)) as! TextfieldCell
                cell.textfieldMain.text = self.bundlePicker[self.selectedIndex]
                
            })
        }

    }
    
    func buttonPickerCancelPressed(_ sender: UIButton){
        globalTextfieldForOptions.resignFirstResponder()
        
    }


    //MARK: UITable View Delegates and Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 4
        }else if section == 1{
            return 2
        }else if section == 2{
            return 1
        }else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        if section == 2{
            return 96.0
        }else{
            return UITableViewAutomaticDimension
        }
    }
    
 
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView:HeaderViewAnalyzerSettings = Bundle.main.loadNibNamed("HeaderViewAnalyzerSettings", owner: self, options: nil)![0] as! HeaderViewAnalyzerSettings
        if section == 0{
            headerView.labelHeading.text = "Hold Line"
            
        }else if section == 1{
            headerView.labelHeading.text = "Frequency (MHz)"
            
        }else if section == 2{
            headerView.labelHeading.text = "Search Filter"
            
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
        
        
        if sectionNo == 0{
            let cellNo = indexPath.row
            let cell = tableView.dequeueReusableCell(withIdentifier: "customswitch") as! SwitchCell
            cell.labelValue.text = bundleFirstSectionEntities[cellNo]
            
            if cellNo == 0{
                cell.switchOutlet.tag = 1000
                cell.switchOutlet.setOn(globalValueForSwitch1, animated: true)
                
            }else if cellNo == 1{
                cell.switchOutlet.tag = 1001
                cell.switchOutlet.setOn(globalValueForSwitch2, animated: true)
                
            }else if cellNo == 2{
                cell.switchOutlet.tag = 1002
                cell.switchOutlet.setOn(globalValueForSwitch3, animated: true)
                
            }else{
                cell.switchOutlet.tag = 1003
                cell.switchOutlet.setOn(globalValueForSwitch4, animated: true)
                
            }
            
            cell.switchOutlet.addTarget(self, action: #selector(switchValueAltered(_:)), for: .valueChanged)
            
            return cell
            
        }else if sectionNo == 1{
            let cellNo = indexPath.row
            
            
            if cellNo == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "customslider") as! SliderCell
                cell.labelSliderTitle.text = bundleSecondSectionEntities[cellNo]
                cell.sliderOutlet.removeTarget(self, action: nil, for: .allEvents)
                cell.sliderOutlet.addTarget(self, action: #selector(sliderDidChangedForFirst(_:)), for: .valueChanged)
    
                cell.sliderOutlet.setValue((Float(globalLabelValueForFirstSlider.text!)! / 100), animated: true)
                
                globalLabelValueForFirstSlider = cell.labelSliderCurrentValue
                
                
                return cell
                
            }else if cellNo == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "customslider") as! SliderCell
                cell.labelSliderTitle.text = bundleSecondSectionEntities[cellNo]
                cell.sliderOutlet.removeTarget(self, action: nil, for: .valueChanged)
                cell.sliderOutlet.addTarget(self, action: #selector(sliderDidChangedForSecond(_:)), for: .valueChanged)
                
                cell.sliderOutlet.setValue((Float(globalLabelValueForSecondSlider.text!)! / 100), animated: true)
                
                globalLabelValueForSecondSlider = cell.labelSliderCurrentValue
                
                return cell
                
            }else {
                return UITableViewCell()
            }
            
            
        }else if sectionNo == 2{
            let cellNo = indexPath.row
            let cell = tableView.dequeueReusableCell(withIdentifier: "textfieldcell") as! TextfieldCell
            cell.textfieldMain.placeholder = "Filter By"
            cell.textfieldMain.delegate = self
            cell.textfieldMain.inputView = self.pickerHolder
            self.globalTextfieldForOptions = cell.textfieldMain
            cell.textfieldMain.textAlignment = .center
            
            
            self.globalTextfieldForFilterText = cell.textfieldContent
            cell.textfieldContent.delegate = self
            cell.textfieldContent.textAlignment = .center
            
            return cell
            
        }else{
            return UITableViewCell()
        }
        
        
    }
    
    
    func switchValueAltered(_ sender : UISwitch){
        let tag = sender.tag
        let valueToSet = sender.isOn
        if tag == 1000{
            globalValueForSwitch1 = valueToSet
            
        }else if tag == 1001{
            globalValueForSwitch2 = valueToSet
            
        }else if tag == 1002{
            globalValueForSwitch3 = valueToSet
            
        }else if tag == 1003{
            globalValueForSwitch4 = valueToSet
            
        }else{
            
        }
    }
    
    
    func sliderDidChangedForFirst(_ sender: UISlider){
        let floathundred = sender.value * 100
        globalLabelValueForFirstSlider.text = String(describing:Int(floathundred))
        
    }
    
    func sliderDidChangedForSecond(_ sender: UISlider){
        let floathundred = sender.value * 100
        globalLabelValueForSecondSlider.text = String(describing:Int(floathundred))
    
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
        self.globalTextfieldForFilterText.resignFirstResponder()
        return true
    }
    
    

    @IBAction func btnActionCloseSetting(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
   

}
