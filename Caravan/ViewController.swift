//
//  ViewController.swift
//  Caravan
//
//
//  Created by Ben Williams on 1/10/15.
//  Copyright (c) 2015 Caravan. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let spanY = 0.015
    let spanX = 0.015
    
    var annotationList: [MKPointAnnotation] = []
    
    @IBOutlet weak var theMap: MKMapView!
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        //Setup our Map View
        theMap.delegate = self
        theMap.mapType = MKMapType.Standard
        theMap.showsUserLocation = true
        
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        myLocations.append(locations[0] as CLLocation)
        
        

        // Pass in other users coordinates here
        let latOff = theMap.userLocation.coordinate.latitude - 0.002
        let longOff = theMap.userLocation.coordinate.longitude - 0.001
        
        var offSet = CLLocationCoordinate2DMake(latOff, longOff)
        
        var annotation = MKPointAnnotation()
        annotation.setCoordinate(offSet)
        annotation.title = "Bob"
        theMap.addAnnotation(annotation)
        
        annotationList.append(annotation)
        
        var newRegion = MKCoordinateRegion(center: theMap.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        theMap.setRegion(newRegion, animated: true)
    }
}









