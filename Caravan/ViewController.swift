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
    
    let spanY = 0.01
    let spanX = 0.01
    
    var searchInput = "food"
    
    //var userPreviousCoordinate : CLLocationCoordinate2D?
    
    struct user {
        var id:Int
        var username:String
        var longitude:Double
        var latitude:Double
        var gasPercentage:Double
        var batteryPercentage:Double
    }
    
    var myRoute : MKRoute?
    
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var annotationPOI: [MKAnnotation] = [MKAnnotation]()
    
    //create the main annotation
    var addedMainannotation = false
    
    //list of annotations by userid and the annotiation
    var annotations = Dictionary<Int, MKPointAnnotation>()
    
    //the current apiEndpoint that we store the interaction on
    var apiEndpoint = "http://162.243.225.16:8080"
    
    //temp user id, need to add code to change this for new users

    var tempUserId = 2
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
            performSearch()
        }
    }
    
    func performSearch() {
        
        //remove old POI before getting new ones
        while !annotationPOI.isEmpty {
            myMap.removeAnnotation(annotationPOI.removeLast())
        }
        
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchInput
        request.region = myMap.region

        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler({(response:
            MKLocalSearchResponse!,
            error: NSError!) in
            
            if error != nil {
                println("Error occured in search: \(error.localizedDescription)")
            } else if response.mapItems.count == 0 {
                println("No matches found")
            } else {
                println("Matches found")
                
                for item in response.mapItems as [MKMapItem] {
                    println("Name = \(item.name)")
                    println("Phone = \(item.phoneNumber)")
                    
                    self.matchingItems.append(item as MKMapItem)
                    println("Matching items = \(self.matchingItems.count)")
                    
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    self.myMap.addAnnotation(annotation)

                    //add to annotationPOI list to keep track and later delete
                    self.annotationPOI.append(annotation)
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var origin = MKPointAnnotation()
        var destination = MKPointAnnotation()
        
        //Setup origin and destination for navigation
        var userLat = myMap.userLocation.coordinate.latitude
        var userLong = myMap.userLocation.coordinate.longitude
        
        //userPreviousCoordinate = myMap.userLocation.coordinate
        
        //let userLat = 37.331797
        //let userLong = -122.029604
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
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        var myLineRenderer = MKPolylineRenderer(polyline: myRoute?.polyline!)
        myLineRenderer.strokeColor = UIColor.greenColor()
        myLineRenderer.lineWidth = 3
        return myLineRenderer
    }
    /*
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if (annotation is MKUserLocation) {
            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            //return nil so map draws default view for it (eg. blue dot)...
            return nil
        }
        
        let colorDotArray = [ "dot-orange", "dot-green", "dot-green"]
    
    
        let identifier = "stopAnnotation"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        if pinView == nil {
            println("Pinview was nil")
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView!.canShowCallout = true
            pinView.image = UIImage(named: colorDotArray[tempUserId-1])
        }
        return pinView
        
    }
    */

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
        //end of api to set user cords

        
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
            if(data == nil || data![0] === 0) {
                println("failed to get other users")
            } else {
                
                //for each user
                for(var i = 0; i < data!.count-1; i++) {
                    
                    //set the data as a dictionary
                    let userDict = data![i] as [NSObject: AnyObject]!
                    
                    let userid:Int = userDict["userid"] as NSInteger
                    let username:String = userDict["username"] as NSString
                    let longitude: Double? = userDict["longitude"] as? Double
                    let latitude:Double? = userDict["latitude"] as? Double
                    let gasPercentage:Double? = userDict["gasPercentage"] as? Double
                    let batteryPercentage:Double? = userDict["batteryPercentage"] as? Double
                    
                    var newUser = user(id: userid, username: username, longitude: longitude!, latitude: latitude!, gasPercentage: gasPercentage!, batteryPercentage: batteryPercentage!)
                    

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
        
       
        
        //Follow user or not follow user based off of their input
        if isTracking {
            
            /*
            //TODO-MG: fix following of the users direction to orient map properly

            userPreviousCoordinate = CLLocationCoordinate2DMake(37.335329, -122.032061)
            
            println("Longitude: ", myMap.userLocation.coordinate.longitude)
            println("Latitude: ", myMap.userLocation.coordinate.latitude)
            
            var newRegion = MKCoordinateRegion(center: myMap.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
            self.myMap.setRegion(newRegion, animated: true)
            
            var newCamera = MKMapCamera(lookingAtCenterCoordinate: myMap.userLocation.coordinate, fromEyeCoordinate: userPreviousCoordinate!, eyeAltitude: 50.0)
            self.myMap.setCamera(newCamera, animated: true)
            
            userPreviousCoordinate = myMap.userLocation.coordinate
            */
            
            self.myMap.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true);
        } else {
            self.myMap.setUserTrackingMode(MKUserTrackingMode.None, animated: true)
        }
        
        ////start navigation
        var destination = MKPointAnnotation()
        
        //Setup origin and destination for navigation
        var userLat = 37.788031
        var userLong = -122.407480
        
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
        //en of api to set user cords

        
        destination.title = "Union Square"
        destination.subtitle = "San Francisco"
        destination.coordinate.latitude = userLat
        destination.coordinate.longitude = userLong
        myMap.addAnnotation(destination)
        CLLocationCoordinate2DMake(userLat, userLong)
        
        var directionsRequest = MKDirectionsRequest()
        var markOrigin = MKPlacemark(coordinate: CLLocationCoordinate2DMake(myMap.userLocation.coordinate.latitude, myMap.userLocation.coordinate.longitude), addressDictionary: nil)
        
        var markDestination = MKPlacemark(coordinate: CLLocationCoordinate2DMake(userLat, userLong), addressDictionary: nil)
        
        directionsRequest.setSource(MKMapItem(placemark: markOrigin))
        directionsRequest.setDestination(MKMapItem(placemark: markDestination))
        directionsRequest.transportType = MKDirectionsTransportType.Automobile
        
        var directions = MKDirections(request: directionsRequest)
        
        
       directions.calculateDirectionsWithCompletionHandler { (response:MKDirectionsResponse!, error: NSError!) -> Void in
            if error == nil {
                self.myMap.removeOverlay(self.myRoute?.polyline)
                self.myRoute = response.routes[0] as? MKRoute
                self.myMap.addOverlay(self.myRoute?.polyline)
            }
        }
        
        
        ////end navigation
        
    }
}
