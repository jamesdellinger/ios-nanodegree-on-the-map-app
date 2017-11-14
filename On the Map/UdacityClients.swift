//
//  UdacityClients.swift
//  On the Map
//
//  Created by James Dellinger on 11/5/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation
import UIKit

class APIClients: NSObject {
    
    // MARK: Properties
    
    // Shared session
    let session = URLSession.shared
    
    // Suthentication state
    var sessionID: String? = nil
    /* userAccountKey will be passed as the "unique key" when posting a student location to the Parse API. */
    var userAccountKey: String? = nil
    var studentFirstName: String? = nil
    var studentLastName: String? = nil
    
    // This flag is true if student has already uploaded location data to Parse once.
    // It's how we know whether to call the PUT or POST Parse API when updating a user's
    // location.
    var studentLocationRecordExists: Bool? = nil
    // If student has already uploaded location data, we retrieve the objectId and store in
    // this variable. We need it when we call the Parse PUT method.
    var objectId: String? = nil
    
    
    // MARK: Initial Login
    
    func loginToUdacityAndGetStudentLocations(userName: String, passWord: String, completionHandlerForLoginAndGetStudentLocations: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        
        retrieveUdacitySessionIDAndUserAccountKey(userName: userName, passWord: passWord) { (success, sessionID, userAccountKey, errorMessage) in
            if success {
                // If successful, we have received and can now store the Udacity session ID and user account key.
                self.sessionID = sessionID
                self.userAccountKey = userAccountKey
                
                // We can also retrieve the user's first and last name from their public Udacity data by
                // calling the Udacity API with the user's account key that we just retrieved.
                self.getUdacityStudentFirstAndLastName(accountKey: userAccountKey!) { (success, studentFirstName, studentLastName, errorMessage) in
                    if success {
                        // If successful, we have received and can now store the Udacity user's first and last name.
                        self.studentFirstName = studentFirstName
                        self.studentLastName = studentLastName
                        
                        // After retrieving and storing the Udacity user's pertintent info (which we
                        // will need to perform the rest of our app's use-cases, we can call the Parse
                        // API in order to retrieve and store location info for 100 students to display
                        // in the map and table view controllers in our app.
                        self.getAndSaveStudentLocations() { (success, errorMessage) in
                            if success {
                                // If successful, we have received 100 student locations from the Parse API, in
                                // order of most to least recently updated. Each entry has also been converted
                                // to the StudentInformation struct and stored in the studentEntries array defined
                                // in the CreateStudentEntries class. This array will be used by the controllers in
                                // the app to display student locations.
                                
                                /* Also, send the desired value(s) to completion handler to indicate success. */
                                completionHandlerForLoginAndGetStudentLocations(success, errorMessage)
                            } else {
                                completionHandlerForLoginAndGetStudentLocations(success, errorMessage)
                            }
                        }
                    } else {
                        completionHandlerForLoginAndGetStudentLocations(success, errorMessage)
                    }
                }
            } else {
                completionHandlerForLoginAndGetStudentLocations(success, errorMessage)
            }
        }
    }
    
    // MARK: Udacity Login API
    
    /*
     Log in to Udacity's session API with user's Udacity username and password.
     Retrieve the user's account key in order to make a subsequent call that retrieve's user's
     public data.
     */
    private func retrieveUdacitySessionIDAndUserAccountKey(userName: String, passWord: String, _ completionHandlerForSessionIDAndUserAccountKey: @escaping (_ success: Bool, _ sessionID: String?, _ userAccountKey: String?, _ errorMessage: String?) -> Void) {
        
        // Configure the request
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(passWord)\"}}".data(using: .utf8)
        
        // Make the request
        let task = session.dataTask(with: request) { data, response, error in
            
            // Sends the error message to the completion handler if an error has occured and an
            // error alert pop-up will need to be displayed. Also prints out the error String
            // debug message to the console.
            func sendErrorMessage(_ errorString: String, _ errorMessage: String) {
                print(errorString)
                completionHandlerForSessionIDAndUserAccountKey(false, nil, nil, errorMessage)
            }
            
            // The string that will contain a detailed error description, should an error arise. For debugging purposes.
            var errorString: String = ""
            
            // The message that will be sent to the alert pop-up through the completion handler,
            // should the login process be unsuccessful.
            var errorMessage: String = "Unable to complete Udacity account login."
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                errorString = "Udacity Login API: There was an error with your request: \(String(describing: error))"
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Was the email and or password incorrect (Udacity server returned 403 code)? */
            guard let statusCodeForbidden = (response as? HTTPURLResponse)?.statusCode, statusCodeForbidden != 403 else {
                errorString = "Udacity Login API: Your request returned a status code of 403 (forbidden)."
                errorMessage = "The email and or password you entered was incorrect."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                errorString = "Udacity Login API: Your request returned a status code other than 2xx."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                errorString = "Udacity Login API: No data was returned by the request."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* Parse the data.
             Note: Must omit the first five characters of all responses from the Udacity API.
             First define the range of data that we will look at (everything but the first
             five characters. Then, take all the data inside this range and parse it.
             */
            let range = Range(5..<data.count)
            
            // The subset of returned data
            let newData = data.subdata(in: range)
            
            // Parse the subset
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {
                errorString = "Udacity Login API: Could not parse the data as JSON: '\(newData)'"
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            // Getting the session ID
            /* GUARD: Is the "session" key in the parsed result? */
            guard let sessionDictionary = parsedResult["session"] as? [String:AnyObject] else {
                errorString = "Udacity Login API: Cannot find key \"session\" in parsed JSON data from Udacity."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Is the "id" key in the dictionary that's returned under the "session" key? */
            guard let sessionID = sessionDictionary["id"] as? String else {
                errorString = "Udacity Login API: Cannot find key \"id\" in \(sessionDictionary)."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            
            // Getting the user's account Key
            /* GUARD: Is the "account" key in the parsed result? */
            guard let accountDictionary = parsedResult["account"] as? [String:AnyObject] else {
                errorString = "Udacity Login API: Cannot find key \"account\" in \(parsedResult)."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Is the "key" key inside the dictionary that's returned under the
             "account" key? */
            guard let userAccountKey = accountDictionary["key"] as? String else {
                errorString = "Udacity Login API: Cannot find key \"key\" in \(accountDictionary)."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /*
             If no guard statements were triggered, we've successfully completed the call and
             can send the desired value(s) to completion handler.
             */
            completionHandlerForSessionIDAndUserAccountKey(true, sessionID, userAccountKey, nil)
        }
        
        // Initiate the request
        task.resume()
    }
    
    // MARK: Udacity Public User Data API
    
    /*
     Log in to Udacity's API with the user's account key string retrieved in the call to the
     session API method.
     */
    private func getUdacityStudentFirstAndLastName(accountKey: String, _ completionHandlerForUdacityUserFirstAndLastName: @escaping (_ success: Bool, _ studentFirstName: String?, _ studentLastName: String?, _ errorMessage: String?) -> Void) {
        
        // Configure the request
        let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(accountKey)")!)
        
        // Make the request
        let task = session.dataTask(with: request) { data, response, error in
            
            // Sends the error message to the completion handler if an error has occured and an
            // error alert pop-up will need to be displayed. Also prints out the error String
            // debug message to the console.
            func sendErrorMessage(_ errorString: String, _ errorMessage: String) {
                print(errorString)
                completionHandlerForUdacityUserFirstAndLastName(false, nil, nil, errorMessage)
            }
            
            // The string that will contain a detailed error description, should an error arise. For debugging purposes.
            var errorString: String = ""
            
            // The message that will be sent to the alert pop-up through the completion handler,
            // should the first and last name retrieval process be unsuccessful.
            let errorMessage = "Could not retrieve student details from the Udacity server."
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                errorString = "Udacity Public User Data API: There was an error with your request: \(String(describing: error))"
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                errorString = "Udacity Public User Data API: Your request returned a status code other than 2xx."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                errorString = "Udacity Public User Data API: No data was returned by the request."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* Parse the data.
             Note: Must omit the first five characters of all responses from the Udacity API.
             First define the range of data that we will look at (everything but the first
             five characters. Then, take all the data inside this range and parse it.
             */
            let range = Range(5..<data.count)
            
            // The subset of returned data
            let newData = data.subdata(in: range)
            
            // Parse the subset
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {
                errorString = "Udacity Public User Data API: Could not parse the data as JSON: '\(newData)'"
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            // Getting the student's first and last names from their Udacity public user data
            /* GUARD: Is the "user" key in the parsed result? */
            guard let userInfoDictionary = parsedResult["user"] as? [String:AnyObject] else {
                errorString = "Udacity Public User Data API: Cannot find key \"user\" in \(parsedResult)."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Is the "first_name" key in the dictionary returned under the "user" key? */
            guard let studentFirstName = userInfoDictionary["first_name"] as? String else {
                errorString = "Udacity Public User Data API: Cannot find key \"first_name\" in \(userInfoDictionary)."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Is the "last_name" key in the dictionary returned under the "user" key? */
            guard let studentLastName = userInfoDictionary["last_name"] as? String else {
                errorString = "Udacity Public User Data API: Cannot find key \"last_name\" in \(userInfoDictionary)."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /*
             If no guard statements were triggered, we've successfully completed the call and
             can send the desired value(s) to completion handler.
             */
            completionHandlerForUdacityUserFirstAndLastName(true, studentFirstName, studentLastName, nil)
        }
        
        // Initiate the request
        task.resume()
    }
    
    // MARK: Udacity Delete session (logout) API
    
    /*
     Deletes the cookie associated with the user's Udacity session ID.
     */
    func deleteUdacitySessionID(_ completionHandlerDeleteUdacitySessionID: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        
        // Configure the request
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        
        //Specify the cookie
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        // Make the request
        let task = session.dataTask(with: request) { data, response, error in
            // Sends the error message to the completion handler if an error has occured and an
            // error alert pop-up will need to be displayed. Also prints out the error String
            // debug message to the console.
            func sendErrorMessage(_ errorString: String, _ errorMessage: String) {
                print(errorString)
                completionHandlerDeleteUdacitySessionID(false, errorMessage)
            }
            
            // The string that will contain a detailed error description, should an error arise. For debugging purposes.
            var errorString: String = ""
            
            // The message that will be sent to the alert pop-up through the completion handler,
            // should the logout process be unsuccessful.
            let errorMessage = "Could not logout from the Udacity server."
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                errorString = "Udacity Delete session (logout) API: There was an error with your request: \(String(describing: error))"
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                errorString = "Udacity Delete session (logout) API: Your request returned a status code other than 2xx."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                errorString = "Udacity Delete session (logout) API: No data was returned by the request."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* Parse the data.
             Note: Must omit the first five characters of all responses from the Udacity API.
             First define the range of data that we will look at (everything but the first
             five characters. Then, take all the data inside this range and parse it.
             */
            let range = Range(5..<data.count)
            
            // The subset of returned data
            let newData = data.subdata(in: range)
            
            // Parse the subset
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {
                errorString = "Udacity Delete session (logout) API: Could not parse the data as JSON: '\(newData)'"
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Is the "session" key in the parsed result? */
            guard let sessionDictionary = parsedResult["session"] as? [String:AnyObject] else {
                errorString = "Udacity Delete session (logout) API: Cannot find key \"session\" in \(parsedResult)."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Is the "id" key inside the dictionary that's returned under the
             "session" key? */
            guard let idKey = sessionDictionary["id"] as? String else {
                errorString = "Cannot find key \"id\" in \(sessionDictionary)."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /* GUARD: Are the first six characters of the returned session id key the same as those of
             the session ID received upon initial login? */
            let returnedSessionIDSixthCharacterIndex = idKey.unicodeScalars.index(idKey.startIndex, offsetBy: 6)
            
            // First six characters of session ID Udacity server returned in response to delete request.
            let returnedSessionIDFirstSixCharacters = idKey[..<returnedSessionIDSixthCharacterIndex]
            
            let storedSessionIDSixthCharacterIndex = self.sessionID!.unicodeScalars.index(idKey.startIndex, offsetBy: 6)
            
            // First six characters of session ID received on login into Udacity API.
            let storedSessionIDFirstSixCharacters = self.sessionID![..<storedSessionIDSixthCharacterIndex]
            
            guard returnedSessionIDFirstSixCharacters == storedSessionIDFirstSixCharacters else {
                errorString = "Session ID received upon login (\(storedSessionIDFirstSixCharacters)) doesn't match session ID returned from the Udacity DELETE session API response (\(returnedSessionIDFirstSixCharacters))."
                sendErrorMessage(errorString, errorMessage)
                return
            }
            
            /*
             If no guard statements were triggered, we've successfully completed the call and
             can send the desired value(s) to completion handler.
             */
            completionHandlerDeleteUdacitySessionID(true, nil)
            
        }
        task.resume()
    }
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> APIClients {
        struct Singleton {
            static var sharedInstance = APIClients()
        }
        return Singleton.sharedInstance
    }
}
