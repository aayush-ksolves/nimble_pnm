//
//  NearbyModemsVC.swift
//  Nimble PNM
//
//  Created by KSolves on 11/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit
import ArcGIS

class NearbyModemsVC: BaseVC, AGSGeoViewTouchDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    var map : AGSMap!
    
    let initialLoaderText = "Getting your location ..."
    
    var currentCoordinate = CLLocationCoordinate2D()
    fileprivate var bundleModemData: [ModemDataDS] = []
    
    var markerModem = AGSPictureMarkerSymbol(image: #imageLiteral(resourceName: "location-modem"))
    var markerPerson = AGSPictureMarkerSymbol(image: #imageLiteral(resourceName: "nearby-modems"))
    
    let graphicsOverlay = AGSGraphicsOverlay()
    var initialZoomLevel = 16
    var selectedModemindex = 0
    let screenWidth: CGFloat = SCREEN_SIZE.width
    let markerModemWidth: CGFloat = 30
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APP_DELEGATE.presentLoader(withMessage: initialLoaderText)
        self.startHandlingLocationUpdate( isCrucial: true)
        configureInitialView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getCurrentLocation()
    }
    
    func getCurrentLocation() {
        
        if (APP_DELEGATE.locationHelper.currentLocation != nil) {
            
            currentCoordinate = APP_DELEGATE.locationHelper.currentLocation!
            
            if currentCoordinate.latitude != 0  && currentCoordinate.longitude != 0{
                
                APP_DELEGATE.hideLoader()
                self.stopHandlingUpdates()
                loadNearByModems()
                
            }else {
                getCurrentLocation()
            }
            
        }else {
            getCurrentLocation()
        }
        
    }
    
    func configureInitialView() {
        
        markerPerson.width = 30
        markerPerson.height = 30
        
        markerModem.width = markerModemWidth
        markerModem.height = markerModemWidth
        
        self.mapView.graphicsOverlays.add(graphicsOverlay)
    }
    
    func showModemsOnMap() {
        
        map = AGSMap(basemapType: .streets, latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude, levelOfDetail: initialZoomLevel)
        
        graphicsOverlay.graphics.removeAllObjects()
        
        self.mapView.map = self.map
        self.mapView.touchDelegate = self
        
        let currentPoint = AGSPoint(clLocationCoordinate2D: CLLocationCoordinate2D(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude))
        addMarkerSymbol(markerPoint: currentPoint, markerImage: markerPerson)
        
        for modemData in bundleModemData {
            initializeModemLocation(latitude: modemData.latitude, longitude: modemData.longitude)
        }
        
    }
    
    func initializeModemLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        let tempPoint = AGSPoint(clLocationCoordinate2D: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        addMarkerSymbol(markerPoint: tempPoint, markerImage: markerModem)
    }
    
    func addMarkerSymbol(markerPoint: AGSPoint, markerImage: AGSPictureMarkerSymbol) {
        
        //graphic for point using simple marker symbol
        let graphic = AGSGraphic(geometry: markerPoint, symbol: markerImage, attributes: nil)
        
        //add the graphic to the graphics overlay
        self.graphicsOverlay.graphics.add(graphic)
    }
    
    @IBAction func btnActionLogout(_ sender: Any) {
        self.performLogout()
    }
    
    
    func loadNearByModems(){
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_USERNAME: username,
                              REQ_PARAM_AUTH_KEY: authKey,
                              REQ_PARAM_LATITUDE: currentCoordinate.latitude,
                              REQ_PARAM_LONGITUDE: currentCoordinate.longitude,
                              REQ_PARAM_RADIUS: 0.5
        ] as [String : Any];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_NEARBY_MODEMS, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_FETCH_NB_MODEMS, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                
                let dataDic = responseDict.value(forKey: RESPONSE_PARAM_DATA) as! NSDictionary
                let modemDataArray = dataDic.value(forKey: RESPONSE_PARAM_MODEM_DATA) as! NSArray
                
                self.bundleModemData.removeAll()
                
                for modemData in modemDataArray {
                    
                    var tempModemData = ModemDataDS()
                    
                    tempModemData.latitude =  Double(String(describing: (modemData as! NSDictionary).value(forKey: RESPONSE_PARAM_LATITUDE)!))!
                    tempModemData.longitude = Double(String(describing: (modemData as! NSDictionary).value(forKey: RESPONSE_PARAM_LONGITUDE)!))!
                    tempModemData.macAddress = String(describing: (modemData as! NSDictionary).value(forKey: RESPONSE_PARAM_MAC_ADDRESS)!)
                    tempModemData.severity = String(describing: (modemData as! NSDictionary).value(forKey: RESPONSE_PARAM_SEVERITY)!)
                    tempModemData.bandwidth = Double(String(describing: (modemData as! NSDictionary).value(forKey: RESPONSE_PARAM_BW)!))!
                    tempModemData.channels = String(describing: (modemData as! NSDictionary).value(forKey: RESPONSE_PARAM_FREQ)!)
                    tempModemData.MTC =  Double(String(describing: (modemData as! NSDictionary).value(forKey: RESPONSE_PARAM_MTC)!))!
                    tempModemData.MRLevel =  Double(String(describing: (modemData as! NSDictionary).value(forKey: RESPONSE_PARAM_MR_LVL)!))!
                    tempModemData.delay =  Double(String(describing: (modemData as! NSDictionary).value(forKey: RESPONSE_PARAM_DELAY)!))!
                    tempModemData.TDR =  Double(String(describing: (modemData as! NSDictionary).value(forKey: RESPONSE_PARAM_TDR)!))!
                    tempModemData.vTDR =  Double(String(describing: (modemData as! NSDictionary).value(forKey: RESPONSE_PARAM_FAR_TDR)!))!
                    tempModemData.address = String(describing: (modemData as! NSDictionary).value(forKey: RESPONSE_PARAM_ADDRESS)!)
                    
                    self.bundleModemData.append(tempModemData)
                }
                
                self.showModemsOnMap()
                
            }else if statusCode == 401{
                self.performLogoutAsSessionExpiredDetected()
                
            }else{
                self.displayAlert(withTitle: ALERT_TITLE_APP_NAME, withMessage: statusMessage, withButtonTitle: ALERT_BUTTON_OK)
            }
            
        },failureCompletionHandler: {
            (errorTitle,errorMessage) in
            self.displayAlert(withTitle: errorTitle, withMessage: errorMessage, withButtonTitle: ALERT_BUTTON_OK)
        })
        
    }
    
    
    func nearbyModemSelected(atRow: Int){
        
        selectedModemindex = atRow
        self.performSegue(withIdentifier: "segue-to-nearby-modem-details", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue-to-nearby-modem-details"{
            
            let destinationController = segue.destination as! NearbyModemDetails
            
            destinationController.selectedNearbyModemDetails = bundleModemData[selectedModemindex]
        }
    }
    
    
    // Map View Touch Delegate
    
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        
        let cornerCoordinates = mapView.visibleArea!.parts.array()[0]
        let topRightCoordinate = cornerCoordinates.point(at: 0).toCLLocationCoordinate2D()
        //        let bottomRightCoordinate = cornerCoordinates.point(at: 1).toCLLocationCoordinate2D()
        //        let bottomLeftCoordinate = cornerCoordinates.point(at: 2).toCLLocationCoordinate2D()
        let topLeftCoordinate = cornerCoordinates.point(at: 3).toCLLocationCoordinate2D()
        
        let factor = (topRightCoordinate.longitude - topLeftCoordinate.longitude)*Double(markerModemWidth)/(Double(screenWidth)*2)
        
        let mapPointLatitude = mapPoint.toCLLocationCoordinate2D().latitude
        let mapPointLongitude = mapPoint.toCLLocationCoordinate2D().longitude
        
        var selectedIndex = 0
        
        for tempModem in bundleModemData {
            
            let tempModemLatitude = tempModem.latitude
            let tempModemLongitude = tempModem.longitude
            
            if mapPointLongitude > tempModemLongitude - factor && mapPointLongitude < tempModemLongitude + factor && mapPointLatitude > tempModemLatitude - factor && mapPointLatitude < tempModemLatitude + factor {
                
                nearbyModemSelected(atRow: selectedIndex)
                
                break
            }
            
            selectedIndex += 1
        }
        
    }
    
    
    
    
    
}

struct ModemDataDS {
    
    var latitude: Double = 0
    var longitude: Double = 0
    var macAddress = ""
    var severity = ""
    var bandwidth: Double = 0
    var channels = ""
    var MTC: Double = 0
    var MRLevel: Double = 0
    var delay: Double = 0
    var TDR: Double = 0
    var vTDR: Double = 0
    var signature = ""
    var address = ""
}







