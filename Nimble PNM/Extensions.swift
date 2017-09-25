//
//  Extensions.swift
//  Nimble PNM
//
//  Created by ksolves on 13/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import Foundation
import UIKit

extension UITextField{
    func setPlaceHolder(withText text:String,withColor color:UIColor, withfontName fontName:String, withSize size:CGFloat, shouldPlaceInsetIllusion shouldPlace:Bool){
        let attributes = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName : UIFont(name: fontName , size: size)!
        ]
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
        
        if shouldPlace{
            let rect = CGRect(x: 0, y: 0, width: 15, height: self.frame.size.height)
            let paddingView = UIView(frame: rect)
            
            self.leftView = paddingView
            self.leftViewMode = UITextFieldViewMode.always
        }
    }
    
    func placeIllusion(ofPixels pixels:CGFloat){
        let rect = CGRect(x: 0.0, y: 0.0, width: pixels, height: self.frame.size.height)
        let paddingView = UIView(frame: rect)
        
        self.leftView = paddingView
        self.leftViewMode = UITextFieldViewMode.always
    }
}
extension UIView{
    func addBorder(withColor: UIColor, withWidth: CGFloat){
        
        self.layer.borderWidth = withWidth;
        self.layer.borderColor = withColor.cgColor
        
        
    }
    
    
    func addBorder(withLeftEnabled:Bool, withRightEnabled : Bool, withTopEnabled : Bool, withBottomEnabled : Bool,withColor : UIColor, withWidth : CGFloat){
        
        let leftLayer : CALayer!
        let rightLayer : CALayer!
        let topLayer : CALayer!
        let bottomLayer : CALayer!
    
        
        if withLeftEnabled{
            
            
            if let sublayers = self.layer.sublayers{
                for eachLayer in sublayers{
                    if (eachLayer.value(forKey: "left") != nil){
                        eachLayer.removeFromSuperlayer()
                    }
                }
            }
            
            leftLayer = CALayer();
            leftLayer.backgroundColor = withColor.cgColor;
            
            var tempFrame = self.frame;
            tempFrame.size.width = withWidth;
            leftLayer.frame = tempFrame;
            
            self.layer.addSublayer(leftLayer)
            
            leftLayer.setValue(1, forKey: "left")
            
            
        }
        
        if withRightEnabled{
            
            if let sublayers = self.layer.sublayers{
                for eachLayer in sublayers{
                    if (eachLayer.value(forKey: "right") != nil){
                        eachLayer.removeFromSuperlayer()
                    }
                }
            }
            
            
            rightLayer = CALayer();
            rightLayer.backgroundColor = withColor.cgColor;
            
            var tempFrame = self.frame;
            tempFrame.origin.x = tempFrame.size.width-withWidth;
            tempFrame.size.width = withWidth;
            rightLayer.frame = tempFrame;
            
            self.layer.addSublayer(rightLayer)
            rightLayer.setValue(1, forKey: "right")
            
        }
        
        if withTopEnabled{
            
            
            if let sublayers = self.layer.sublayers{
                for eachLayer in sublayers{
                    if (eachLayer.value(forKey: "top") != nil){
                        eachLayer.removeFromSuperlayer()
                    }
                }
            }
            
            
            topLayer = CALayer();
            topLayer.backgroundColor = withColor.cgColor;
            
            var tempFrame = self.frame;
            tempFrame.size.height = withWidth;
            topLayer.frame = tempFrame;
            
            self.layer.addSublayer(topLayer)
            topLayer.setValue(1, forKey: "top")
            
            
        }
        
        if withBottomEnabled{
            
            if let sublayers = self.layer.sublayers{
                for eachLayer in sublayers{
                    if (eachLayer.value(forKey: "bottom") != nil){
                        eachLayer.removeFromSuperlayer()
                    }
                }
            }
            
            
            bottomLayer = CALayer();
            bottomLayer.backgroundColor = withColor.cgColor;
            
            var tempFrame = self.frame;
            tempFrame.origin.y = tempFrame.size.height - withWidth;
            tempFrame.size.height = withWidth
            bottomLayer.frame = tempFrame;
            
            self.layer.addSublayer(bottomLayer)
            bottomLayer.setValue(1, forKey: "bottom")
            
        }

    }
    
    func addShadow(withColor : UIColor){
        
        self.clipsToBounds = false;
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 1.0
        self.layer.shadowColor = withColor.cgColor
        self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        
    }
    
    func addCornerRadius(radius : CGFloat){
        self.layer.cornerRadius = radius
    }
    
    
    
    
    
}
