//
//  MappingInGeocodeVC.swift
//  Nimble PNM
//
//  Created by ksolves on 12/09/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit
import ArcGIS

class MappingInGeocodeVC: BaseVC,AGSGeoViewTouchDelegate {

    @IBOutlet weak var viewLocationHolder: UIView!
    @IBOutlet weak var labelLocationLatLng: UILabel!
    @IBOutlet weak var mapView: AGSMapView!
    var map : AGSMap!
    
    @IBOutlet weak var buttonUseLocation: UIButton!
    var GeocodeVC: GeocodeVC!
    
    var markerPerson = AGSPictureMarkerSymbol(image: #imageLiteral(resourceName: "location-modem"))
    let graphicsOverlay = AGSGraphicsOverlay()
    var lastGraphics = AGSGraphic()
    
    var currentMarkerPoint: AGSPoint!
    var currentSelectedlatitude : Double!
    var currrentSelectedLongitude : Double!
    
    let screenWidth: CGFloat = SCREEN_SIZE.width
    let screenHeight: CGFloat = SCREEN_SIZE.height
    
    var initialZoomLevel = 16
    var markerWidth: CGFloat = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.intializeMap()
    }
    

    func intializeMap(){
        //initialize map with `imagery with labels` basemap and an initial location
        
        map = AGSMap(basemapType: .streets, latitude: currentSelectedlatitude, longitude: currrentSelectedLongitude, levelOfDetail: initialZoomLevel)
        
        markerPerson.height = markerWidth
        markerPerson.width = markerWidth
        
        self.mapView.graphicsOverlays.add(graphicsOverlay)
        
        currentMarkerPoint =  AGSPoint(clLocationCoordinate2D: CLLocationCoordinate2D(latitude: currentSelectedlatitude, longitude: currrentSelectedLongitude))
        addPersonMarkerSymbol(markerPoint: currentMarkerPoint, markerImage: markerPerson)
        
        mapView.contentMode = .scaleAspectFill
        //assign the map to the map view
        self.mapView.map = self.map
        self.mapView.touchDelegate = self
        //self.mapView.map?.minScale = 17
        
        buttonUseLocation.addTarget(self, action: #selector(buttonUseLocationPressed), for: .touchUpInside)
    }
    
    func addModemMarkerSymbol(markerPoint: AGSPoint, markerImage: AGSPictureMarkerSymbol) {
        
        //graphic for point using simple marker symbol
        let graphic = AGSGraphic(geometry: markerPoint, symbol: markerImage, attributes: nil)
        
        //add the graphic to the graphics overlay
        self.graphicsOverlay.graphics.add(graphic)
    }
    
    func addPersonMarkerSymbol(markerPoint: AGSPoint, markerImage: AGSPictureMarkerSymbol) {
                
        //graphic for point using simple marker symbol
        let graphic = AGSGraphic(geometry: markerPoint, symbol: markerImage, attributes: nil)
        
        self.graphicsOverlay.graphics.remove(lastGraphics)
        //add the graphic to the graphics overlay
        self.graphicsOverlay.graphics.add(graphic)
        lastGraphics = graphic
    }
    
    @objc func buttonUseLocationPressed() {
        print("Button use location pressed")
        
        let currentLatitude = String(describing: currentMarkerPoint.toCLLocationCoordinate2D().latitude)
        let currentLongitude = String(describing: currentMarkerPoint.toCLLocationCoordinate2D().longitude)
        
        GeocodeVC.bundleLocation.latitude = Double(currentLatitude)!
        GeocodeVC.bundleLocation.longitude = Double(currentLongitude)!
        
        self.navigationController?.popViewController(animated: true)
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
        
        addPersonMarkerSymbol(markerPoint: currentMarkerPoint, markerImage: markerPerson)
        
        if screenPoint.x <= markerWidth / 2 || screenPoint.y <= markerWidth / 2 || screenPoint.x >= screenWidth - markerWidth / 2 || screenPoint.y >= screenHeight - 60 - markerWidth / 2 {
            
            mapView.setViewpointCenter(mapPoint, completion: {
                completed in
                
            })
        }
        
    }
    
   
}
