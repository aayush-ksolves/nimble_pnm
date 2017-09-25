//
//  ChangePasswordVC.swift
//  Nimble PNM
//
//  Created by ksolves on 25/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class ChangePasswordVC: BaseVC,UITextFieldDelegate {

    @IBOutlet weak var labelHeadingChangePassword: UILabel!
    @IBOutlet weak var buttonOutletSave: UIButton!
    @IBOutlet weak var textfieldCurrentPassword: UITextField!
    @IBOutlet weak var textfieldNewPassword: UITextField!
    @IBOutlet weak var textfieldConfirmPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUIComponents()
    }
    
    func configureUIComponents(){
        self.labelHeadingChangePassword.text = TXT_LBL_CHANGE_PASS_HEAD
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.addLayers()
    }
    
    
    func addLayers(){
        self.textfieldCurrentPassword.addBorder(withColor: COLOR_BORDER_GRAY_MODIFIED, withWidth: 1.0)
        self.textfieldNewPassword.addBorder(withColor: COLOR_BORDER_GRAY_MODIFIED, withWidth: 1.0)
        self.textfieldConfirmPassword.addBorder(withColor: COLOR_BORDER_GRAY_MODIFIED, withWidth: 1.0)
        
    }
    
    
    @IBAction func btnActionSave(_ sender: Any) {
        if validate(){
            let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
            let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
            
            let loginParameters = [REQ_PARAM_AUTH_KEY : authKey,
                                   REQ_PARAM_NEW_PASS : self.textfieldNewPassword.text!,
                                   REQ_PARAM_USERNAME : username,
                                   REQ_PARAM_CURRENT_PASS : self.textfieldCurrentPassword.text!
            ];
            
            self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_PROFILE_CHANGE_PASSWORD, withParameters: loginParameters, withLoaderMessage: LOADER_MSG_PASSWORD_CHANGE, sucessCompletionHadler: {
                responseDict in
                
                let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
                let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
                
                if statusCode == 200{
                    let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_APP_NAME, message: statusMessage, buttonTitle: ALERT_BUTTON_OK, completionHandler: {
                        action in
                        self.navigationController?.popViewController(animated: true)
                    })
                    self.present(alert, animated: true, completion: nil)
                    
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
    
    
    func validate() -> Bool{
        let currentPassword = self.textfieldCurrentPassword.text?.trimmingCharacters(in: CharacterSet.controlCharacters)
        let newPassword = self.textfieldNewPassword.text?.trimmingCharacters(in: CharacterSet.controlCharacters)
        let confirmPassword = self.textfieldConfirmPassword.text?.trimmingCharacters(in: CharacterSet.controlCharacters)
        
        
        var message = ""
        if (currentPassword?.characters.count)! < 1{
            message = ALERT_MSG_CP_BLANK_CURRENT_PASSWORD
            
        }else if ((newPassword?.characters.count)! < 1){
            message = ALERT_MSG_CP_BLANK_NEW_PASSWORD
            
        }else if ((confirmPassword?.characters.count)! < 1){
            message = ALERT_MSG_CP_BLANK_CONFIRM_PASSWORD
            
        }else if ((confirmPassword?.characters.count)! < 6){
            message = ALERT_MSG_CP_PASSWORD_LENGTH
            
        }else if (newPassword != confirmPassword){
            message = ALERT_MSG_CP_NO_MATCH_PASSWORD
        }
        
        if message != ""{
            self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: message, withButtonTitle: ALERT_BUTTON_OK)
            return false
        }else{
            return true
        }
        
    }
    
    
   
    
    
    //MARK: UITextfield Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    @IBAction func btnActionLogout(_ sender: Any) {
        self.performLogout()
    }
    
    
}
