//
//  ParseClients.swift
//  On the Map
//
//  Created by James Dellinger on 11/5/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation

extension APIClients {
    
    // MARK: Multiple student locations from Parse API
    
    /*
     Call the Parse API to retrieve 100 student locations, sorted in order of
     most recent update.
     */
    func getAndSaveStudentLocations(_ completionHandlerForGetAndSaveStudentLocations: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        
        // Configure the request
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        // Make the request
        let task = session.dataTask(with: request) { data, response, error in
            
            // Sends the error message to the completion handler if an error has occured and an
            // error alert pop-up will need to be displayed. Also prints out the error String
            // debug message to the console.
            func sendErrorMessage(_ errorString: String, _ errorMessage: String) {
                print(errorString)
                completionHandlerForGetAndSaveStudentLocations(false, errorMessage)
            }
            
            // The string that will contain the error message, should an error arise.
            var errorString: String = ""
            
            // The message that will be sent to the alert pop-up through the completion handler,
            // should the first and last name retrieval process be unsuccessful.
            let errorMessage = "Could not retrieve student locations."
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                errorString = "Multiple student locations from Parse API: There was an error with your request: \(String(describing: error))"
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                errorString = "Multiple student locations from Parse API: Your request returned a status code other than 2xx."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                errorString = "Multiple student locations from Parse API: No data was returned by the request."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* Parse the data. */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                errorString = "Multiple student locations from Parse API: Could not parse the data as JSON: '\(data)'"
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Is the "results" key in the parsed result? */
            guard let locationResults = parsedResult["results"] as? [[String:AnyObject]] else {
                errorString = "Multiple student locations from Parse API: Cannot find key \"results\" in \(parsedResult)."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /*
             If no error, send the array of location results dictionaries for all
             100 students to the CreateStudentEntries class so that they can be parsed
             into the StudentInformation struct and stored in the studentEntries array, so
             that they'll be accessible to the rest of the app.
             
             Also, if no guard statements were triggered, we've successfully completed the call and
             can send the desired value(s) to completion handler.
             */
            CreateStudentEntries.studentEntriesFromResults(locationResults)
            completionHandlerForGetAndSaveStudentLocations(true, nil)
        }
        
        // Initiate the request
        task.resume()
    }
    
    // MARK: Get single student location from Parse API
    
    /*
     Call the Parse API to determine whether or not the student has a location saved already.
     And if so, get a single student's location and retrieve the objectId string so that, if necessary,
     the student's location can be updated on Parse.
     */
    func getStudentLocation(_ completionHandlerForGetStudentLocation: @escaping (_ success: Bool, _ studentLocationRecordExists: Bool?, _ errorMessage: String?) -> Void) {
        
        // Configure the request
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(userAccountKey!)%22%7D"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        // Make the request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            // Sends the error message to the completion handler if an error has occured and an
            // error alert pop-up will need to be displayed. Also prints out the error String
            // debug message to the console.
            func sendErrorMessage(_ errorString: String, _ errorMessage: String) {
                print(errorString)
                completionHandlerForGetStudentLocation(false, nil, errorMessage)
            }
            
            // The string that will contain the error message, should an error arise.
            var errorString: String = ""
            
            // The message that will be sent to the alert pop-up through the completion handler,
            // should the request to get the student's location information fail.
            let errorMessage = "Could not confirm status of location data for \(self.studentFirstName!) \(self.studentLastName!)."
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                errorString = "Single student location from Parse API: There was an error with your request: \(String(describing: error))"
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                errorString = "Single student location from Parse API: Your request returned a status code other than 2xx."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                errorString = "Single student location from Parse API: No data was returned by the request."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* Parse the data. */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                errorString = "Single student location from Parse API: Could not parse the data as JSON: '\(data)'"
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* Does student already have their location saved through the Parse API? */
            
            /* GUARD: Is the "results" key in the parsed result? */
            guard let locationResults = parsedResult["results"] as? [[String:AnyObject]] else {
                errorString = "Single student location from Parse API: Cannot find key \"results\" in \(parsedResult)."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /*
             Is there only one entry inside the dictionary that's returned under the
             "results" key? If zero entries, then the student hasn't yet uploaded their
             location data to Parse for the first time.
             */
            if locationResults.count == 0 {
                // Student has never uploaded their location data to Parse before. Values passed to
                // completion handler will reflect this.
                completionHandlerForGetStudentLocation(true, false, nil)
                
//                Had included a check that student only had one location on Parse for their Udacity ID.
//                Apparently, this is over-zealous and it's normal for folks on Parse to have multiple
//                location entries (objectIDs) saved under one Udacity Account ID.
//                Not cool that this is allowed. Makes Parse service less interesting and useful.
//            } else if locationResults.count > 1 {
//                // If somehow there is more than one location entry for the student on Parse,
//                // then will return an error.
//                errorString = "Single student location from Parse API: More than one location entry returned for student."
//                sendErrorMessage(errorString, errorMessage)
                
            } else {
                // Otherwise, there is at least one location record for the student, which means they
                // have previously uploaded their location info to Parse.
                
                /* GUARD: Can the first location result be accessed? */
                guard let studentLocationResult = locationResults[0] as? [String:AnyObject] else {
                    errorString = "Single student location from Parse API: Could not access the location result returned for the student."
                    sendErrorMessage(errorString, errorMessage)
                    return
                }
                
                /* GUARD: Is the "uniqueKey" key inside the dictionary that's returned under the
                 "results" key? */
                guard let uniqueKey = studentLocationResult["uniqueKey"] as? String else {
                    errorString = "Single student location from Parse API: Cannot find key \"uniqueKey\" in \(studentLocationResult)"
                    sendErrorMessage(errorString, errorMessage)
                    return
                }
                
                /*
                 GUARD: Is the unique key associated with the student's Parse location entry the same as their
                 Udacity user account key?
                 */
                guard uniqueKey == self.userAccountKey else {
                    errorString = "Single student location from Parse API: unique key stored for student in Parse not identical to their Udacity user account key."
                    sendErrorMessage(errorString, errorMessage)
                    return
                }
                
                /* GUARD: Is the "objectID" key inside the dictionary that's returned under the "results" key? */
                guard let objectId = studentLocationResult["objectId"] as? String else {
                    errorString = "Single student location from Parse API: Cannot find key \"objectId\" in \(studentLocationResult)"
                    sendErrorMessage(errorString, errorMessage)
                    return
                }
                
                /*
                 Student has one location record stored on Parse and its unique key matches
                 student's udacity user account key.
                 */
                // Since we have verified that student has an existing location entry on Parse, set
                // the studentLocationRecordExists flag to true to indicate and remember this.
                self.studentLocationRecordExists = true
                // Store the objectId so that it can be used eventually to update the student's
                // location information in the PUT API call to the Parse server.
                self.objectId = objectId
                // Finally, send the necessary values to the completion handler, in particular the
                // value for studentLocationRecordExists is important. We will use this value back in the
                // view controller that called this method in order to determine whether or not to show a
                // pop-up asking the user whether they want to overwrite a previously stored location
                // record.
                completionHandlerForGetStudentLocation(true, true, nil)
            }
        }
        // Initiate the request
        task.resume()
    }
    
    // MARK: Add or update student's location
    
    /*
     If a location has been saved, update (put) the student's location, using the student's location entry's
     "objectId" that was retrieved in the check to see whether student had a location entry saved or not.
     Otherwise, add (post) the student's location for the first time.
     */
    func addOrUpdateStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandlerForAddOrUpdateStudentLocation: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        
        if studentLocationRecordExists! {
            // If location record already does exist, then update the student's location on Parse.
            self.putStudentLocation(objectId: objectId!, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude) {
                (success, errorMessage) in
                if success {
                    // If successful, indicate this in the completion handler.
                    completionHandlerForAddOrUpdateStudentLocation(true, nil)
                } else {
                    // If unsuccessful, indicate this in the completion handler and send
                    // along the error message that will be displayed in the app.
                    completionHandlerForAddOrUpdateStudentLocation(false, errorMessage)
                }
            }
        } else {
            // If a student location record doesn't exist (studentLocationRecordExists is false), then post
            // the student's location to the Parse sever for the first time.
            self.postStudentLocation(mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude) {
                (success, errorMessage) in
                if success {
                    // If successful, indicate this in the completion handler.
                    completionHandlerForAddOrUpdateStudentLocation(true, nil)
                } else {
                    // If unsuccessful, indicate this in the completion handler and send
                    // along the error message that will be displayed in the app.
                    completionHandlerForAddOrUpdateStudentLocation(false, errorMessage)
                }
            }
        }
    }
    
    // MARK: Post a student's location to the Parse API
    
    /*
     Call the Parse API and upload a single student's location info to it for the
     first time.
     */
    func postStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, _ completionHandlerForPostStudentLocation: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        
        // Configure the request
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(userAccountKey)\", \"firstName\": \"\(studentFirstName)\", \"lastName\": \"\(studentLastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\", \"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: .utf8)
        
        // Make the request
        let task = session.dataTask(with: request) { data, response, error in
            
            // Sends the error message to the completion handler if an error has occured and an
            // error alert pop-up will need to be displayed. Also prints out the error String
            // debug message to the console.
            func sendErrorMessage(_ errorString: String, _ errorMessage: String) {
                print(errorString)
                completionHandlerForPostStudentLocation(false, errorMessage)
            }
            
            // The string that will contain the error message, should an error arise.
            var errorString: String = ""
            
            // The message that will be sent to the alert pop-up through the completion handler,
            // should the attempt to post the student's location info to the Parse API for the first
            // time be unsuccessful.
            let errorMessage = "Could not successfully upload your location to the Parse server."
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                errorString = "Post student location to Parse API: There was an error with your request: \(String(describing: error))"
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                errorString = "Post student location to Parse API: Your request returned a status code other than 2xx."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                errorString = "Post student location to Parse API: No data was returned by the request."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* Parse the data. */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                errorString = "Post student location to Parse API: Could not parse the data as JSON: '\(data)'"
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Is the "updatedAt" key in the parsed result? */
            guard let _ = parsedResult["updatedAt"] as? String else {
                errorString = "Cannot find key \"updatedAt\" in \(parsedResult)."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            // If the "updatedAt" timestamp is inside the parsed result, we know
            // that the student's location info has been successfully added to Parse.
            completionHandlerForPostStudentLocation(true, nil)
        }
        
        // Initiate the request
        task.resume()
    }
    
    // MARK: Update a student's location on the Parse API
    
    /*
     Call the Parse API and update a single student's location info.
     */
    func putStudentLocation(objectId: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, _ completionHandlerForPutStudentLocation: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        
        // Configure the request
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation/\(objectId)")!)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(userAccountKey!)\", \"firstName\": \"\(self.studentFirstName!)\", \"lastName\": \"\(self.studentLastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\", \"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: .utf8)
        
        // Make the request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            // Sends the error message to the completion handler if an error has occured and an
            // error alert pop-up will need to be displayed. Also prints out the error String
            // debug message to the console.
            func sendErrorMessage(_ errorString: String, _ errorMessage: String) {
                print(errorString)
                completionHandlerForPutStudentLocation(false, errorMessage)
            }
            
            // The string that will contain the error message, should an error arise.
            var errorString: String = ""
            
            // The message that will be sent to the alert pop-up through the completion handler,
            // should the attempt to update the student's location on the Parse API be unsuccessful.
            let errorMessage = "Could not successfully update your location on the Parse server."
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                errorString = "Put student location to Parse API: There was an error with your request: \(String(describing: error))"
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                errorString = "Put student location to Parse API: Your request returned a status code other than 2xx."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                errorString = "Put student location to Parse API: No data was returned by the request."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* Parse the data. */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                errorString = "Put student location to Parse API: Could not parse the data as JSON: '\(data)'"
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Is the "updatedAt" key in the parsed result? */
            guard let _ = parsedResult["updatedAt"] as? String else {
                errorString = "Cannot find key \"updatedAt\" in \(parsedResult)."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            // If the "updatedAt" timestamp is inside the parsed result, we know
            // that the student's location info has been successfully updated on Parse.
            completionHandlerForPutStudentLocation(true, nil)
            
        }
        // Initiate the request
        task.resume()
    }
}
