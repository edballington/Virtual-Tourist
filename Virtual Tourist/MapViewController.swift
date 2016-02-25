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

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: - Load a default map with the settings from the last use
        
        setMapInitialState()
        
        //TODO: - Set default zoom level and center if not determined from the saved settings
        
        //TODO: - Load annotations from Core Data if any
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        saveContext()
        
    }
    
    
    @IBAction func editMap(sender: AnyObject) {
        
        if self.navigationItem.rightBarButtonItem?.title == "Edit" {     //Edit map
        
        //TODO: - Slide up map and reveal red bar at bottom
        
        //TODO: = Change right bar button text to say "Done"
        
        //TODO: - Delete any annotations from Core Data that are tapped
            
        } else {        //Done with editing map
            
        //TODO: - Slide map back down and remove red bar at bottom
        
        //TODO: - Change right bar button text back to say "Edit"
            
        }
        
    }
    
    func setMapInitialState() {
        
        let fetchRequest = NSFetchRequest(entityName: "MapState")
        let storedMapState: MapState?
        
        do {
            storedMapState = try sharedContext.executeFetchRequest(fetchRequest) as? MapState
            
        } catch {
            print("Error retrieving map initial state: \(error)")
            return
        }
        
        self.mapView.setRegion((storedMapState?.region)!, animated: true)
        
        
        
    }
    
    func loadPins() -> [Pin] {
        
        
    }
    
    func addPinsToMap(pins: [Pin]) -> Void {
        
    }
    
    // MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }


}

