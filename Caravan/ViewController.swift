//
//  ViewController.swift
//  Caravan
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
    
    var isTracking = true
    
    var annotationList: [MKPointAnnotation] = []
    
    
    @IBOutlet weak var theMap: MKMapView!
    @IBOutlet weak var trackingSwitch: UISwitch!
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    
    @IBAction func doTracking(sender: AnyObject) {
        if trackingSwitch.on {
            //follow user
            isTracking = true
        } else {
            //stop following
            isTracking = false
        }
    }
    
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
        
        while (!annotationList.isEmpty){
            theMap.removeAnnotation(annotationList[0])
            annotationList.removeAtIndex(0)
        }
        
        var annotation = MKPointAnnotation()
        annotation.setCoordinate(theMap.userLocation.coordinate)
        annotation.title = "Bob"
        theMap.addAnnotation(annotation)
        
        annotationList.append(annotation)
        
        if isTracking {
            var newRegion = MKCoordinateRegion(center: theMap.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
            theMap.setRegion(newRegion, animated: true)
        }
        
    }
}