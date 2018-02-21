//
//  ViewController.swift
//  Nimble PNM
//
//  Created by ksolves on 12/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit


class SyncMobileVC: UIViewController,BarCodeScannerDelegate {

    @IBOutlet weak var viewTopTitleContainer: UIView!
    @IBOutlet weak var constraintLabelTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var btnOutletScanCode: UIButton!
    @IBOutlet weak var labelInstructionsTop: UILabel!
    @IBOutlet weak var labelScreenTitle: UILabel!
    
    @IBOutlet weak var labelCurrentSettingsURL: UILabel!
    
    var isLoadedAsSettingVC : Bool = false;
    var isCodeOverwritten = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUIComponents()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isCodeOverwritten{
            if let settingsURL = USER_DEFAULTS.value(forKey: DEFAULTS_SETTINGS_URL){
                BASE_URL = settingsURL as! String
                self.performSegue(withIdentifier: "seguetologin", sender: nil)
            }
        }
    }
    
    func configureUIComponents(){
        
        self.btnOutletScanCode .setTitle(TXT_BTN_SCAN_CODE, for: .normal);
        self.labelInstructionsTop.text = TXT_LBL_INSTRUCTION_SCAN_FROM_WHERE;
        
        if isLoadedAsSettingVC{
            self.labelCurrentSettingsURL.text = "Current URL :  \(USER_DEFAULTS.value(forKey: DEFAULTS_SETTINGS_URL) as! String)"
            self.labelCurrentSettingsURL.isHidden = false
            self.shouldHideTopTitleContainer(shouldHide: true)
            
        }else{
            self.labelCurrentSettingsURL.isHidden = true
            self.shouldHideTopTitleContainer(shouldHide: false)
        }
        
    }
    
    func shouldHideTopTitleContainer(shouldHide: Bool){
        if shouldHide {
            self.viewTopTitleContainer.isHidden = true
            self.constraintLabelTitleHeight.constant = 0
        }else{
            self.viewTopTitleContainer.isHidden = false
            self.constraintLabelTitleHeight.constant = 64
        }
    }
    
    func saveToDefaultsAndMove(value:String){
        isCodeOverwritten = true;
        USER_DEFAULTS.set(value, forKey: DEFAULTS_SETTINGS_URL)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguetobarcodescanner"{
            let destinationController = segue.destination as! BarCodeScannerVC
            destinationController.delegate = self
        }
    }
    
    //MARK: Bar Code Scanner Delegates
    func scanningCompleteWithDataString(dataString: String) {
        self.saveToDefaultsAndMove(value:dataString)
        
    }
    
    
    func scanningFailedDueToReason(reasonCode: Int!) {
        print("Scanning Failed Due To Reason code \(reasonCode!)")
    }
    
    
    //MARK: Actions
    @IBAction func btnActionScanCode(_ sender: Any) {
        isCodeOverwritten = false;
        self.performSegue(withIdentifier: "seguetobarcodescanner", sender: nil)
    }
    
}

