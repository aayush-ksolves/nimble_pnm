//
//  ImageViewerVC.swift
//  Nimble PNM
//
//  Created by KSolves on 10/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class ImageViewerVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var exposedImageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        imageView.af_setImage(withURL: URL(string:exposedImageURL)!)
        imageView.contentMode = .scaleAspectFit
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        print("Zooming")
        return imageView
    }
    
}
