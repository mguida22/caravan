//
//  ViewController.swift
//  Caravan
//
//
//  Created by Ben Williams on 1/10/15.
//  Copyright (c) 2015 Caravan. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate , MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up location manager
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        // set up the map view
        mapView.delegate = self
        mapView.mapType = MKMapType.Satellite
        mapView.showsUserLocation = true
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
  
        func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        
            
            myLocations.append(locations[0] as CLLocation)
            let spanX = 0.007
            let spanY = 0.007
            
            var newRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
            mapView.setRegion(newRegion, animated: true)
            
            
            
            
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }


}

