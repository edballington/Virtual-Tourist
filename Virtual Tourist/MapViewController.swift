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
    
    //MARK: - Constants
    let deleteViewheight: CGFloat = 60
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //Set maps initial center and zoom level from last use if available
        setMapInitialState()
        
        //Load pins if there are any
        if let pins = loadPins() {
            addPinsToMap(pins)
        }
        
        //Add label at bottom to be shown when pins can be deleted
        addDeleteView()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        saveContext()
        
    }
    
    //MARK: - Other methods
    
    override func setEditing(editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        if editing {     //Edit map
            UIView.animateWithDuration(0.4, animations: { self.view.frame.origin.y -= self.deleteViewheight }, completion: nil)
            
        } else {        //Done with editing map
            UIView.animateWithDuration(0.4, animations: { self.view.frame.origin.y += self.deleteViewheight }, completion: nil)
        }
        
    }

    
    func setMapInitialState() {
        
        let fetchRequest = NSFetchRequest(entityName: "MapState")
        let storedMapState: MapState?
        
        do {
            storedMapState = try sharedContext.executeFetchRequest(fetchRequest) as? MapState
            print("Tried assigning mapstate")
            
        } catch {
            print("Error retrieving map initial state: \(error)")
            return
        }
        
        self.mapView.setRegion((storedMapState?.region)!, animated: true)
        
    }
    
    func loadPins() -> [Pin]? {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as? [Pin]
        } catch {
            print("Error retrieving Pins from CoreData: \(error)")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.showAlertView("Cannot load saved annotations")
            })

        }
        
    }
    
    func addPinsToMap(pins: [Pin]) -> Void {
        
        for pin in pins {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mapView.addAnnotation(pin)
            })
        }
        
    }
    
    //User tapped a pin - delete it if in editing mode or segue to Photo Album view if not
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        let pin = view.annotation as! Pin
        
        if editing {
            
            self.mapView.removeAnnotation(pin)
            sharedContext.deleteObject(pin)
            saveContext()
            
        } else {
            
            let controller = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
            controller.coordinateForPhotos = pin.coordinate
            
            self.navigationController?.pushViewController(controller, animated: true)
            
        }
        
    }
    
    // MARK: - Convenience
    
    func showAlertView(message: String?) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func addDeleteView() {      //Adds label view at bottom indicating when pins can be deleted
        
        let viewWidth = view.bounds.width
        let viewBottom = view.bounds.height
        let deleteViewFrame: CGRect = CGRectMake(0, viewBottom, viewWidth, deleteViewheight)
        
        let deleteLabel = UILabel(frame: deleteViewFrame)
        deleteLabel.text = "Tap Pins to Delete"
        deleteLabel.textColor = UIColor.whiteColor()
        deleteLabel.backgroundColor = UIColor.redColor()
        deleteLabel.font = UIFont(name: "Arial", size: 17)
        deleteLabel.textAlignment = .Center
        
        self.view.addSubview(deleteLabel)
    }
    
    // MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }


}

