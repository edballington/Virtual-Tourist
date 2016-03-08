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
    
    //MARK: - Properties
    
    //Map position save file
    var file: String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("savedLocation").path!
    }
    
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
        
        //Add a gesture recognizer for long press to add pins
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        longPressRecognizer.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPressRecognizer)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        saveContext()
        saveMapState()
        
    }
    
    //MARK: - Other methods
    
    func saveMapState() {
        let mapDictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        NSKeyedArchiver.archiveRootObject(mapDictionary, toFile: file)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        if editing {     //Edit map
            UIView.animateWithDuration(0.4, animations: { self.view.frame.origin.y -= self.deleteViewheight }, completion: nil)
            
        } else {        //Done with editing map
            UIView.animateWithDuration(0.4, animations: { self.view.frame.origin.y += self.deleteViewheight }, completion: nil)
        }
        
    }

    
    func setMapInitialState() {
        
        if let mapDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(file) as? [String : AnyObject] {
            
            let latitude = mapDictionary["latitude"] as! CLLocationDegrees
            let longitude = mapDictionary["longitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let latitudeDelta = mapDictionary["latitudeDelta"] as! CLLocationDegrees
            let longitudeDelta = mapDictionary["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            self.mapView.setRegion(savedRegion, animated: true)
            
        } else {
            
            //First time use so saved region doesn't exist yet - set to center of continental US with a span that covers the continent
            
            let latitude : CLLocationDegrees = 33.9
            let longitude : CLLocationDegrees = 84.0
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let latitudeDelta : CLLocationDegrees = 40
            let longitudeDelta : CLLocationDegrees = 40
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            self.mapView.setRegion(savedRegion, animated: true)
            
        }
        
    }
    
    func loadPins() -> [Pin]? {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        var foundPins = [Pin]()
        
        do {
            foundPins = try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch {
            print("Error retrieving Pins from CoreData: \(error)")
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.showAlertView("Cannot load saved annotations")
            })
            
        }
        
        return foundPins
        
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
        
        let selectedPin = view.annotation as! Pin
        
        if editing {
            
            self.mapView.removeAnnotation(selectedPin)
            sharedContext.deleteObject(selectedPin)
            saveContext()
            
        } else {
            
            let controller = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
            controller.pinForPhotos = selectedPin
            
            self.navigationController?.pushViewController(controller, animated: true)
            
        }
        
    }
    
    func dropPin(sender: UIGestureRecognizer) {
        
        if sender.state != UIGestureRecognizerState.Began {
            return
        }
        
        let pinLocation = sender.locationInView(mapView)
        let pinCoordinate = mapView.convertPoint(pinLocation, toCoordinateFromView: mapView)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.mapView.addAnnotation( Pin(lat: pinCoordinate.latitude, long: pinCoordinate.longitude, context: self.sharedContext) )
        }
        
        saveContext()

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

