//
//  CustomActivityIndicatorController.swift
//  On the Map
//
//  Created by James Dellinger on 11/7/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation
import UIKit

/*
 An class that contains functions to display, and also disappear, the custom activity
 indicator from whichever view the functions are called from.
 
 Adds a UI overlay (gray tinted) that appears over the view and under the
 activity indicator. This makes the indicator more visible, and helps indicate to the user
 that they cannot interact with the view until the activity indicator disappears.
 */

class CustomActivityIndicatorController: NSObject {
    
    // Allows re-use of this class' functions from any other class.
    static let sharedInstance = CustomActivityIndicatorController()
    
    // The custom activity indicator based on the CustomActivityIndicatorView class.
    // Created the custom class to be able to use the custom "loading.png" asset included
    // with the assets for this project.
    private var customActivityIndicator: CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "loading")!
        return CustomActivityIndicatorView(image: image)
    }()
    
    // The overlay that we will show underneath our activity indicator when it appears.
    private var overlay: UIView?
    
    // Display the activity indicator and gray tinted overlay. When this method is called from
    // the various view controllers, the UIView of the view controller is what will be passed
    // as a parameter.
    func displayCustomActivityIndicator(_ uiView: UIView?) {
        
        // The view over which the custom activity indicator and gray tinted overlay will
        // be displayed.
        let holdingView = uiView!
        
        performUIUpdatesOnMain {
            /*
             Make sure that the activity indicator and overlay are positioned and displayed
             properly within the view.
            */
            
            // Ensure that the overlay covers the entire screen, and that it tints the screen gray.
            let screenSize = UIScreen.main.nativeBounds
            self.overlay = UIView(frame: screenSize)
            self.overlay?.alpha = 0.5
            self.overlay?.backgroundColor = UIColor.black
            
            // If this print statement is not included, the custom activity indicator spinner will
            // appear abnormally low beginning with the second refresh, when the table view is refreshed
            // multiple times in a row. I'm open to a better way to prevent this, but could not
            // find a different way to prevent the behavior, either in storyboard or programmatically.
            print(holdingView.layoutMarginsGuide)

            /*
             Ensure that the custom activity indicator displays in the center of the screen:
             Final two view controllers, at run-time, have a min Y value that's greater than zero.
             This is causing the spinner to not be centered when it appears as a subview in those view
             controllers. The if statement below checks for this case, and compensates in order to keep
             the custom activity indicator properly centered.
             */
            if holdingView.frame.minY > 0 {
                self.customActivityIndicator.center.x = holdingView.center.x
                self.customActivityIndicator.center.y = holdingView.center.y - holdingView.frame.minY
            } else {
                self.customActivityIndicator.center = holdingView.center
            }
            
            // Add the subview for the gray tinted overlay that will appear underneath the custom activity indicator.
            holdingView.addSubview(self.overlay!)
            
            // Add a subview for our custom activity indicator, so that it can spin once
            // the login button has been tapped.
            holdingView.addSubview(self.customActivityIndicator)
            self.customActivityIndicator.startAnimating()
        }
    }
    
    // Hide the activity indicator and gray tinted overlay.
    func removeCustomActivityIndicator() {
        performUIUpdatesOnMain {
            self.customActivityIndicator.stopAnimating()
            self.overlay?.removeFromSuperview()
        }
    }
}
