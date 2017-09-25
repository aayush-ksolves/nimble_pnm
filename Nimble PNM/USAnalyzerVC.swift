//
//  USAnalyzerVC.swift
//  Nimble PNM
//
//  Created by ksolves on 17/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class USAnalyzerVC: BaseVC {

    @IBOutlet weak var btnOutletLogout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

  
   
    
    @IBAction func btnActionLogout(_ sender: Any) {
        self.performLogout()
    }
  

}
