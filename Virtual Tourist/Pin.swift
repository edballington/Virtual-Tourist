//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Ed Ballington on 2/23/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import CoreData
import MapKit

class Pin: NSManagedObject {
    
    @NSManaged var pinLatitude: Double
    @NSManaged var pinLongitude: Double
    @NSManaged var pictures: [Picture]
    
    var coordinate : CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: pinLatitude, longitude: pinLongitude)
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(lat: Double, long: Double, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        pinLatitude = lat
        pinLongitude = long
        
    }

}
