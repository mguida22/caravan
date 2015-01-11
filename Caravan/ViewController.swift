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
    
    //create the main annotation
    var Mainannotation = MKPointAnnotation()
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
        
        //update the lat/long of the mainAnnotation (now with fancy animation)
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut | .AllowUserInteraction,
            animations: {
                self.Mainannotation.coordinate.latitude = self.theMap.userLocation.coordinate.latitude
                self.Mainannotation.coordinate.longitude = self.theMap.userLocation.coordinate.longitude
            }, completion: { finished in})
        
        //if the Annotation is not of the map, add it
        if(!addedMainannotation) {
            addedMainannotation = true
            theMap.addAnnotation(Mainannotation)
            Mainannotation.title = "me"
        }
        
        //use the setusercords apiPoint
        Alamofire.request(.POST, apiEndpoint + "/setusercords",
            
            //set the api parameters
            parameters: [
                "longitude" : theMap.userLocation.coordinate.longitude,
                "latitude" : theMap.userLocation.coordinate.latitude,
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
                        self.theMap.removeAnnotation(self.annotationList[1])
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
                    
                    var annotations = MKPointAnnotation()
                    
                    annotations.setCoordinate(marker)
                    
                    annotations.title = newUser.username
                    
                    println(newUser.username)
                    println(newUser.id)
                    
                    self.theMap.addAnnotation(annotations)
                    /*
                    if(self.annotations[newUser.id] == nil) {
                        
                        self.annotations[newUser.id] = MKPointAnnotation()
                        self.theMap.addAnnotation(self.annotations[newUser.id])
                        self.annotations[newUser.id].title = newUser.username
                        
                    }
                    
                    //update the lat/long of the mainAnnotation (now with fancy animation)
                    UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut | .AllowUserInteraction,
                        animations: {
                            annotations[newUser.id].coordinate.latitude = self.theMap.userLocation.coordinate.latitude
                            annotations[newUser.id].coordinate.longitude = self.theMap.userLocation.coordinate.longitude
                        }, completion: { finished in})
                    */
                }
            }
        }
        
        if isTracking {
            var newRegion = MKCoordinateRegion(center: theMap.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
            theMap.setRegion(newRegion, animated: true)
        }
        
    }
}
