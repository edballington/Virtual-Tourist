//
//  image.swift
//  Virtual Tourist
//
//  Created by Ed Ballington on 3/20/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import UIKit
import CoreData

class image: NSManagedObject {
    
    @NSManaged var imageFile: NSData?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(image: NSData, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("imageFile", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.imageFile = image
        
    }
    
}
