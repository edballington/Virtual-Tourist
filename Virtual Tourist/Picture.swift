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
    @NSManaged var pin: Pin               //Annotation for the photo
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(imageURL: String, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Picture", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.imageURL = imageURL
        
    }
}