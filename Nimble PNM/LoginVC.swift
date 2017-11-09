//
//  LoginVC.swift
//  Nimble PNM
//
//  Created by ksolves on 14/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import Foundation
import UIKit


class LoginVC: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var constraintNavHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewLoginHolder: UIView!
    
    @IBOutlet weak var textfieldUsername: UITextField!
    @IBOutlet weak var textfieldPassword: UITextField!
    
    
    @IBOutlet weak var btnOutletLogin: UIButton!
    
    let networkManager : AlamofireHelper = APP_DELEGATE.networkManager
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUIComponents()
        
        //Checking Current Login Status
        if isUserLoggedIn(){
            //Perform Auto Login
            if let username = USER_DEFAULTS.value(forKey: DEFAULTS_AUTO_LOGIN_USERNAME){
                if let password = USER_DEFAULTS.value(forKey: DEFAULTS_AUTO_LOGIN_PASSWORD){
                    self.textfieldUsername.text = (username as! String);
                    self.textfieldPassword.text = (password as! String);
                    
                    self.btnOutletLogin.sendActions(for: .touchUpInside)
                    
                }
            }
            
        }else{
            //Dont do Anything
            
        }
        
    }
    
    
    func isUserLoggedIn() -> Bool{
        if USER_DEFAULTS.value(forKey: DEFAULTS_IS_LOGGED_IN) != nil{
            return true
        }else{
            return false
        }
    }
    
    
    func configureUIComponents(){
        //self.addLayers()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.addLayers()
    }
    
    
    func addLayers(){
        self.textfieldUsername.addBorder(withLeftEnabled: false, withRightEnabled: false, withTopEnabled: false, withBottomEnabled: true, withColor: COLOR_BORDER_GRAY_MODIFIED, withWidth: 1.0);
        
        self.textfieldPassword.addBorder(withLeftEnabled: false, withRightEnabled: false, withTopEnabled: false, withBottomEnabled: true, withColor: COLOR_BORDER_GRAY_MODIFIED, withWidth: 1.0);
    }
    
    func clearFormFields(){
        self.textfieldUsername.text = ""
        self.textfieldPassword.text = ""
    }
    
    
    func validate() -> Bool{
        let username = self.textfieldUsername.text?.trimmingCharacters(in: CharacterSet.controlCharacters)
        let password = self.textfieldPassword.text?.trimmingCharacters(in: CharacterSet.controlCharacters)
        
        var message = ""
        if (username?.characters.count)! < 1{
            message = ALERT_MSG_LOGIN_BLANK_USERNAME
        }else if ((password?.characters.count)! < 1){
            message = ALERT_MSG_LOGIN_BLANK_PASSWORD
        }
        
        if message != ""{
            let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_APP_NAME, message: message, buttonTitle: ALERT_BUTTON_OK, completionHandler: nil)
            self.present(alert, animated: true, completion: nil)
            return false
        }else{
            return true
        }
        
    }
    
    @IBAction func btnActionLogin(_ sender: Any) {
        if validate(){
            
            
            let loginParameters = [REQ_PARAM_USERNAME:self.textfieldUsername.text! ,
                                   REQ_PARAM_PASSWORD:self.textfieldPassword.text!
                                   ];
            
            self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_LOGIN, withParameters: loginParameters, withLoaderMessage: LOADER_MSG_LOGIN, sucessCompletionHadler: {
                responseDict in
                
                guard let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as? Int else{
                    print("Status Code Cannot Be Converted To Integer")
                    return
                }
                
                guard let statusMessage = responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG) else{
                    print("Status Message Key Can not be found")
                    return
                }
                

                if statusCode == 200{
                    
                    
                    let dataArray = responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSArray
                    let dataDict = dataArray[0] as! NSDictionary
                    
                    
                    let authKey = String(describing:dataDict.value(forKey: RESPONSE_PARAM_AUTH_KEY)!)
                    let emailId = String(describing:dataDict.value(forKey: RESPONSE_PARAM_EMAIL_ID)!)
                    let firstName = String(describing:dataDict.value(forKey: RESPONSE_PARAM_FIRST_NAME)!)
                    let lastName = String(describing:dataDict.value(forKey: RESPONSE_PARAM_LAST_NAME)!)
                    let id = String(describing:dataDict.value(forKey: RESPONSE_PARAM_ID)!)
                    let userType = String(describing:dataDict.value(forKey: RESPONSE_PARAM_USER_TYPE)!)
                    
                    USER_DEFAULTS.set(authKey, forKey: DEFAULTS_AUTH_KEY)
                    USER_DEFAULTS.set(emailId, forKey: DEFAULTS_EMAIL_ID)
                    USER_DEFAULTS.set(firstName, forKey: DEFAULTS_FIRST_NAME)
                    USER_DEFAULTS.set(lastName, forKey: DEFAULTS_LAST_NAME)
                    USER_DEFAULTS.set(id, forKey: DEFAULTS_ID)
                    USER_DEFAULTS.set(userType, forKey: DEFAULTS_USER_TYPE)
                    
                    USER_DEFAULTS.set(true, forKey: DEFAULTS_IS_LOGGED_IN);
                    USER_DEFAULTS.set(self.textfieldUsername.text!, forKey: DEFAULTS_AUTO_LOGIN_USERNAME)
                    USER_DEFAULTS.set(self.textfieldPassword.text!, forKey: DEFAULTS_AUTO_LOGIN_PASSWORD)
                    
                    self.clearFormFields()
                    self.performSegue(withIdentifier: "seguetohome", sender: nil)
                    
                    
                }else if statusCode == 226{
                    
                    guard let bundleDataArray = responseDict.value(forKey: RESPONSE_PARAM_DATA)! as? NSArray else{
                        print("Data Key can not be found")
                        return
                    }
                    
                    let dataDict = bundleDataArray[0] as! NSDictionary
                    
                    
                    guard let doLogout = dataDict.value(forKey: RESPONSE_PARAM_DO_LOGOUT) as? Int else{
                        print("Do Logout Key Cannot Be Found")
                        return
                    }
                    
                    guard let logoutURL = dataDict.value(forKey: RESPONSE_PARAM_LOGOUT_URL) as? String else{
                        print("logoutURL Key Cannot Be Found")
                        return
                    }
                    
//                    let logoutURL = "http://10.1.0.22/testing/master2/index.php/pnmservice/logoutAnotherPlace"
                    
                    guard let logoutKey = dataDict.value(forKey: RESPONSE_PARAM_LOGOUT_KEY) as? String else{
                        print("logoutKey Key Cannot Be Found")
                        return
                    }
                    
                    guard let userId = dataDict.value(forKey: RESPONSE_PARAM_USER_ID) as? String else{
                        print("userId Key Cannot Be Found")
                        return
                    }
                    
                    
                    //Compose Alert With Handler
                    let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_APP_NAME, message: statusMessage as! String, buttonTitle1: ALERT_BUTTON_CANCEL, buttonTitle2: ALERT_BUTTON_LOGOUT, buttonStyle1: .destructive, buttonStyle2: .default, completionHandler1: {
                        action in
                        //Do Nothing
                    }, completionHandler2: {
                        action in
                        
                        self.performLogoutFromAnotherPlace(usingURL: logoutURL, usingDoLogoutValue: doLogout, usingLogoutKey: logoutKey, usingUserId: userId)
                        
                    })
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }else{
                    self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: statusMessage as! String, withButtonTitle: ALERT_BUTTON_OK)
                }
                                
                
            },failureCompletionHandler: {
                (errorTitle,errorMessage) in
                self.displayAlert(withTitle: errorTitle, withMessage: errorMessage, withButtonTitle: ALERT_BUTTON_OK)
            })        
            
        }
        
    }
    
    
    func performLogoutFromAnotherPlace(usingURL url:String, usingDoLogoutValue doLogoutValue: Int, usingLogoutKey logoutKey : String, usingUserId userId : String){
        let parametersDict : [String:Any] = [REQ_PARAM_USER_ID: userId,
                              REQ_PARAM_DO_LOGOUT : doLogoutValue,
                              REQ_PARAM_LOGOUT_KEY : logoutKey
        ];
        
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: url, withParameters: parametersDict,withLoaderMessage: LOADER_MSG_ANOTHER_LOGOUT, isStandAloneURL: true, sucessCompletionHadler: {
            responseDict in
            
                let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
                
                if statusCode == 200{
                    self.btnOutletLogin.sendActions(for: .touchUpInside)
                }else{
                    self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: ERROR_UNKNOWN, withButtonTitle: ALERT_BUTTON_OK)
                }
        
            },failureCompletionHandler: {
            (errorTitle,errorMessage) in
            self.displayAlert(withTitle: errorTitle, withMessage: errorMessage, withButtonTitle: ALERT_BUTTON_OK)
        })
    }
    
    
    
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
       super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: {
            context in
            if size.width > size.height{
                //Rotating To Landscape
                self.constraintNavHeight.constant = 44;
            }else{
                //Rotating To Potrait
                self.constraintNavHeight.constant = 64;
            }
            self.addLayers()
            
        }, completion: {
            context in

        })
        
        
        
    }
    
    
    
    //MARK: UIText Field Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func displayAlert(withTitle : String, withMessage: String, withButtonTitle buttonTitle:String){
        let alert = UtilityHelper.composeAlertWith(title: withTitle, message: withMessage, buttonTitle: buttonTitle, completionHandler: nil)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
}
