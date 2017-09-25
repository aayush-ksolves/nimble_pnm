//
//  BarCodeScanner.swift
//  Nimble PNM
//
//  Created by ksolves on 13/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

protocol BarCodeScannerDelegate: class {
    func scanningCompleteWithDataString(dataString : String)
    func scanningFailedDueToReason(reasonCode:Int!)
}

class BarCodeScannerVC: UIViewController {

    weak var delegate : BarCodeScannerDelegate!
    var scanner : MTBBarcodeScanner!
    
    @IBOutlet weak var viewScanningRegion: UIView!
    @IBOutlet weak var viewFocusRegionToScan: UIView!
    
    
    @IBOutlet weak var btnOutletToggleFlash: UIButton!
    @IBOutlet weak var btnOutletToggleCamera: UIButton!
    @IBOutlet weak var btnOutletCancel: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        APP_DELEGATE.supportedOrientation = .portrait
        
        scanner = MTBBarcodeScanner(previewView: self.viewScanningRegion);
        configureUIComponents()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APP_DELEGATE.changeWindowLevelTo(level: UIWindowLevelStatusBar)
        APP_DELEGATE.supportedOrientation = .portrait

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startScanning()
        //Defining Zone To Read From
        self.constructLayerAndAdd()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        APP_DELEGATE.supportedOrientation = .all
        APP_DELEGATE.changeWindowLevelTo(level: UIWindowLevelNormal)
        
    }
    
    
    func configureUIComponents(){
        
        self.btnOutletToggleFlash.imageView?.contentMode = .scaleAspectFit
        self.btnOutletToggleCamera.imageView?.contentMode = .scaleAspectFit
        
        
        //Deciding Torch
        if scanner.hasTorch(){
            btnOutletToggleFlash.isEnabled = true
        }else{
            btnOutletToggleFlash.isEnabled = false
        }
        
        
        //Deciding Camera FLip
        if scanner.hasOppositeCamera(){
            self.btnOutletToggleFlash.isEnabled = true
        }else{
            self.btnOutletToggleFlash.isEnabled = false
        }
    }
    
    func changeFlashAvailabilityTo(isAvailable:Bool){
        if isAvailable{
            self.btnOutletToggleFlash.isEnabled = true;
        }else{
            self.btnOutletToggleFlash.isEnabled = false;
        }
    }
    
    
    
    func constructLayerAndAdd(){
        let layerLeftTop = CALayer()
        let layerLeftBottom = CALayer()
        let layerRightTop = CALayer()
        let layerRightBottom = CALayer()
        let layerTopLeft = CALayer()
        let layerTopRight = CALayer()
        let layerBottomLeft = CALayer()
        let layerBottomRight = CALayer()
        
        layerLeftTop.frame = CGRect(x: 0, y: 0, width: 1, height: 20)
        layerLeftTop.backgroundColor = COLOR_SCAN_REGION_BORDER.cgColor;
        
        layerLeftBottom.frame = CGRect(x: 0, y: self.viewFocusRegionToScan.frame.size.height - 20, width: 1, height: 20)
        layerLeftBottom.backgroundColor = COLOR_SCAN_REGION_BORDER.cgColor;
        
        layerRightTop.frame = CGRect(x: self.viewFocusRegionToScan.frame.size.width - 1, y: 0, width: 1, height: 20)
        layerRightTop.backgroundColor = COLOR_SCAN_REGION_BORDER.cgColor;
        
        
        layerRightBottom.frame = CGRect(x: self.viewFocusRegionToScan.frame.size.width - 1, y: self.viewFocusRegionToScan.frame.size.height-20, width: 1, height: 20)
        layerRightBottom.backgroundColor = COLOR_SCAN_REGION_BORDER.cgColor;
        
        
        layerTopLeft.frame = CGRect(x: 0, y: 0, width: 20, height: 1)
        layerTopLeft.backgroundColor = COLOR_SCAN_REGION_BORDER.cgColor;
        
        
        layerTopRight.frame = CGRect(x: self.viewFocusRegionToScan.frame.size.width - 20, y: 0, width: 20, height: 1)
        layerTopRight.backgroundColor = COLOR_SCAN_REGION_BORDER.cgColor;
        
        
        layerBottomLeft.frame = CGRect(x: 0, y: self.viewFocusRegionToScan.frame.size.height-1, width: 20, height: 1)
        layerBottomLeft.backgroundColor = COLOR_SCAN_REGION_BORDER.cgColor;
        
        
        layerBottomRight.frame = CGRect(x: self.viewFocusRegionToScan.frame.size.width-20, y: self.viewFocusRegionToScan.frame.size.height-1, width: 20, height: 1)
        layerBottomRight.backgroundColor = COLOR_SCAN_REGION_BORDER.cgColor;
        
        
        self.viewFocusRegionToScan.layer.addSublayer(layerLeftTop)
        self.viewFocusRegionToScan.layer.addSublayer(layerLeftBottom)
        self.viewFocusRegionToScan.layer.addSublayer(layerRightTop)
        self.viewFocusRegionToScan.layer.addSublayer(layerRightBottom)
        self.viewFocusRegionToScan.layer.addSublayer(layerTopLeft)
        self.viewFocusRegionToScan.layer.addSublayer(layerTopRight)
        self.viewFocusRegionToScan.layer.addSublayer(layerBottomLeft)
        self.viewFocusRegionToScan.layer.addSublayer(layerBottomRight)
        
        
        
        
        
    }
    
    
    

    
    //MARK: Utility Functions
    func startScanning(){
        MTBBarcodeScanner.requestCameraPermission(success: { success in
            if success {
                do {
                    
                    if self.scanner.camera == .back{
                        self.changeFlashAvailabilityTo(isAvailable: true)
                    }else{
                        self.changeFlashAvailabilityTo(isAvailable: false)
                    }
                    
                    try self.scanner?.startScanning(resultBlock: { codes in
                        if let codes = codes {
                            for code in codes {
                                
                                
                                self.scanner?.stopScanning()
                                let stringValue = code.stringValue!

                                
                                
                                self.delegate.scanningCompleteWithDataString(dataString: stringValue)
                                self.dismiss(animated: true, completion: nil)
                                
                                
                                
                            }
                        }
                    })
                } catch {
                    
                    //Present Alert
                    let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_APP_NAME, message: ALERT_MSG_SCAN_UNABLE_START, buttonTitle: ALERT_BUTTON_OK, completionHandler: {
                        action in
                        
                        
                        self.performCancelProdure(reasonCode: 0)
                    })
                    self.present(alert, animated: true, completion: nil)
                    
                }
            } else {
                
                
                //Present Alert
                let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_APP_NAME, message: ALERT_MSG_SCAN_CAMERA_PERM_NA, buttonTitle: ALERT_BUTTON_OK, completionHandler: {
                    action in
                    self.performCancelProdure(reasonCode: 1)
                })
                self.present(alert, animated: true, completion: nil)
                
            }
        })
    }
    
    func performCancelProdure(reasonCode:Int!){
        self.delegate.scanningFailedDueToReason(reasonCode: reasonCode)
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Button Actions
    
    @IBAction func btnActionToggleCamera(_ sender: Any) {
        if scanner.camera == .back{
            changeFlashAvailabilityTo(isAvailable: false)
            if scanner.torchMode == .on{
                self.btnOutletToggleFlash.sendActions(for: .touchUpInside)
            }
            scanner.flipCamera()
        }else{
            changeFlashAvailabilityTo(isAvailable: true)
            scanner.flipCamera()
        }
        
    }
    
    @IBAction func btnActionToggleFlash(_ sender: Any) {
        print(scanner.camera.rawValue)
        do {
            if scanner.torchMode == .on{
                btnOutletToggleFlash.setImage(IMAGE_TORCH_OFF, for: .normal)
                try scanner.setTorchMode(MTBTorchMode.off, error: ())
                
                
            }else{
                try scanner.setTorchMode(MTBTorchMode.on, error: ())
                btnOutletToggleFlash.setImage(IMAGE_TORCH_ON, for: .normal)
                
            }
            
        }catch{
            print(error)
        }
        
        
    }
    
    @IBAction func btnActionCancelScanning(_ sender: Any) {
        self.performCancelProdure(reasonCode: 2)
    }
    
    

}
