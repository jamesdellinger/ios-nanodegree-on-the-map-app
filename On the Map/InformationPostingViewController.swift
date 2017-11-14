//
//  InformationPostingViewController.swift
//  On the Map
//
//  Created by James Dellinger on 11/9/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class InformationPostingViewController: UIViewController {
    
    //MARK: Properties
    
    // The location that the user enteres into the location text field
    var locationString: String?
    
    // The location stored as a CLLocation (received when doing a forward
    // geocode lookup on the location text string the user entered).
    var location: CLLocation?
    
    // The personal url that the user entered.
    var urlString: String?
    
    // The set of coordinates that the user's location was converted into.
    var coordinates: CLLocationCoordinate2D?
    
    // Variables to hold the latitude, longitude coordinates received upon converting
    // location user entered into location text field.
    var latitude: Double?
    var longitude: Double?
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Set the text field delegates
        locationTextField.delegate = self
        urlTextField.delegate = self
        
        // Set login button to disabled and button's alpha to 0.5 to reflect this in the UI.
        findLocationButton.isEnabled = false
        findLocationButton.alpha = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        resignIfFirstResponder(locationTextField)
        resignIfFirstResponder(urlTextField)
        
        // When text is entered in both location and url text fields, the find location button will
        // become enabled and its alpha will change to reflect this in the UI.
        // Adding targets to both text fields here in order to detect this.
        locationTextField.addTarget(self, action: #selector(textFieldHasText), for: .editingChanged)
        urlTextField.addTarget(self, action: #selector(textFieldHasText), for: .editingChanged)
        
        // Subscribe to notifications to know when to display keyboard and when to adjust screen position.
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var findLocationButton: LogInButton!
    
    
    // MARK: User taps cancel button
    
    /* Pop back to the tab bar view controller when user taps CANCEL. */
    @IBAction func cancelAddLocation(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: User taps Find Location button
    
    
    @IBAction func findLocation(_ sender: Any) {
        
        // Display the activity indicator and gray tinted overlay.
        CustomActivityIndicatorController.sharedInstance.displayCustomActivityIndicator(self.view)
        
        /* GUARD: Make sure that url text field text begins with "http://" */
        guard
            // Index of seventh character of text entered in url text field.
            let urlTextSeventhCharacterIndex = self.urlTextField.text?.unicodeScalars.index((self.urlTextField.text?.startIndex)!, offsetBy: 7),
            // First seven characters of text in url text field.
            let urlTextFirstSevenCharacters = self.urlTextField.text?[..<urlTextSeventhCharacterIndex],
            urlTextFirstSevenCharacters == "http://" else {
                return
        }
        
        // Store the personal url string that the user entered.
        self.urlString = self.urlTextField.text!
        
        // Take the text that user entered inside the location text field.
        let enteredLocationText = self.locationTextField.text!
        // And try to convert to a set of latitude, longitude coordinates.
        self.getCoordinate(addressString: enteredLocationText) { (success, location, coordinates, error) in
            performUIUpdatesOnMain {
                if success{
                    // If successful, geocoding worked and we have a set of coordinates derived from
                    // the adddress that the user typed in. We can also store the location text string, coordinate
                    // pair, as wellthe  latitude and longitude coordinates that the location was converted into. We
                    // will need these in order to store the address on Parse.
                    self.locationString = enteredLocationText
                    self.location = location
                    self.coordinates = coordinates
                    self.latitude = coordinates.latitude
                    self.longitude = coordinates.longitude
                    
                    // Stop the activity indicator, remove the gray tinted overlay
                    CustomActivityIndicatorController.sharedInstance.removeCustomActivityIndicator()
                    
                    // Then, hide the keyboard and  push the Location Detail View Controller, which
                    // will display the user's location inside the map view contained within the controller.
                    self.hideKeyboardBeforePushing() { (success) in
                        if success {
                            performUIUpdatesOnMain {
                                self.displayLocationDetailScreen()
                            }
                        }
                    }
                }
                else {
                    // Display error pop-up if geocoding fails.
                    self.displayErrorAlert(errorMessage: "Unable to pinpoint the location you entered. Try entering a city and state (or country) like this: \"Mountain View, California.\"")
                }
            }
        }
    }
    
    // MARK: Hide keyboard before pushing view controller
    
    func hideKeyboardBeforePushing(completionHandler: @escaping (_ success: Bool) -> Void) {
        resignIfFirstResponder(locationTextField)
        resignIfFirstResponder(urlTextField)
        keyboardOnScreen = false
        if keyboardOnScreen == false {
            completionHandler(true)
        } else {
            completionHandler(false)
        }
    }
    
    // MARK: Push location detail posting view controller
    
    func displayLocationDetailScreen() {
        // Get the Location Detail View Controller from the Storyboard
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "LocationDetailViewController") as! LocationDetailViewController
        
        // Update the locationString, coordinates, latitude, and longitude properties in the Location Detail View
        // Controller. This will allow the location to be displayed inside that controller's mapview, as well as
        // the necessary parameters to be passed to the PUT or POST call that will made to the Parse server to update
        // (or add for the first time) the user's location.
        controller.urlString = urlString!
        controller.locationString = locationString!
        controller.location = location!
        controller.coordinates = coordinates!
        controller.latitude = latitude!
        controller.longitude = longitude!
        
        // Push the controller.
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - InformationPostingViewController: Get location coordinates

extension InformationPostingViewController {
    
    // Converts the address string user entered into the location text field into
    // a set of latitude, longitude coordinates.
    func getCoordinate(addressString: String, completionHandler: @escaping (Bool, CLLocation?, CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    // Conversion to coordinates was successful. Return the coordinates inside the
                    // completion handler.
                    completionHandler(true, location, location.coordinate, nil)
                    return
                }
            }
            // Conversion to coordinates failed. Return the error message inside the completion handler.
            completionHandler(false, nil, kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
}

// MARK: - InformationPostingViewController: UITextFieldDelegate

extension InformationPostingViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    // Ensure that "http://" is automatically inserted into
    // the URL text field if user hadn't already entered it in.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == urlTextField {
            if !(textField.text?.contains("http://"))! {
                textField.text = "http://"
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Check if textfield has text entered
    
    // Defining the selector that will be used to determine whether both
    // text fields have had text entered, and the find location button should be enabled.
    @objc func textFieldHasText(_ textField: UITextField) {
        // Making sure that text in text field doesn't begin with a space.
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let location = locationTextField.text, !location.isEmpty,
            let url = urlTextField.text, !url.isEmpty
            else {
                self.findLocationButton.isEnabled = false
                findLocationButton.alpha = 0.5
                return
        }
        // Enable find location button and set alpha to 1.0 if text fields both not empty.
        findLocationButton.isEnabled = true
        findLocationButton.alpha = 1.0
    }
    
    // MARK: Show/Hide Keyboard
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)/2
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)/2
        }
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(locationTextField)
        resignIfFirstResponder(urlTextField)
    }
}

// MARK: - InformationPostingViewController (Configure UI)

private extension InformationPostingViewController {
    
    func setUIEnabled(_ enabled: Bool) {
        locationTextField.isEnabled = enabled
        urlTextField.isEnabled = enabled
        findLocationButton.isEnabled = enabled
        
        // adjust find location button alpha
        if enabled {
            findLocationButton.alpha = 1.0
        } else {
            findLocationButton.alpha = 0.5
        }
    }
}

// MARK: - InformationPostingViewController (Error Alert Pop-up)

private extension InformationPostingViewController {
    
    func displayErrorAlert(errorMessage: String?) {
        let alert = UIAlertController(title: "Find Location Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"Find Location Error\" alert occured.")
        }))
        self.present(alert, animated: true, completion: {
            
            // Stop the activity indicator, remove the gray tinted overlay
            CustomActivityIndicatorController.sharedInstance.removeCustomActivityIndicator()
            // Re-enable the text fields and login button.
            self.setUIEnabled(true)
        })
    }
    
}

// MARK: - InformationPostingViewController (Notifications)

private extension InformationPostingViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
