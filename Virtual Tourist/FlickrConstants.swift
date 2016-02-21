//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Ed Ballington on 2/19/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//


extension FlickrClient {
    
    // MARK: Constants
    struct Constants {
        
        static let FlickrAPIKey : String = "90aa18bf9e84e101a6959bf0700f7784"
        static let FlickrBaseURLSecure : String = "https://api.flickr.com/services/rest/"
        
        let EXTRAS = "url_m"
        let SAFE_SEARCH = "1"
        let DATA_FORMAT = "json"
        let NO_JSON_CALLBACK = "1"
        let CONTENT_TYPE = "1"
        let NUM_PHOTOS = "21"
        
        let BOUNDING_BOX_HALF_WIDTH = 1.0
        let BOUNDING_BOX_HALF_HEIGHT = 1.0
        let LAT_MIN = -90.0
        let LAT_MAX = 90.0
        let LON_MIN = -180.0
        let LON_MAX = 180.0
        
    }
    
    // MARK: Methods
    struct Methods {
        
        static let photoSearchMethod = "flickr.photos.search"
        
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        
        static let ApiKey = "api_key"
        static let bbox = "bbox"
        static let contentType = "content_type"
        static let lat = "lat"
        static let long = "lon"
        static let perPage = "per_page"
        
    }
    
    // MARK: JSON Body Keys********
    struct JSONBodyKeys {
        
        static let udacity = "udacity"
        static let username = "username"
        static let password = "password"
        static let account = "account"
        static let key = "key"
        
        static let uniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
        static let ACL = "ACL"
        
    }
    
    // MARK: JSON Response Keys********
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let Session = "session"
        static let sessionID = "id" 
        
        // MARK: Account
        static let UserID = "id"
        static let account = "account"
        static let key = "key"
        
        static let user = "user"
        static let last_name = "last_name"
        static let first_name = "first_name"
        static let results = "results"
        
        // MARK: Student Locations
        static let LocationResults = "results"  
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let objectID = "objectId"
        static let uniqueKey = "uniqueKey"
        static let updatedAt = "updatedAt"
        
        
    }
    

}
