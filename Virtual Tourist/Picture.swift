//
//  Picture.swift
//  Virtual Tourist
//
//  Created by Ed Ballington on 2/21/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import UIKit
import CoreData

class Picture: NSManagedObject {
    
    @NSManaged var imageURL: String      //Flickr photo URL
    @NSManaged var imageFilePath : String?  //Optional string file path in case there is a local downloaded copy to use
    @NSManaged var pin: Pin               //Annotation for the photo
    
    var image: UIImage? {               //Getter for the local image file if there is one
        
        //Below only works if there is a locally stored image file
        if let filePath = imageFilePath {
            
            // Get the file path
            let imageFileName = (filePath as NSString).lastPathComponent
            let imagesDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let pathArray = [imagesDirectory, imageFileName]
            let imageFileURL = NSURL.fileURLWithPathComponents(pathArray)!
            
            return UIImage(contentsOfFile: imageFileURL.path!)
        }
        return nil
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(imageURL: String, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Picture", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.imageURL = imageURL
        
    }
    
    //Automatically delete saved image file when Picture object is deleted
    override func prepareForDeletion() {
        
        if let imageFileName = (imageFilePath as? NSString)?.lastPathComponent {
            let imagesDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let pathArray = [imagesDirectory, imageFileName]
            let imageFileURL = NSURL.fileURLWithPathComponents(pathArray)!
            
            do {
                try NSFileManager.defaultManager().removeItemAtURL(imageFileURL)
            } catch _ {
                print("Error deleting photo file from images directory for image file:  \(imageFileURL.lastPathComponent)")
                abort()
            }
        
        }
        
    }
    
}