//
//  LoaderVC.swift
//  Nimble PNM
//
//  Created by ksolves on 18/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class LoaderVC: UIViewController {

    @IBOutlet weak var viewLoaderBackground: UIView!
    
    @IBOutlet weak var imgViewLoader: UIImageView!
    @IBOutlet weak var labelLoaderMessage: UILabel!
    
    var animatedImageArray : [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUIComponents()
        
    }
    
    func configureUIComponents(){
        animatedImageArray = [UIImage(named:"spinner-0")!,
                              UIImage(named:"spinner-1")!,
                              UIImage(named:"spinner-2")!,
                              UIImage(named:"spinner-3")!,
                              UIImage(named:"spinner-4")!,
                              UIImage(named:"spinner-5")!,
                              UIImage(named:"spinner-6")!
            
        ]
        
        
        self.imgViewLoader.animationImages = animatedImageArray;
        self.imgViewLoader.animationRepeatCount = 0;
        self.imgViewLoader.animationDuration = 0.5;
        
        self.viewLoaderBackground.addCornerRadius(radius: CORNER_RADIUS_STANDARD)
        

    }
    
    func setPresentationMode(shouldPresent : Bool, withMessage message: String = ""){
        if shouldPresent{
            self.imgViewLoader.startAnimating()
            self.labelLoaderMessage.text = message
        }else{
            self.imgViewLoader.stopAnimating()
        }
    }
    
    
    
    
    

}
