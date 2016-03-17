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
        
        static let EXTRAS = "url_m"
        static let SAFE_SEARCH = "1"
        static let DATA_FORMAT = "json"
        static let NO_JSON_CALLBACK = "1"
        static let CONTENT_TYPE = "1"
        static let NUM_PHOTOS = 21
        static let PHOTOS_PER_PAGE = 200    
        
        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
        
    }
    
    // MARK: Methods
    struct Methods {
        
        static let photoSearchMethod = "flickr.photos.search"
        
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        
        static let ApiKey = "api_key"
        static let bbox = "bbox"
        static let safeSearch = "safe_search"
        static let contentType = "content_type"
        static let extras = "extras"
        static let perPage = "per_page"
        
    }
       

}
