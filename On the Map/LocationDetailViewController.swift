//
//  LocationDetailViewController.swift
//  On the Map
//
//  Created by James Dellinger on 11/9/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocationDetailViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties
    
    var urlString: String?
    var locationString: String?
    var location: CLLocation?
    var coordinates: CLLocationCoordinate2D?
    var latitude: Double?
    var longitude: Double?
    
    // MARK: Mapview IBOutlet
    
    /* The map. The view controller is set up as the map view's delegate. */
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Here we create the annotation and set its coordinate property
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.coordinates!
        
        // Reverse geocode the coordinates so that the resultant address string can
        // be displayed as the title of the map pin annotation for the location the user had entered.
        reverseGeoCode(location!) { (locationAddress) in
            
            // Set the title of the annotation to the address that was
            // reverse geo coded. (Returns "No Matching Addresses Found" if
            // reverse geocode lookup was unsuccessful.)
            annotation.title = locationAddress
            
            // When the array is complete, we add the annotation to the map.
            self.mapView.addAnnotation(annotation)
            
            // Make sure the map is centered on our one annotation.
            self.mapView.centerCoordinate = annotation.coordinate
            
            // And make sure the map is zoomed in fairly close to the location pin.
            self.mapView.camera.altitude = 5000.0
        }
    }
    
    // MARK: User Finish Adding/Updating Location
    
    /*
     Four things will happen when the user taps the Finish button:
     1. Address either be added (POST) or updated (PUT) on the Parse server, depending
        on whether or not user uploaded an address previously.
     2. The data in the studentEntries array of student locations in the CreateStudentEntries
        class will be updated to reflect the user's address update.
     3. The views of both (Map View and Table View) view controllers accessible from the
        UITabBarController (TabBarViewController) will be reloaded to ensure location that user
        just added is displayed.
     4. Navigation controller will pop back to the TabBarViewController.
     */
    @IBAction func finishButtonTapped(_ sender: Any) {
        
        // Display the activity indicator and gray tinted overlay.
        CustomActivityIndicatorController.sharedInstance.displayCustomActivityIndicator(self.view)
        
        // This method will either add (POST) a student location or update (PUT) a student
        // location on Parse depending on whether or not student has ever uploaded a location
        // entry on Parse before (this status is tracked inside the APIClients class.
        APIClients.sharedInstance().addOrUpdateStudentLocation(mapString: locationString!, mediaURL: urlString!, latitude: latitude!, longitude: longitude!) { (success, errorMessage) in
            performUIUpdatesOnMain {
                if success {
                    // If successful, the student has been able to add/update their location
                    // on Parse. Now we need to refresh data for all student locations to ensure
                    // the locations displayed in the app include the one the student just added/udated.
                    APIClients.sharedInstance().getAndSaveStudentLocations() { (sucess, errorMessage) in
                        if success {
                            // First, stop the activity indicator, remove the gray tinted overlay
                            CustomActivityIndicatorController.sharedInstance.removeCustomActivityIndicator()
                            
                            // And then pop back to the tab bar view controller.
                            performUIUpdatesOnMain {
                                self.returnToTabView()
                            }
                        } else {
                            self.displayErrorAlert(errorMessage: errorMessage)
                        }
                    }
                } else {
                    self.displayErrorAlert(errorMessage: errorMessage)
                }
            }
        }
    }
    
    // Pops back to the tab bar view once API calls to add/update location, and then reloads
    // all the student locations once the pop is completed.
    func returnToTabView() {
        // Popping to the root view controller will take us to the tab bar view controller. Am
        // using the custom popToRootViewController method defined below in an extension to
        // UINavigationController. This custom definition can accept a completion method, which we
        // use here to ensure that table and map views are freshly reloaded once we arrive back.
        // They will display the latest location info entered by the user in this screen.
        navigationController?.popToRootViewController(animated: true, completion: {
            // Variable representing our tab bar view controller
            let tabBarController = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
            
            // Calling the reloadMapTableViewControllers method inside the tab bar
            // view controller. Doing this in the completion here ensures that when popping
            // back after tapping the FINISH button, user will see table or map view already
            // updated to reflect the new location information that they just sent to Parse in this screen!
            tabBarController.reloadMapTableViewControllers()
        })
    }
    
    // Display error alert if Parse API call to add or update location fails.
    func displayErrorAlert(errorMessage: String?) {
        let alert = UIAlertController(title: "Save Location Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"Save Location Error\" alert occured.")
        }))
        self.present(alert, animated: true, completion: {
            
            // Stop the activity indicator, remove the gray tinted overlay
            CustomActivityIndicatorController.sharedInstance.removeCustomActivityIndicator()
        })
    }
    
    // Reverse geocoding a CLLocation object so that we can display a string representing its
    // compact address when user taps on the pin displayed in this controller's map view.
    func reverseGeoCode(_ location: CLLocation, completionHandlerForReverseGeoCode: @escaping (String) -> Void ) {
        
        // String that will contain the reverse geocoded address.
        var locationAddress: String = ""
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil {
                if let placemarks = placemarks, let placemark = placemarks.first, let locationAddress = placemark.compactAddress {
                    completionHandlerForReverseGeoCode(locationAddress)
                } else {
                    locationAddress = "No Matching Addresses Found"
                    completionHandlerForReverseGeoCode(locationAddress)
                }
            } else {
                locationAddress = "No Matching Addresses Found"
                completionHandlerForReverseGeoCode(locationAddress)
            }
        }
    }
}

// MARK: - MKMapViewDelegate

/*
 Custom pin view for the mapview in this view controller. Only a simple address
 string will be displayed if user taps on pin, so no "right callout accessory view"
 is necessary.
 */
extension LocationDetailViewController {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}

// MARK: - CLPlacemark compact address

/* Allows the display of a compact address string for any CLPlacemark object. */
extension CLPlacemark {
    
    var compactAddress: String? {
        if let city = locality {
            var result = city
            
            if let administrativeArea = administrativeArea {
                result += ", \(administrativeArea)"
            }
            
            if let postalCode = postalCode {
                result += " \(postalCode)"
            }
            
            if let country = country {
                result += ", \(country)"
            }
            
            return result
        }
        return nil
    }
}

// MARK: UINavigationController custom popToRootViewController method

extension UINavigationController {
    
    private func doAfterAnimatingTransition(animated: Bool, completion: @escaping (() -> Void)) {
        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil, completion: { _ in
                completion()
            })
        } else {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func popToRootViewController(animated: Bool, completion: @escaping (() -> Void)) {
        popToRootViewController(animated: animated)
        doAfterAnimatingTransition(animated: animated, completion: completion)
    }
}
