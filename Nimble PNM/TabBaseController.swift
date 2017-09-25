//
//  TabBaseController.swift
//  Nimble PNM
//
//  Created by ksolves on 17/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class TabBaseController: UITabBarController {

    let indexForAnalyzer = 2;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureUIComponents()
        
    }
    
    func configureUIComponents(){
        if let tabBartems = self.tabBar.items{
            let analyzerTabBarItem = tabBartems[indexForAnalyzer];
            analyzerTabBarItem.image = UIImage(named: "up-stream-grey")?.withRenderingMode(.alwaysOriginal)
            analyzerTabBarItem.selectedImage = UIImage(named: "up-stream-blue")?.withRenderingMode(.alwaysOriginal)
        }
        
        
    }
    
    
    
    
    
    
    
    
    
}
