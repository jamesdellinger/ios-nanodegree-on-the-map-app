//
//  CreateStudentEntries.swift
//  On the Map
//
//  Created by James Dellinger on 11/3/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation

class CreateStudentEntries {
    
    // MARK: Properties
    
    // Shared data model for student location information entries
    static var studentEntries = [StudentInformation]()
    
    // MARK: Student entries from results
    
    /*
     Takes in an array of dictionaries. Each dictionary contains location and media URL data for an
     individual student. Use the StudentInformation struct to return an array of entries for
     each of the students, containing the information (name, latitude, longitude, etc.) that
     we will need to properly display student info in the app's screens.
     */
    static func studentEntriesFromResults(_ results: [[String:AnyObject]]) {
        
        /*
         Make sure studentEntries array is empty before appending each Student Information
         entry onto it from the results of the most recent call to the Parse student locations API.
         */
        studentEntries = []
        
        /*
         Iterate through an array of dictionaries. Each dictionary contains a student's
         information entry.
         */
        for result in results {
            studentEntries.append(StudentInformation(dictionary: result))
        }
    }
    
}
