//
//  CMAnalyzerVC.swift
//  Nimble PNM
//
//  Created by ksolves on 09/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

class CMAnalyzerVC: BaseVC,BarCodeScannerDelegate {

    
    let illusionForBalancingLeftViewTextfields : CGFloat = 40.0
    let barcodeScanner  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BarCodeScannerVC") as! BarCodeScannerVC
    let imageScanBarcode = UIImage(named: "barcode")
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var textfieldMacAddress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUIComponents()
    }
    
    func configureUIComponents(){
        
        self.labelHeading.text = TXT_LBL_CM_ANALYZER_HEAD
        
        self.textfieldMacAddress.placeholder = "Mac Address"
        self.textfieldMacAddress.textAlignment = .center
        self.textfieldMacAddress.placeIllusion(ofPixels: illusionForBalancingLeftViewTextfields)
        //Preparing Button To Insert in the Right Of Text field
        let buttonScanBarcode = UIButton(frame: CGRect(x: 0, y: 8, width: 40, height: 24));
        buttonScanBarcode.addTarget(self, action: #selector(buttonScanBarcodePressed(_:)), for: .touchUpInside)
        buttonScanBarcode.setImage(imageScanBarcode, for: .normal)
        buttonScanBarcode.imageView?.contentMode = .scaleAspectFit
        
        self.textfieldMacAddress.rightViewMode = .always
        self.textfieldMacAddress.rightView = buttonScanBarcode
    }
    
    
    
    
    
    //MARK : Barcode Scanner Delegates
    func scanningCompleteWithDataString(dataString: String) {
        self.textfieldMacAddress.text = dataString
        
    }
    
    
    func scanningFailedDueToReason(reasonCode: Int!) {
        print("Scanning Failed Due To Reason code \(reasonCode!)")
    }
    
    @objc func buttonScanBarcodePressed(_ sender: UIButton){
        barcodeScanner.delegate = self
        self.present(barcodeScanner, animated: true, completion: nil)
    }

    @IBAction func btnActionGetModemDetails(_ sender: Any) {
        if self.validate(){
            self.performSegue(withIdentifier: "segue-to-modem-detail", sender: nil)
            
        }
        
    }
    
    func validate() -> Bool{
        var message = ""
        if textfieldMacAddress.text == ""{
            message = ALERT_MSG_CM_ANALYZER_BLANK_MAC
            
        }else if !UtilityHelper.isValidMacAddress(testStr: textfieldMacAddress.text!){
            message = ALERT_MSG_CM_ANALYZER_VALID_MAC
            
        }else{
            message = ""
        }
        
        if message == ""{
            return true
        }else{
            self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: message, withButtonTitle: ALERT_BUTTON_OK)
            return false
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue-to-modem-detail"{
            let destination = segue.destination as! CMModemDetailVC
            destination.exposedMacAddress = self.textfieldMacAddress.text!
//            destination.exposedMacAddress = "1cabc0b9992c"
        }
    }
    
    


}
