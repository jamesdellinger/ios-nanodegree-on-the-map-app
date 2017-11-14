//
//  TableViewController.swift
//  On the Map
//
//  Created by James Dellinger on 11/7/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Table View outlet
    @IBOutlet var tableView: UITableView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Since we call this class' viewDidLoad method from the TabBarViewController everytime the refresh
        // button is tapped, include this call to reloadData() here to ensure that the table view is also
        // refreshed to display the latest student locations data.
        tableView.reloadData()
    }
    
    // MARK: Table methods
    
    // Get the number of rows (student locations) that must appear in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The number of student locations that are stored in the student entries array
        // in the CreateStudentEntries class.
        return CreateStudentEntries.studentEntries.count
    }
    
    // Display each row with the appropriate student location info inside it.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Retrieve the location to be displayed in the row
        let studentLocation: StudentInformation = CreateStudentEntries.studentEntries[(indexPath as NSIndexPath).row]
        
        // Dequeue each row and set the title and detail and text inside it
        let row = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell")!
        // Set the title text of the row to the student's first and last name.
        // Some entries may not have first or last name, so we need to unwrap carefully.
        
        var displayedFirstName: String = ""
        var displayedLastName: String = ""
        
        if let firstName = studentLocation.firstName {
            displayedFirstName = firstName
        } else {
            displayedFirstName = "[First Name Empty]"
        }
        
        if let lastName = studentLocation.lastName {
            displayedLastName = lastName
        } else {
            displayedLastName = "[Last Name Empty]"
        }
        
        row.textLabel?.text = "\(displayedFirstName) \(displayedLastName)"
        
        // And set the detail text in the row to the student's personal URL, also
        // carefully unwrapping.
        if let mediaURL = studentLocation.mediaURL {
            row.detailTextLabel?.text = mediaURL
        } else {
            row.detailTextLabel?.text = "[Personal URL Empty]"
        }
        
        return row
    }
    
    // Open the student's personal URL in Safari when user taps on the student's row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let linkToOpen = CreateStudentEntries.studentEntries[(indexPath as NSIndexPath).row].mediaURL, let url = URL(string: linkToOpen) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
