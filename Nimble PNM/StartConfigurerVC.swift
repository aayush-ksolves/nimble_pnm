//
//  StartConfigurerVC.swift
//  Nimble PNM
//
//  Created by ksolves on 14/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class StartConfigurerVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.checkAndProceedInNavigation()
    }
   
    
    func checkAndProceedInNavigation(){
        //Checking Defaults
//    USER_DEFAULTS.set(BASE_URL, forKey: DEFAULTS_SETTINGS_URL)
        
        if let settingsURL = USER_DEFAULTS.value(forKey: DEFAULTS_SETTINGS_URL){
            //WE CAN SET SETTINGS URL HERE
            BASE_URL = settingsURL as! String
            self.performSegue(withIdentifier: "seguetologin", sender: nil)
            
        }else{
            //Segue To Settings
            self.performSegue(withIdentifier: "seguetosyncmobile", sender: nil)
        }
    }
    
    
    
}
