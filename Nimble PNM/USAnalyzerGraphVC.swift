//
//  USAnalyzerGraphVC.swift
//  Nimble PNM
//
//  Created by ksolves on 06/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class USAnalyzerGraphVC: BaseVC {

    var bundleLoadingData : NSDictionary!
    var bundleLoadingSetting : NSDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }
    
    @IBAction func btnActionLogout(_ sender: Any) {
        //self.performLogout()
        self.performSegue(withIdentifier: "segue-to-us-analyzer-setting", sender: nil)
    }
    
    @IBAction func refreshGraphAsUnwindSegueReceived(segue: UIStoryboardSegue){
        print("Unwinded")
        
    }
    


}
