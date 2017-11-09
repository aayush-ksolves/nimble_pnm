//
//  UtilityHelper.swift
//  Nimble PNM
//
//  Created by ksolves on 13/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import Foundation
import UIKit

class UtilityHelper : NSObject{
    
    //MARK: Alert Handlers
    static func composeAlertWith(title: String!, message: String!, buttonTitle : String, buttonStyle : UIAlertActionStyle = .default,completionHandler : ((UIAlertAction) -> ())? ) -> UIAlertController{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert);
        
        let action = UIAlertAction(title: buttonTitle, style: buttonStyle, handler: completionHandler)
        alertController.addAction(action)
        
        return alertController
        
    }
    
    
    static func composeAlertWith(title: String!, message: String!, buttonTitle1 : String, buttonTitle2 : String, buttonStyle1 : UIAlertActionStyle, buttonStyle2 : UIAlertActionStyle,completionHandler1 :  ((UIAlertAction) -> ())?, completionHandler2 :  ((UIAlertAction) -> ())? ) -> UIAlertController{
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert);
        
        let action1 = UIAlertAction(title: buttonTitle1, style: buttonStyle1, handler: completionHandler1)
        let action2 = UIAlertAction(title: buttonTitle2, style: buttonStyle2, handler: completionHandler2)
        
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        return alertController
        
    }
    
    static func composeAlertWith(title: String!, message: String!, buttonTitle1 : String, buttonTitle2 : String, buttonTitle3 : String, buttonStyle1 : UIAlertActionStyle, buttonStyle2 : UIAlertActionStyle, buttonStyle3 : UIAlertActionStyle,completionHandler1 :  ((UIAlertAction) -> ())?, completionHandler2 :  ((UIAlertAction) -> ())?, completionHandler3 :  ((UIAlertAction) -> ())? ) -> UIAlertController{
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert);
        
        let action1 = UIAlertAction(title: buttonTitle1, style: buttonStyle1, handler: completionHandler1)
        let action2 = UIAlertAction(title: buttonTitle2, style: buttonStyle2, handler: completionHandler2)
        let action3 = UIAlertAction(title: buttonTitle3, style: buttonStyle3, handler: completionHandler2)
        
        
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        
        return alertController
        
    }
    
    
    static func decorateUILabelsInCellWith(part1 startString:String, part2 endString:String ,withPart1Size size1:CGFloat,withPart2Size size2:CGFloat,withStartStringFont startFontString:String,withEndStringFont endFontString:String,part1Color color1:UIColor! = nil,part2Color color2:UIColor! = nil) -> NSAttributedString{
        
        /* First String Decoration Starts */
        let rangeForStartString = NSMakeRange(0, startString.characters.count)
        let startFontFamilyAttribute = UIFont(name: startFontString, size: size1)!
        
        let attributedStartString:NSMutableAttributedString = NSMutableAttributedString(string: startString)
        attributedStartString.addAttributes([NSAttributedStringKey.font:startFontFamilyAttribute], range: rangeForStartString)
        
        if color1 != nil{
            attributedStartString.addAttributes([NSAttributedStringKey.foregroundColor:color1], range: rangeForStartString)
        }
        
        
        /*Second String Decoration Starts */
        let endString = " \(endString)"
        let rangeForEndString = NSMakeRange(0, endString.characters.count)
        let endFontFamilyAttribute = UIFont(name: endFontString, size: size2)!
        
        let attributedEndString:NSMutableAttributedString = NSMutableAttributedString(string: endString)
        attributedEndString.addAttributes([NSAttributedStringKey.font:endFontFamilyAttribute], range: rangeForEndString)
        
        if color2 != nil{
            attributedEndString.addAttributes([NSAttributedStringKey.foregroundColor:color2], range: rangeForEndString)
        }
        
        
        /* Combining Both Attributed String */
        let combinedString:NSMutableAttributedString = NSMutableAttributedString()
        combinedString.append(attributedStartString)
        combinedString.append(attributedEndString)
        
        return combinedString
    }
    
    static func isValidMacAddress(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let macRegEx = "^([0-9A-Fa-f]{2}){5}([0-9A-Fa-f]{2})$"
        
        let macTest = NSPredicate(format:"SELF MATCHES %@", macRegEx)
        return macTest.evaluate(with: testStr)
    }
    
    static func getMacAddressFromTrivialString(mac : String, separator : String = ":") -> String{
        let arr = mac.components(separatedBy: separator)
        
        var tempMac = ""
        for eachComponent in arr{
            tempMac = tempMac + eachComponent
        }
        
        return tempMac
        
    }
    
    
    
}
