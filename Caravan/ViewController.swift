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
    var myRoute : MKRoute?
    
    var isTracking = true
    
    
    var annotationList: [MKPointAnnotation] = []
    
    
    @IBOutlet weak var theMap: MKMapView!
    @IBOutlet weak var trackingSwitch: UISwitch!
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
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
        
        
        // Set up the points for the directions request.
        var point1 = MKPointAnnotation()
        var point2 = MKPointAnnotation()
        
        point1.coordinate = CLLocationCoordinate2DMake(25.0305, 121.5360)
        point1.title = "Taipei"
        point1.subtitle = "Taiwan"
        theMap.addAnnotation(point1)
        
        
        point2.coordinate = CLLocationCoordinate2DMake(24.9511, 121.2358)
        point2.title = "Chungli"
        point2.subtitle = "Taiwan"
        theMap.addAnnotation(point2)
        
        theMap.centerCoordinate = point2.coordinate
        theMap.delegate = self
        
        var directionsRequest = MKDirectionsRequest()
        let markTaipei = MKPlacemark(coordinate: CLLocationCoordinate2DMake(point1.coordinate.latitude, point1.coordinate.longitude), addressDictionary: nil)
        let markChungli = MKPlacemark(coordinate: CLLocationCoordinate2DMake(point2.coordinate.latitude, point2.coordinate.longitude), addressDictionary: nil)
        
        directionsRequest.setSource(MKMapItem(placemark: markChungli))
        directionsRequest.setDestination(MKMapItem(placemark: markTaipei))
        directionsRequest.transportType = MKDirectionsTransportType.Automobile
        
        var directions = MKDirections(request: directionsRequest)
        
        directions.calculateDirectionsWithCompletionHandler{(response: MKDirectionsResponse!, error:NSError!) -> Void in
            if error == nil {
                self.myRoute = response.routes[0] as? MKRoute
                self.theMap.addOverlay(self.myRoute?.polyline)
            }
        }
        
        func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
            
            var myLineRenderer = MKPolylineRenderer(polyline: myRoute?.polyline!)
            myLineRenderer.strokeColor = UIColor.redColor()
            myLineRenderer.lineWidth = 3
            return myLineRenderer
        }
    
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
        
        
        while (!annotationList.isEmpty){
            theMap.removeAnnotation(annotationList[0])
            annotationList.removeAtIndex(0)
        }
        
        var annotation = MKPointAnnotation()
        annotation.setCoordinate(offSet)
        annotation.title = "Bob"
        theMap.addAnnotation(annotation)
        
        annotationList.append(annotation)
        
        if isTracking {
            var newRegion = MKCoordinateRegion(center: theMap.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
            theMap.setRegion(newRegion, animated: true)
        }
        
    }
}
