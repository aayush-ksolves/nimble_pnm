//
//  USAnalyzerSettingVC.swift
//  Nimble PNM
//
//  Created by ksolves on 24/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class USAnalyzerSettingVC: UIViewController,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableViewAnalyzerSetting: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        //Registering Cell Nibs
        
        tableViewAnalyzerSetting.register(UINib(nibName: "SwitchCell", bundle: nil) , forCellReuseIdentifier: "customswitch")
        tableViewAnalyzerSetting.register(UINib(nibName: "SliderCell", bundle: nil) , forCellReuseIdentifier: "customslider")
        
    }


    

    //MARK: UITable View Delegates and Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 4
        }else if section == 1{
            return 2
        }else{
            return 0
        }
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0{
//            return "Hold Line"
//        }else if section == 1{
//            return "Frequency (MHz)"
//        }else{
//            return ""
//        }
//    }
//    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        
        let headerView:HeaderViewAnalyzerSettings = Bundle.main.loadNibNamed("HeaderViewAnalyzerSettings", owner: self, options: nil)![0] as! HeaderViewAnalyzerSettings
        if section == 0{
            headerView.labelHeading.text = "Hold Line"
            
        }else if section == 1{
            headerView.labelHeading.text = "Frequency (MHz)"
            
        }else{
            headerView.labelHeading.text = ""
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "customswitch") as! SwitchCell
            return cell
            
        }else if sectionNo == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "customslider") as! SliderCell
            return cell
            
        }else{
            return UITableViewCell()
        }
        
        
    }
   

}
