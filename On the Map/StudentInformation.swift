//
//  StudentInformation.swift
//  On the Map
//
//  Created by James Dellinger on 11/3/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation
import UIKit

/*
 Defining the kind of information we will store for a student. In order to
 fulfill the app's requirements, we need to know a students first name, last name,
 media URL, latitude, and longitude.
 */
struct StudentInformation {
    
    // MARK: Properties
    
    let firstName: String?
    let lastName: String?
    let mediaURL: String?
    let latitude: Double?
    let longitude: Double?
    
    // MARK: Initializers
    
    init(dictionary: [String:AnyObject]) {
        firstName = dictionary["firstName"] as? String
        lastName = dictionary["lastName"] as? String
        mediaURL = dictionary["mediaURL"] as? String
        latitude = dictionary["latitude"] as? Double
        longitude = dictionary["longitude"] as? Double
    }
}
