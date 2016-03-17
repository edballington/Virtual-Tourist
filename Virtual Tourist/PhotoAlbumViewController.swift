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

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource  {
    
    //MARK: - Constants
    let GRID_SPACING: CGFloat = 2.0     //Spacing between elements of the collection view grid
    let EDGE_INSETS: CGFloat = 2.0      //Insets for the collection view sections

    //MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomButton: UIBarButtonItem!

    //MARK: - Properties
    var pinForPhotos: Pin!
    var selectedPictures: [Picture]?      //Array to keep track of Pictures selected for removal
    
    var selectedIndexes = [NSIndexPath]()       //Tracking array of indexPaths selected by tapping in collectionView
    var insertedIndexPaths = [NSIndexPath]()    //Tracking array of indexPaths to be inserted in collectionView
    var deletedIndexPaths = [NSIndexPath]()     //Tracking array of indexPaths to be deleted in collectionView
    
    
    //MARK: - Actions
    
    //Either remove selected photos or load new collection depending on state of bottom button
    @IBAction func bottomButtonAction(sender: AnyObject) {
        
        if bottomButton.enabled {
            
            if selectedIndexes.isEmpty {    //No pictures selected so load new collection
                
                //First remove all of the existing pictures
                for object in fetchedResultsController.fetchedObjects! {
                    let indexPath = fetchedResultsController.indexPathForObject(object)
                    sharedContext.deleteObject(fetchedResultsController.objectAtIndexPath(indexPath!) as! Picture)
                }
            
                loadPictures()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView.reloadData()
                })
                
            } else {                        //Pictures selected - delete them
                
                for indexPath in selectedIndexes {
                    sharedContext.deleteObject(fetchedResultsController.objectAtIndexPath(indexPath) as! Picture)
                }
                
                //Reset the selectedIndexes array
                selectedIndexes.removeAll()
                toggleBottomButton()
                
            }
            
            self.saveContext()
            
        }
        
    }
    
    //MARK: - View Controller Lifecycle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            //Set mapviews center and range based on pin coordinates passed to the view controller
            let span = MKCoordinateSpanMake(0.2, 0.2)
            let region = MKCoordinateRegionMake(self.pinForPhotos.coordinate, span)
            
            self.mapView.setRegion(region, animated: false)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.pinForPhotos.coordinate
            
            self.mapView.addAnnotation(annotation)
            
        }
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        fetchedResultsController.delegate = self

        // Fetch the stored photos data if any already exists
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching Pictures for pin: \(error)")
            abort()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        //Make sure cells get laid out in squares with 3 across
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = GRID_SPACING
        flowLayout.minimumInteritemSpacing = GRID_SPACING
        flowLayout.scrollDirection = .Vertical
        let imageSize = floor((self.collectionView.frame.size.width-9)/3)
        flowLayout.itemSize = CGSize(width: imageSize, height: imageSize)
        flowLayout.sectionInset = UIEdgeInsets(top: EDGE_INSETS, left: EDGE_INSETS, bottom: EDGE_INSETS, right: EDGE_INSETS)
        
        collectionView.collectionViewLayout = flowLayout
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        //If there are no photos because this is the first time for this pin then load some
        if pinForPhotos.pictures.isEmpty {
            loadPictures()
        }
        
    }
    
    // MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Picture")
        
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pinForPhotos);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    //MARK: - Collection View Data Source methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        let picture = fetchedResultsController.objectAtIndexPath(indexPath) as! Picture
        configureCell(cell, picture: picture)

        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        
        //Toggle the cell indexes presence in the selectedIndexes array - if its already in there remove it from the array, otherwise add it in.
        if let selectedIndex = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(selectedIndex)
            selectedCell.imageView.alpha = 1.0
        } else {
            selectedIndexes.append(indexPath)
            selectedCell.imageView.alpha = 0.5
        }
        
        //Change the bottom button function and text to appropriate values 
        toggleBottomButton()
        
    }
    
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        //Reset the arrays that track the indexPaths to handle the changes in content
        selectedIndexes.removeAll()
        insertedIndexPaths.removeAll()
        deletedIndexPaths.removeAll()
        
    }
    
    //Handle the various change types every time a collection view cell makes a change
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break
        default:
            return
            
        }
        
    }

    
    //Perform an animated batch change of all of the updates after collecting the indexPaths into the appropriate arrays
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        //Enable bottom button if there are any pictures
        if controller.fetchedObjects?.count > 0 {
            bottomButton.enabled = true
        }
     
        collectionView.performBatchUpdates({ () -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            self.collectionView.reloadData()
            
            
            //Make sure to save everything
            self.saveContext()
            
            }, completion: nil)
        
    }
    
    

    
    //MARK: - Other Convenience methods
    
    //Set up the collection view cell with a picture
    func configureCell(cell: PhotoCollectionViewCell, picture: Picture) {
        
        
        let _ = FlickrClient.sharedInstance().taskForPhoto(picture.imageURL) { (imageData, error) -> Void in
            
            if let error = error {
                print("Error downloading photo: \(error.localizedDescription)")
            }
            
            if let data = imageData {
                
                let image = UIImage(data: data)
                
                //Update the cell
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.imageView.image = image
                    cell.imageView.alpha = 1.0
                })
            }
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                cell.activityIndicator.stopAnimating()
            }
            
        }
        
    }
    
    func toggleBottomButton() -> Void {
        
        //If there are any photos selected then change the title, otherwise leave it alone
            
            if selectedIndexes.isEmpty {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.bottomButton.title = "New Collection"
                })
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.bottomButton.title = "Remove Selected Pictures"
                })
                
            }
        
    }
    
    func showAlertView(message: String?) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func loadPictures() {
        
        //Disable bottom button while pictures are loading
        self.bottomButton.enabled = false
        
        FlickrClient.sharedInstance().getPicturesFromFlickrBySearch(pinForPhotos.pinLatitude, long: pinForPhotos.pinLongitude) { (JSONresults, error) -> Void in
            
            if let error = error {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.showAlertView("Error retrieving photo URL's from Flickr")
                    print("Error retrieving photo URL's from Flickr: \(error)")
                })
            } else {
                
                if let results = JSONresults {
                    
                    for result in results {
                        
                        let imageURL = result["url_m"]! as String
                        let picture = Picture(imageURL: imageURL, context: self.sharedContext)
                        picture.pin = self.pinForPhotos
                        
                    }
                    
                    self.saveContext()
                    
                } else {    //No JSON returned
                    print("No JSON returned from Flickr by getImagesFromFlickrBySearch: \(error)")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.showAlertView("Error parsing photos from Flickr")
                    })
                
            }
            
            
        }
        
        //Re-enable the bottom button
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.bottomButton.enabled = true
        }

        }

}

}
