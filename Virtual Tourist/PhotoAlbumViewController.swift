//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Ed Ballington on 2/16/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate  {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem!.title = "OK"
        
        // Fetch the photos data
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Unresolved error \(error)")
            abort()
        }
        
        fetchedResultsController.delegate = self
        
    }

    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // This invocation prepares the table to recieve a number of changes. It will store them up
        // until it receives endUpdates(), and then perform them all at once.
        self.collectionView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        // Our project does not use sections. So we can ignore these invocations.
    }
    
    //
    // adds and removes rows in the table, in response to changes in the data.
    //
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            collectionView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            collectionView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    // When endUpdates() is invoked, the collectionView makes the changes visible.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.collectionView.endUpdates()
    }


    
    // MARK: - Collection View Data Source methods
    
    // TODO: - Implement number of items in section
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
    }
    
    // TODO: - Implement Cell for item at indexpath
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
    }

    // MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    

}
