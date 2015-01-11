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
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let spanY = 0.015
    let spanX = 0.015
    
    struct user {
        var id:Int
        var username:String
        var longitude:Double
        var latitude:Double
        var gasPercentage:Double
        var batteryPercentage:Double
    }
    
    var myRoute : MKRoute?
    
    //create the main annotation
    var addedMainannotation = false
    
    //list of annotations by userid and the annotiation
    var annotations = Dictionary<Int, MKPointAnnotation>()
    
    //the current apiEndpoint that we store the interaction on
    var apiEndpoint = "http://162.243.225.16:8080"
    
    //temp user id, need to add code to change this for new users
    var tempUserId = 1
    var tempGroupId = 1
    
    //simple bool for testing
    var isTracking = true
    
    @IBOutlet weak var myMap: MKMapView!
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
        
        var origin = MKPointAnnotation()
        var destination = MKPointAnnotation()
        
        //Setup origin and destination for navigation
        //let userLat = Mainannotation.coordinate.latitude
        //let userLong = Mainannotation.coordinate.longitude
        let userLat = 37.331797
        let userLong = -122.029604
        origin.coordinate = CLLocationCoordinate2DMake(userLat, userLong)
        origin.title = "Current Location"
        myMap.addAnnotation(origin)
        
        destination.coordinate = CLLocationCoordinate2DMake(37.788031, -122.407480)
        destination.title = "Union Square"
        destination.subtitle = "San Francisco"
        myMap.addAnnotation(destination)
        
        //Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        //Setup our Map View
        myMap.delegate = self
        myMap.mapType = MKMapType.Standard
        myMap.showsUserLocation = true
        
        var directionsRequest = MKDirectionsRequest()
        let markOrigin = MKPlacemark(coordinate: CLLocationCoordinate2DMake(origin.coordinate.latitude, origin.coordinate.longitude), addressDictionary: nil)
        //let markOrigin = MKPlacemark(coordinate: CLLocationCoordinate2DMake(userLat, userLong), addressDictionary: nil)
        let markDestination = MKPlacemark(coordinate: CLLocationCoordinate2DMake(destination.coordinate.latitude, destination.coordinate.longitude), addressDictionary: nil)
        
        directionsRequest.setSource(MKMapItem(placemark: markOrigin))
        directionsRequest.setDestination(MKMapItem(placemark: markDestination))
        directionsRequest.transportType = MKDirectionsTransportType.Automobile
        var directions = MKDirections(request: directionsRequest)
        directions.calculateDirectionsWithCompletionHandler { (response:MKDirectionsResponse!, error: NSError!) -> Void in
            if error == nil {
                self.myRoute = response.routes[0] as? MKRoute
                self.myMap.addOverlay(self.myRoute?.polyline)
            }
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        var myLineRenderer = MKPolylineRenderer(polyline: myRoute?.polyline!)
        myLineRenderer.strokeColor = UIColor.blueColor()
        myLineRenderer.lineWidth = 3
        return myLineRenderer
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        
            let identifier = "stopAnnotation"
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            if pinView == nil {
                //println("Pinview was nil")
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                pinView!.canShowCallout = true
                pinView.image = UIImage(named: "dot-orange")
            }
            return pinView

    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        
        //use the setusercords apiPoint
        Alamofire.request(.POST, apiEndpoint + "/setusercords",
            
            //set the api parameters
            parameters: [
                "longitude" : myMap.userLocation.coordinate.longitude,
                "latitude" : myMap.userLocation.coordinate.latitude,
                "userid" : tempUserId
            ])
            
            //get the response as a string (simple true or false)
            .responseString { (_, _, data, _) in
                if(data! == "false") {
                    println("failed to update user data")
                }
        }

        
        //get the other user's locations from the api
        Alamofire.request(.POST, apiEndpoint + "/getgroupinfo",
            
            //set the api parameters
            parameters: [
                "groupid" : tempGroupId,
                "userid" : tempUserId
            ])

        //get the response as json
        .responseJSON { (_, _, data, _) in
            
            //if the request was bad
            if(data![0] === 0) {
                println("failed to get other users")
            } else {
                
                //for each user
                for(var i = 0; i < data!.count-1; i++) {
                    
                   /* if(self.annotationList.count > 1){
                        self.myMap.removeAnnotation(self.annotationList[1])
                        self.annotationList.removeAtIndex(1)
                    }*/
                    
                    //set the data as a dictionary
                    let userDict = data![i] as [NSObject: AnyObject]!
                    
                    let userid:Int = userDict["userid"] as NSInteger
                    let username:String = userDict["username"] as NSString
                    let longitude: Double? = userDict["longitude"] as? Double
                    let latitude:Double? = userDict["latitude"] as? Double
                    let gasPercentage:Double? = userDict["gasPercentage"] as? Double
                    let batteryPercentage:Double? = userDict["batteryPercentage"] as? Double
                    
                    var newUser = user(id: userid, username: username, longitude: longitude!, latitude: latitude!, gasPercentage: gasPercentage!, batteryPercentage: batteryPercentage!)
                    
                    var marker = CLLocationCoordinate2DMake(newUser.latitude, newUser.longitude)

                    if(self.annotations[newUser.id] === nil) {
                        
                        self.annotations[newUser.id] = MKPointAnnotation()
                        self.myMap.addAnnotation(self.annotations[newUser.id])
                        self.annotations[newUser.id]!.title = newUser.username
                        
                    }
                    
                    //update the lat/long of the mainAnnotation (now with fancy animation)
                    UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut | .AllowUserInteraction,
                        animations: {
                            self.annotations[newUser.id]!.coordinate.latitude = latitude!
                            self.annotations[newUser.id]!.coordinate.longitude = longitude!
                        }, completion: { finished in})
                    
                }
            }
        }
        
        if isTracking {
            var newRegion = MKCoordinateRegion(center: myMap.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
            myMap.setRegion(newRegion, animated: true)
        }
        
    }
}
