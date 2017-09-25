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
        
        
        
        //assign the map to the map view
        self.mapView.map = self.map
        self.mapView.touchDelegate = self
        //self.mapView.map?.minScale = 17
        
    }
    
    
    //MARK: Touch delegate Map View
    func geoView(_ geoView: AGSGeoView, didTouchDragToScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        print(screenPoint)
    }
    
    
    
    
    
    
    
    
    
    
    
    


}
