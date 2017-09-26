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
    
    var marker = AGSSimpleMarkerSymbol()
    let graphicsOverlay = AGSGraphicsOverlay()
    
    var currentMarkerPoint: AGSPoint!
    var currentSelectedlatitude : Double!
    var currrentSelectedLongitude : Double!
    
    var initialZoomLevel = 16
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.intializeMap()
        
    }
    
    func intializeMap(){
        //initialize map with `imagery with labels` basemap and an initial location
        map = AGSMap(basemapType: .imageryWithLabels, latitude: currentSelectedlatitude, longitude: currrentSelectedLongitude, levelOfDetail: initialZoomLevel)
        
        marker = AGSSimpleMarkerSymbol(style: .circle, color: UIColor.red, size: 12)
        self.mapView.graphicsOverlays.add(graphicsOverlay)
        
//        currentMarkerPoint =  AGSPoint
//        addSimpleMarkerSymbol(markerPoint: currentMarkerPoint)
        
        //assign the map to the map view
        self.mapView.map = self.map
        self.mapView.touchDelegate = self
        //self.mapView.map?.minScale = 17
        
    }
    
    func addSimpleMarkerSymbol(markerPoint: AGSPoint) {
        
        print("Marker lati and longi")
        
        let latitude = markerPoint.x
        let longitude = markerPoint.y
        
        print(latitude)
        print(longitude)
        
        //create point
        let point = markerPoint
        
        //graphic for point using simple marker symbol
        let graphic = AGSGraphic(geometry: point, symbol: marker, attributes: nil)
        
        self.graphicsOverlay.graphics.removeAllObjects()
        //add the graphic to the graphics overlay
        self.graphicsOverlay.graphics.add(graphic)
    }
    
    
    func geoView(_ geoView: AGSGeoView, didTouchDownAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint, completion: @escaping (Bool) -> Void) {
        
        print("ABCD")
        print(screenPoint)
        
//        if screenPoint == currentMarkerPoint {
            completion ({
                return true
                }())
//        }
    }
    
    //MARK: Touch delegate Map View
    func geoView(_ geoView: AGSGeoView, didTouchDragToScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        currentMarkerPoint = mapPoint
        addSimpleMarkerSymbol(markerPoint: currentMarkerPoint)
        print(mapPoint)
    }
    
   
}
