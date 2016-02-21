//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by Ed Ballington on 12/8/15.
//  Copyright © 2015 Ed Ballington. All rights reserved.
//

import UIKit
import Foundation
import MapKit

// MARK: - OTMClient (Convenient Resource Methods)

extension OTMClient {
    
    //MARK: Udacity authentication and account methods
    
    func authenticateWithUdacity(login: String, password: String, completionHandler: (sessionID: String?, accountKey: String?, error: NSError?) -> Void) {
        
        /* Set up HTTP Body with correct parameters */
        let jsonBody : [String : AnyObject] = ["udacity" : [
            OTMClient.JSONBodyKeys.username : login,
            OTMClient.JSONBodyKeys.password : password
        ]]
        
        /* Make the request */
        taskForUdacityPOSTMethod(OTMClient.Methods.Session, jsonBody: jsonBody) {
            JSONResult, error in
            
            /* Send error values to completion handler */
            if let error = error {
                completionHandler(sessionID: nil, accountKey: nil, error: error)
                
            } else {
                if let sessionID = JSONResult[OTMClient.JSONResponseKeys.Session]??[OTMClient.JSONResponseKeys.sessionID] as? String {
                    
                    let accountKey = JSONResult[OTMClient.JSONResponseKeys.account]??[OTMClient.JSONResponseKeys.key] as? String
                    
                    completionHandler(sessionID: sessionID, accountKey: accountKey,error: nil)
                } else {
                    completionHandler(sessionID: nil, accountKey: nil, error: error)
                }
                
                
            }
            
        }
        
    }
    
    func getUdacityStudentName(userID: String, completionHandler: (firstName: String?, lastName: String?, error: NSError?) -> Void) {
        
        /* Make the Udacity GET request */
        taskForUdacityGETMethod(OTMClient.Methods.Users, userID: OTMClient.sharedInstance().userID!) { (result, error) -> Void in
            
            if let error = error {
                completionHandler(firstName: nil, lastName: nil, error: error)
            } else {
                
                if let lastName = result[OTMClient.JSONResponseKeys.user]??[OTMClient.JSONResponseKeys.last_name] as? String {
                    let first_name = result[OTMClient.JSONResponseKeys.user]??[OTMClient.JSONResponseKeys.first_name] as? String
                    
                    completionHandler(firstName: first_name, lastName: lastName, error: nil)
                    
                } else {
                    
                    completionHandler(firstName: nil, lastName: nil, error: nil)
                }
                
            }
            
        }
        
    }
    
    func logoutWithUdacity(sessionID: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        /* Make the Udacity DELETE request */
        taskForUdacityDELETEMethod(OTMClient.Methods.Session) {result, error in
         
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                if let session = result[OTMClient.JSONResponseKeys.Session]??[OTMClient.JSONResponseKeys.sessionID] as? String {
                    
                    //DELETE method returned a session so set the shared instance sessionID back to nil
                    OTMClient.sharedInstance().sessionID = nil
                    completionHandler(success: true, error: nil)
                    
                } else {
                    completionHandler(success: false, error: nil)
                }
            
            }
        }
    }
    
    //MARK: Student location methods
    
    //Retrieves the student information entries from PARSE and stores them in a singleton student information array model
    func getStudentLocations(limit: String, completionHandler: (error: NSError?) -> Void) {
        
        let parameters : [String : AnyObject] = [OTMClient.ParameterKeys.limit : limit, "order" : "-updatedAt"]
        
        let method : String = Methods.Location

        taskForParseGETMethod(method, parameters: parameters) { JSONResult, error in
            
            if let error = error {
                
                completionHandler(error: error)
                
            } else {
                
                if let results = JSONResult?[OTMClient.JSONResponseKeys.LocationResults] as? [[String : AnyObject]] {
                    
                    /* Delete any previous entries in the StudentInformation array */
                    StudentInformationModel.sharedInstance().studentInformationArray.removeAll()
                    
                    for location in results {

                        /* Create the StudentInformation object from the values retrieved from the JSON */
                        let location = StudentInformation.init(dictionary: location)
                        
                        /* Add the newly created location to the StudentInformation array */
                        StudentInformationModel.sharedInstance().studentInformationArray.append(location)
                    }
                    
                    completionHandler(error: nil)
                } else {
                    completionHandler(error: NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
            
        }
        
    }
    
    
    //Take a StudentInformation object and make it into an annotation
    func createAnnotationFromStudentInformation(location: StudentInformation) ->MKPointAnnotation {
        
        let annotation = MKPointAnnotation()
        
        let lat = CLLocationDegrees(location.latitude!)
        let long = CLLocationDegrees(location.longitude!)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let first = location.firstName!
        let last = location.lastName!
        let mediaURL = location.mediaURL!
        
        annotation.coordinate = coordinate
        annotation.title = "\(first) \(last)"
        annotation.subtitle = mediaURL
        
        return annotation
    }
    
    //MARK: - PARSE Database methods
    
    //Check for a StudentInformation entry already in PARSE - use Udacity userId as key
    func checkForDuplicateStudentInformation(userID: String, completionHandler: (duplicateFound: Bool, error: NSError?) -> Void) {
        
        let method : String = OTMClient.Methods.Location
        let parameters : String = "?where=%7B%22\(OTMClient.ParameterKeys.uniqueKey)%22%3A%22\(userID)%22%7D"
        
        taskForParseGETQueryMethod(method, parameters: parameters) { (JSONResult, error) -> Void in
            
            if let error = error {
                print("Error querying for student information: \(error)")
                completionHandler(duplicateFound: false, error: error)
            }
            
            //If any JSON results are returned from the query then the user already has an entry.  If not then its the first time
            
            if let results = JSONResult?[OTMClient.JSONResponseKeys.results] as? [[String : AnyObject]] {
                //Save the PARSE objectId of the returned results
                OTMClient.sharedInstance().objectID = results[0][OTMClient.JSONResponseKeys.objectID] as? String
                completionHandler(duplicateFound: true, error: nil)
            } else {
                OTMClient.sharedInstance().objectID = nil
                completionHandler(duplicateFound: false, error: nil)
            }
            
        }
        
    }
    
    //Add a new StudentInformation entry to PARSE database
    func addStudentInformationToPARSE(studentInfo : StudentInformation, completionHandler: (success: Bool, objectId: String?, error: NSError?) -> Void) {
        
        //First create the jsonBody from the StudentInformation object
        var jsonBody = [String : AnyObject]()
        jsonBody[JSONBodyKeys.uniqueKey] = studentInfo.uniqueKey
        jsonBody[JSONBodyKeys.FirstName] = studentInfo.firstName
        jsonBody[JSONBodyKeys.LastName] = studentInfo.lastName
        jsonBody[JSONBodyKeys.MapString] = studentInfo.mapString
        jsonBody[JSONBodyKeys.MediaURL] = studentInfo.mediaURL
        jsonBody[JSONBodyKeys.Latitude] = studentInfo.latitude
        jsonBody[JSONBodyKeys.Longitude] = studentInfo.longitude
        
        taskForParsePOSTMethod(OTMClient.Methods.Location, jsonBody: jsonBody) { (JSONResult, error) -> Void in
            
            if let error = error {
                print("Error posting student location to PARSE: \(error)")
                completionHandler(success: false, objectId: nil, error: error)
            }
            
            if let results = JSONResult?[OTMClient.JSONResponseKeys.objectID] as? String {
                //Return the ObjectID
                completionHandler(success: true, objectId: results, error: nil)
            } else {
                completionHandler(success: false, objectId: nil, error: nil)
            }
            
        }
        
    }
    
    //Update an existing StudentInformation entry in PARSE database
    func updateStudentInformationInPARSE(objectId: String, studentInfo: StudentInformation, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        //First create the jsonBody from the StudentInformation object
        var jsonBody = [String : AnyObject]()
        jsonBody[JSONBodyKeys.uniqueKey] = studentInfo.uniqueKey
        jsonBody[JSONBodyKeys.FirstName] = studentInfo.firstName
        jsonBody[JSONBodyKeys.LastName] = studentInfo.lastName
        jsonBody[JSONBodyKeys.MapString] = studentInfo.mapString
        jsonBody[JSONBodyKeys.MediaURL] = studentInfo.mediaURL
        jsonBody[JSONBodyKeys.Latitude] = studentInfo.latitude
        jsonBody[JSONBodyKeys.Longitude] = studentInfo.longitude
        
        taskForParsePUTMethod(OTMClient.Methods.Location, objectID: objectID!, jsonBody: jsonBody) { (result, error) -> Void in
            
            guard (error == nil) else {
                print("Error updating student location in PARSE: \(error)")
                completionHandler(success: false, error: error)
                return
            }
            
            guard (result != nil) else {
                completionHandler(success: false, error: nil)
                return
            }
            
            completionHandler(success: true, error: nil)
            
        }
    
        }

}
