//
//  LoginViewController.swift
//  On the Map
//
//  Created by James Dellinger on 10/24/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    
    
    // The custom activity indicator based on the CustomActivityIndicatorView class.
    // Created the custom class to be able to use the custom "loading" asset included
    // with the assets for this project.
//    lazy private var customActivityIndicator : CustomActivityIndicatorView = {
//        let image : UIImage = UIImage(named: "loading")!
//        return CustomActivityIndicatorView(image: image)
//    }()
//
//    // The overlay that we will show underneath our activity indicator when it appears.
//    var overlay: UIView?
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Set the text field delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Set login button to disabled and button's alpha to 0.5 to reflect this in the UI.
        logInButton.isEnabled = false
        logInButton.alpha = 0.5
        
        // When text is entered in both email and password text fields, the login button will
        // become enabled and its alpha will change to reflect this in the UI.
        // Adding targets to both text fields here in order to detect this.
        emailTextField.addTarget(self, action: #selector(textFieldHasText), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldHasText), for: .editingChanged)
        
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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: LogInButton!    
    
    // MARK: Sign up
    
    /*
     User taken to Udacity's account creation web page in their device's
     Safari browser when 'Sign Up' button is tapped
    */
    @IBAction func signUpForUdacity(_ sender: Any) {
        let url = URL(string: "https://www.udacity.com/account/auth#!/signup")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // MARK: Login
    
    /*
     User has just tapped the 'LOG IN' button. First log in to Udacity and
     retrieve the user's basic info before calling the Parse API.
     */
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        let userName = emailTextField.text
        let passWord = passwordTextField.text
        
        // Dis-enable the text fields and login button once user taps login button.
        setUIEnabled(false)
        
        // Display the activity indicator and gray tinted overlay.
        CustomActivityIndicatorController.sharedInstance.displayCustomActivityIndicator(self.view)
        
        // Log in to Udacity, get user's first and last name, and download 100 student locations
        // to display on the map.
        APIClients.sharedInstance().loginToUdacityAndGetStudentLocations(userName: userName!, passWord: passWord!) { (success, errorMessage) in
            performUIUpdatesOnMain {
                if success {
                    self.completeLoginAndDisplayMap()
                } else {
                    self.displayErrorAlert(errorMessage: errorMessage)
                }
            }
        }
    }
    
    // MARK: Complete Login and Display Map
    
    private func completeLoginAndDisplayMap() {
        let controller = storyboard!.instantiateViewController(withIdentifier: "NavigationViewController")
        present(controller, animated: true, completion: {

            // Stop the activity indicator, remove the gray tinted overlay.
            CustomActivityIndicatorController.sharedInstance.removeCustomActivityIndicator()
            // Re-enable the text fields and login button.
            self.setUIEnabled(true)
            // Remove text from password text field so it will be empty if/when
            // user logs out.
            self.passwordTextField.text = ""
        })
    }
    
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Check if textfield has text entered
    
    // Defining the selector that will be used to determine whether both
    // text fields have had text entered, and the login button should be enabled.
    @objc func textFieldHasText(_ textField: UITextField) {
        // Making sure that text in text field doesn't begin with a space.
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
            else {
                self.logInButton.isEnabled = false
                logInButton.alpha = 0.5
                return
        }
        // Enable login button and set alpha to 1.0 if text fields both not empty.
        logInButton.isEnabled = true
        logInButton.alpha = 1.0
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
        resignIfFirstResponder(emailTextField)
        resignIfFirstResponder(passwordTextField)
    }
}

// MARK: - LoginViewController (Configure UI)

private extension LoginViewController {
    
    func setUIEnabled(_ enabled: Bool) {
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        logInButton.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            logInButton.alpha = 1.0
        } else {
            logInButton.alpha = 0.5
            
        }
    }
}

// MARK: - LoginViewController (Error Alert Pop-up)

private extension LoginViewController {
    
    func displayErrorAlert(errorMessage: String?) {
        let alert = UIAlertController(title: "Login Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"Login Error\" alert occured.")
        }))
        self.present(alert, animated: true, completion: {
            
            // Stop the activity indicator, remove the gray tinted overlay
            CustomActivityIndicatorController.sharedInstance.removeCustomActivityIndicator()
            // Re-enable the text fields and login button.
            self.setUIEnabled(true)
            
            // If password or email was incorrect (Udacity server returned 403 response), then
            // make sure text in password text field is also cleared out when user dismisses
            // the error alert.
            if errorMessage == "The email and or password you entered was incorrect." {
                self.passwordTextField.text = ""
            }
        })
    }

}

// MARK: - LoginViewController (Notifications)

private extension LoginViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

