//
//  TabBarViewController.swift
//  On the Map
//
//  Created by James Dellinger on 11/8/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation
import UIKit

class TabBarViewController: UITabBarController {
    
    // MARK: Properties
    
    // Will store the view of the view controller of the currently selected tab.
    // Necessary for knowing which view to pass to the method that displays
    // the activity indicator.
    var currentlySelectedViewControllerView: UIView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        if self.presentingViewController ==  {
//            print("TRIGGERED")
//            reloadMapTableViewControllers()
//        }
        reloadMapTableViewControllers()
    }
    
    // MARK: Logout
    
    // User tapped logout button.
    @IBAction func logout(_ sender: Any) {
        
        // The view of the view controller of the currently selected tab
        currentlySelectedViewControllerView = selectedViewController?.view
        // Display the activity indicator and gray tinted overlay.
        CustomActivityIndicatorController.sharedInstance.displayCustomActivityIndicator(currentlySelectedViewControllerView)
        
        // Log out of Udacity
        APIClients.sharedInstance().deleteUdacitySessionID() { (success, errorMessage) in
            performUIUpdatesOnMain {
                if success {
                    // If logout successfully completed, we can display the login view controller.
                    self.completeLogout()
                } else {
                    // If logout was not successful, display alert pop-up, which will contain
                    // the error message.
                    self.displayErrorAlert(title: "Logout Error", errorMessage: errorMessage)
                }
            }
        }
    }
    
    // MARK: Complete the logout
    
    private func completeLogout() {
        dismiss(animated: true, completion: {
            // Hide the activity spinner and gray tinted overlay once the login view appears.
            CustomActivityIndicatorController.sharedInstance.removeCustomActivityIndicator()
            })
    }
    
    // MARK: Refresh multiple student location data
    
    // User tapped refresh button. Re-download reload the student location data
    // for 100 students.
    @IBAction func refresh(_ sender: Any) {

        // The view of the view controller of the currently selected tab
        currentlySelectedViewControllerView = selectedViewController?.view
        // Display the activity indicator and gray tinted overlay.
        CustomActivityIndicatorController.sharedInstance.displayCustomActivityIndicator(currentlySelectedViewControllerView)
        
        // Download the latest 100 most recent student locations from Parse and save
        // to the studentEntries array located in the CreateStudentEntries class.
        APIClients.sharedInstance().getAndSaveStudentLocations() { (success, errorMessage) in
            performUIUpdatesOnMain {
                if success {
                    // If successful, the studentEntries array is up-to-date, and we can refresh
                    // the view to reflect this latest batch of student locations we just downloaded
                    // from Parse.
                    
                    // Refresh the views of each controller simultaneously whenever the refresh button is tapped.
                    self.reloadMapTableViewControllers()
                    
                    // And stop the activity indicator, remove the gray tinted overlay
                    CustomActivityIndicatorController.sharedInstance.removeCustomActivityIndicator()
                } else {
                    // If retrieval was not successful, display alert pop-up, which will contain
                    // the error message.
                    self.displayErrorAlert(title: "Refresh Error", errorMessage: errorMessage)
                }
            }
        }
    }
    
    // MARK: Refresh Map and Table View Controllers
    
    // If re-download and storage of latest top 100 student location entries is successful,
    // it's necessary to reload both view controllers that are accessible from this tab bar
    // view controller.
    func reloadMapTableViewControllers() {
        // The map view and table view controllers
        let controllers = self.viewControllers
        
        // Refresh the views of each controller simultaneously.
        for controller in controllers! {
            controller.loadView()
            controller.viewDidLoad()
        }
    }
    
    // MARK: Add or update individual student's (user's) location data
    
    // User tapped plus button. Check to see if student already has location stored on
    // the Parse server. If so, this location will be updated. If not, a brand new location
    // entry for the user will be created.
    @IBAction func addOrUpdateLocation(_ sender: Any) {
        
        // The view of the view controller of the currently selected tab
        currentlySelectedViewControllerView = selectedViewController?.view
        // Display the activity indicator and gray tinted overlay.
        CustomActivityIndicatorController.sharedInstance.displayCustomActivityIndicator(currentlySelectedViewControllerView)
        
        // Retrieve the location entry on Parse for the student, and if the entry exists,
        // also get the objectId for the entry.
        APIClients.sharedInstance().getStudentLocation() { (success, studentLocationRecordExists, errorMessage) in
            performUIUpdatesOnMain {
                if success {
                    // If successful, we at lest know whether or not a location record
                    // exists for the student
                    if studentLocationRecordExists! {
                        // If record exists, display a pop-up for user to confirm that they
                        // want to overwrite their previously saved location.
                        self.displayOverwriteAlert()
                    } else {
                        // If no record exists, first stop the activity indicator, and remove
                        // the gray tinted overlay.
                        CustomActivityIndicatorController.sharedInstance.removeCustomActivityIndicator()
                        // Then push to the information posting view controller so user can submit their
                        // location information to Parse for the first time.
                        self.displayInformationPostingScreen()
                    }
                } else {
                    // If unsuccessful, display error alert pop-up and the error message returned from
                    // the failed API call to Parse.
                    self.displayErrorAlert(title: "", errorMessage: errorMessage)
                }
            }
        }
    }
    
    // MARK: Display error alert pop-up
    
    func displayErrorAlert(title: String, errorMessage: String?) {
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"\(title)\" alert occured.")
        }))
        self.present(alert, animated: true, completion: {
            
            // Stop the activity indicator, remove the gray tinted overlay
            CustomActivityIndicatorController.sharedInstance.removeCustomActivityIndicator()
        })
    }
    
    // MARK: Display overwrite alert pop-up
    
    func displayOverwriteAlert() {
        let firstName = APIClients.sharedInstance().studentFirstName!
        let lastName = APIClients.sharedInstance().studentLastName!
        let alert = UIAlertController(title: "Update Saved Location", message: "\(firstName) \(lastName) has already saved a location. Would you like to overwrite it?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"\(self.title!)\" alert occured. (\"OK\")")
            // Push the location information posting view controller if user taps "OK"
            self.displayInformationPostingScreen()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: { _ in
            NSLog("The \"\(self.title!)\" alert occured. (\"Cancel\")")
        }))
        self.present(alert, animated: true, completion: {
            // Stop the activity indicator, remove the gray tinted overlay when alert pop-up is presented.
            CustomActivityIndicatorController.sharedInstance.removeCustomActivityIndicator()
        })
    }
    
    // MARK: Push location information posting view controller
    
    func displayInformationPostingScreen() {
        // Get the location Information Posting View Controller from the Storyboard
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "InformationPostingViewController") as! InformationPostingViewController
        // Push the controller.
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
