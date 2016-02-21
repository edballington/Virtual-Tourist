//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Ed Ballington on 2/16/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: - Load a default map with the settings from the last use
        
        //TODO: - Set default zoom level if not determined from the saved settings
        
        //TODO: - Load annotations from NSFetchedResults Controller if any
        
        
    }
    
    @IBAction func editMap(sender: AnyObject) {
        
        if self.navigationItem.rightBarButtonItem?.title == "Edit" {     //Edit map
        
        //TODO: - Slide up map and reveal red bar at bottom
        
        //TODO: = Change right bar button text to say "Done"
        
        //TODO: - Delete any annotations from the NSFetchedResults Controller that are tapped
            
        } else {        //Done with editing map
            
        //TODO: - Slide map back down and remove red bar at bottom
        
        //TODO: - Change right bar button text back to say "Edit"
            
        }
        
    }
    


}

