//
//  SettingsViewController.swift
//  Caravan
//
//  Created by Andrew Gentry on 1/10/15.
//  Copyright (c) 2015 Caravan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class SettingsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if searchBar.searchResultsButtonSelected == true {
            var userText : String? = searchBar.text
        }
        
        // Do any additional setup after loading the view.
}

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        

        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
