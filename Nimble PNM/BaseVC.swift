//
//  BaseVC.swift
//  Nimble PNM
//
//  Created by ksolves on 17/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {

    let networkManager : AlamofireHelper = APP_DELEGATE.networkManager
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    
    func performLogout(){
        let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_APP_NAME, message: ALERT_MSG_LOGOUT_CONFIRM, buttonTitle1: ALERT_BUTTON_CANCEL, buttonTitle2: ALERT_BUTTON_LOGOUT, buttonStyle1: .cancel, buttonStyle2: .destructive, completionHandler1: {
            action in
            //Do Nothing
        }, completionHandler2: {
            action in
            self.fireHttpServiceToLogout()
            
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func performLogoutAsSessionExpiredDetected(){
        let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_APP_NAME, message: ALERT_MSG_SESSION_EXPIRED, buttonTitle: ALERT_BUTTON_OK, buttonStyle: .default, completionHandler: {
            action in
            self.clearDefaultsAndPresentLoginScreenIdeally()
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func fireHttpServiceToLogout(){
        if let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY){
            if let  username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID){
                let paramDict : [String: Any] = [REQ_PARAM_USERNAME : username,
                                                 REQ_PARAM_AUTH_KEY : authKey];
                
                
                self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_LOGOUT, withParameters: paramDict, withLoaderMessage: LOADER_MSG_LOGOUT, sucessCompletionHadler: {
                    responseDict in
                    
                    let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
                    //let statusMessage = String(describing: responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
                    
                    if statusCode == 200{
                        self.clearDefaultsAndPresentLoginScreenIdeally()
                        
                    }else if statusCode == 401{
                        self.performLogoutAsSessionExpiredDetected()
                        

                        
                    }else{
                        self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: ERROR_UNKNOWN, withButtonTitle: ALERT_BUTTON_OK)
                    }
                    
                }, failureCompletionHandler: {
                    (errorTitle, errorMessage) in
                    self.displayAlert(withTitle: errorTitle, withMessage: errorMessage, withButtonTitle: ALERT_BUTTON_OK)
                    
                })
                
                
            }else{
                print("Cannot Logout. Value for Username Not Found")
            }
        }else{
            print("Cannot Logout. Value for Auth Key Not Found")
        }
    }
    
    
    
    //Helper Functions
    func displayAlert(withTitle : String, withMessage: String, withButtonTitle buttonTitle:String){
        let alert = UtilityHelper.composeAlertWith(title: withTitle, message: withMessage, buttonTitle: buttonTitle, completionHandler: nil)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func clearDefaultsAndPresentLoginScreenIdeally(){
        USER_DEFAULTS.removeObject(forKey: DEFAULTS_IS_LOGGED_IN)
        
        self.navigationController?.dismiss(animated: true, completion: {
            self.tabBarController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func startHandlingLocationUpdate(isCrucial : Bool = false){
        let response = APP_DELEGATE.locationHelper.startUpdating()
        if (response == CONST_MSG_LOCATION_SERVICE_GRANTED){
                //Location Updates has been started
            
        }else{
            let alert = UtilityHelper.composeAlertWith(title: APP_NAME, message: response, buttonTitle: ALERT_BUTTON_OK, completionHandler: {
                action in
                if isCrucial{
                    self.navigationController?.popViewController(animated: true)
                }else{
                    //Do Nothing
                }
            })
            self.present(alert, animated: true, completion: nil)

        }
        
    }
    
    func stopHandlingUpdates(){
        APP_DELEGATE.locationHelper.stopUpdating()
    }
    
    
    
    
}
