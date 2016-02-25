//
//  MapState.swift
//  Virtual Tourist
//
//  Created by Ed Ballington on 2/24/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import MapKit
import CoreData

class MapState: NSManagedObject {
        
        @NSManaged var latitude: Double
        @NSManaged var longitude: Double
        @NSManaged var latitudeDelta: Double
        @NSManaged var longitudeDelta: Double
    
        var region : MKCoordinateRegion {
            get {
                let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
                return MKCoordinateRegion(center: center, span: span)
            }
        }
        
        override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
            super.init(entity: entity, insertIntoManagedObjectContext: context)
        }
        
        init(lat: Double, long: Double, latDelta: Double, longDelta: Double, context: NSManagedObjectContext) {
            
            // Core Data
            let entity =  NSEntityDescription.entityForName("MapState", inManagedObjectContext: context)!
            super.init(entity: entity, insertIntoManagedObjectContext: context)
            
            latitude = lat
            longitude = long
            latitudeDelta = latDelta
            longitudeDelta = longDelta
            
        }

}
