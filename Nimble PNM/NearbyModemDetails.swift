//
//  NearbyModemDetails.swift
//  Nimble PNM
//
//  Created by KSolves on 12/10/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit
import ArcGIS

class NearbyModemDetails : BaseVC, AGSGeoViewTouchDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var labelModemDetails: UILabel!
    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var viewModemLocation: UIView!
    
    @IBOutlet weak var buttonSave: UIButton!
    
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var tableViewModemDetails: UITableView!
    @IBOutlet weak var buttonUpdate: UIButton!
    @IBOutlet weak var buttonMoreDetails: UIButton!
    
    var markerModem = AGSPictureMarkerSymbol(image: #imageLiteral(resourceName: "location-modem"))
    
    var map : AGSMap!
    var initialZoomLevel = 16
    var selectedNearbyModemDetails = ModemDataDS()
    let screenWidth: CGFloat = SCREEN_SIZE.width
    let screenHeight: CGFloat = SCREEN_SIZE.height
    var markerWidth: CGFloat = 30
    var lastGraphics = AGSGraphic()
    var currentMarkerPoint: AGSPoint!
    let graphicsOverlay = AGSGraphicsOverlay()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    func configureView() {
        
        buttonUpdate.addTarget(self, action: #selector(buttonUpdatePressed), for: .touchUpInside)
        buttonMoreDetails.addTarget(self, action: #selector(buttonMoreDetailsPressed), for: .touchUpInside)
        buttonCancel.addTarget(self, action: #selector(buttonCancelPressed), for: .touchUpInside)
        buttonSave.addTarget(self, action: #selector(buttonSavePressed), for: .touchUpInside)
        
        tableViewModemDetails.estimatedRowHeight = 270
        tableViewModemDetails.rowHeight = UITableViewAutomaticDimension
        
        tableViewModemDetails.backgroundColor = COLOR_WHITE_AS_GREY
        tableViewModemDetails.addBorder(withColor: COLOR_WHITE_AS_GREY, withWidth: 1)
        
        tableViewModemDetails.register(UINib(nibName: "NearbyModemDetailsCell", bundle: nil), forCellReuseIdentifier: "NearbyModemDetailsCell")
        
        tableViewModemDetails.reloadData()
        
        configureMapView()
        shouldShowModemLocationView(shouldShow: false)
    }
    
    func configureMapView() {
        
        map = AGSMap(basemapType: .streets, latitude: selectedNearbyModemDetails.latitude, longitude: selectedNearbyModemDetails.longitude, levelOfDetail: initialZoomLevel)
        
        markerModem.width = markerWidth
        markerModem.height = markerWidth
        
        currentMarkerPoint =  AGSPoint(clLocationCoordinate2D: CLLocationCoordinate2D(latitude: selectedNearbyModemDetails.latitude, longitude: selectedNearbyModemDetails.longitude))
        addPersonMarkerSymbol(markerPoint: currentMarkerPoint)
        
        self.mapView.graphicsOverlays.add(graphicsOverlay)
        
        self.mapView.map = self.map
        self.mapView.touchDelegate = self
    }
    
    func buttonUpdatePressed() {
        shouldShowModemLocationView(shouldShow: true)
    }
    
    func buttonMoreDetailsPressed() {
        
    }
    
    func buttonSavePressed() {
        
        let alert = UtilityHelper.composeAlertWith(title: ALERT_TITLE_CONFIRM, message: ALERT_MSG_UPDATE_MODEM_LOCATION, buttonTitle1: ALERT_BUTTON_NO, buttonTitle2: ALERT_BUTTON_YES, buttonStyle1: .destructive, buttonStyle2: .default, completionHandler1: {
            action in
            //Do Nothing
        }, completionHandler2: {
            action in
            
            self.updateCoordinatesOfModemOnServer()
        })
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func updateCoordinatesOfModemOnServer() {
        
        let username = USER_DEFAULTS.value(forKey: DEFAULTS_EMAIL_ID) as! String;
        let authKey = USER_DEFAULTS.value(forKey: DEFAULTS_AUTH_KEY) as! String;
        
        let dictParameters = [REQ_PARAM_USERNAME: username,
                              REQ_PARAM_AUTH_KEY: authKey,
                              REQ_PARAM_LATITUDE: currentMarkerPoint.toCLLocationCoordinate2D().latitude,
                              REQ_PARAM_LONGITUDE: currentMarkerPoint.toCLLocationCoordinate2D().longitude,
                              REQ_PARAM_MAC_ADDRESS: selectedNearbyModemDetails.macAddress,
                              ] as [String : Any];
        
        self.networkManager.makePostRequestWithAuthorizationHeaderTo(url: SERVICE_URL_GEOCODE_SAVE, withParameters: dictParameters, withLoaderMessage: LOADER_MSG_UPDATE_MODEM_LOCATION, sucessCompletionHadler: {
            responseDict in
            
            let statusCode = responseDict.value(forKey: RESPONSE_PARAM_STATUS_CODE) as! Int
            let statusMessage = String(describing:responseDict.value(forKey: RESPONSE_PARAM_STATUS_MSG)!)
            
            if statusCode == 200{
                
                self.navigationController?.popViewController(animated: false)
                
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
    
    func buttonCancelPressed(){
        shouldShowModemLocationView(shouldShow: false)
    }
    
    func shouldShowModemLocationView(shouldShow: Bool) {
        
        labelModemDetails.isHidden = shouldShow
        tableViewModemDetails.isHidden = shouldShow
        buttonUpdate.isHidden = shouldShow
        buttonMoreDetails.isHidden = shouldShow
        
        viewModemLocation.isHidden = !shouldShow
    }
    
    // table view data source and delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyModemDetailsCell") as! NearbyModemDetailsCell
        
        cell.labelMacAddress.text = selectedNearbyModemDetails.macAddress
        cell.labelBW.text = "\(selectedNearbyModemDetails.bandwidth)"
        cell.labelChannels.text = selectedNearbyModemDetails.channels
        cell.labelMTC.text = "\(selectedNearbyModemDetails.MTC)"
        cell.labelMRLevel.text = "\(selectedNearbyModemDetails.MRLevel)"
        cell.labelDelay.text = "\(selectedNearbyModemDetails.delay)"
        cell.labelTDR.text = "\(selectedNearbyModemDetails.TDR)"
        cell.labelVTDR.text = "\(selectedNearbyModemDetails.vTDR)"
        cell.labelSignature.text = selectedNearbyModemDetails.signature
        cell.labelAddress.text = selectedNearbyModemDetails.address
        cell.labelLatitude.text = "\(selectedNearbyModemDetails.latitude)"
        cell.labelLongitude.text = "\(selectedNearbyModemDetails.longitude)"
        cell.imageViewSeverity.image = #imageLiteral(resourceName: "settings")
        
        return cell
    }
    
    
    func addPersonMarkerSymbol(markerPoint: AGSPoint) {
        
        //graphic for point using simple marker symbol
        let graphic = AGSGraphic(geometry: markerPoint, symbol: markerModem, attributes: nil)
        
        self.graphicsOverlay.graphics.remove(lastGraphics)
        //add the graphic to the graphics overlay
        self.graphicsOverlay.graphics.add(graphic)
        lastGraphics = graphic
    }
    
    
    func geoView(_ geoView: AGSGeoView, didTouchDownAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint, completion: @escaping (Bool) -> Void) {
        
        let cornerCoordinates = mapView.visibleArea!.parts.array()[0]
        let topRightCoordinate = cornerCoordinates.point(at: 0).toCLLocationCoordinate2D()
        //        let bottomRightCoordinate = cornerCoordinates.point(at: 1).toCLLocationCoordinate2D()
        //        let bottomLeftCoordinate = cornerCoordinates.point(at: 2).toCLLocationCoordinate2D()
        let topLeftCoordinate = cornerCoordinates.point(at: 3).toCLLocationCoordinate2D()
        
        let factor = (topRightCoordinate.longitude - topLeftCoordinate.longitude)*Double(markerWidth)/(Double(screenWidth)*2)
        
        let mapPointLatitude = mapPoint.toCLLocationCoordinate2D().latitude
        let mapPointLongitude = mapPoint.toCLLocationCoordinate2D().longitude
        
        if mapPointLongitude > currentMarkerPoint.x - factor && mapPointLongitude < currentMarkerPoint.x + factor && mapPointLatitude > currentMarkerPoint.y - factor && mapPointLatitude < currentMarkerPoint.y + factor {
            
            completion ({
                return true
                }())
            
        }else {
            
            completion ({
                return false
                }())
            
        }
    }
    
    
    //MARK: Touch delegate Map View
    func geoView(_ geoView: AGSGeoView, didTouchDragToScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        
        currentMarkerPoint =  AGSPoint(clLocationCoordinate2D: CLLocationCoordinate2D(latitude: mapPoint.toCLLocationCoordinate2D().latitude, longitude: mapPoint.toCLLocationCoordinate2D().longitude))
        
        addPersonMarkerSymbol(markerPoint: currentMarkerPoint)
        
    }
    
    
    @IBAction func btnActionLogout(_ sender: Any) {
        self.performLogout()
    }


}

struct SelectedNearbyModemDetailsDS {
    
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





