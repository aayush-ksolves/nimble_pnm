//
//  AppDelegate.swift
//  Nimble PNM
//
//  Created by ksolves on 12/07/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var supportedOrientation:UIInterfaceOrientationMask = UIInterfaceOrientationMask.all
    var networkManager: AlamofireHelper = AlamofireHelper()
    var windowForLoader : UIWindow = UIWindow()
    //var windowForAlert : UIWindow = UIWindow()
    
    var locationHelper = LocationHelper()
    
    //Instantiate Loader View Controller Dor the application
    var loaderVC : LoaderVC = LoaderVC()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.instantiateLoaderWindowOneTime()
        self.locationHelper.configureLocationManager()
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
       
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
       
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
      
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        print("SupportbCalled")
        if supportedOrientation == .portrait{
            return supportedOrientation
        }else{
            if UIDevice.current.userInterfaceIdiom == .pad{
                return .all
            }else{
                return .allButUpsideDown
            }
            
        }
        
    }
    
    
    
    
    //Loader VC Configurations
    func instantiateLoaderWindowOneTime(){
        self.windowForLoader.frame = (self.window?.frame)!
        loaderVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoaderVC") as! LoaderVC;
        self.windowForLoader.backgroundColor = UIColor.clear
        self.windowForLoader.rootViewController = loaderVC;
        
    }
    
    func presentLoader(withMessage message: String){
        self.windowForLoader.makeKeyAndVisible()
        self.loaderVC.setPresentationMode(shouldPresent: true, withMessage: message)
    }
    
    
    func hideLoader(){
        self.loaderVC.setPresentationMode(shouldPresent: false)
        self.window?.makeKeyAndVisible()
    }
    
    
    //MARK: HelperFunctions
    func changeWindowLevelTo(level: UIWindowLevel){
        self.window?.windowLevel = level
    }

}

