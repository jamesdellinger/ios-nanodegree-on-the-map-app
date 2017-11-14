//
//  MapViewController.swift
//  On the Map
//
//  Created by James Dellinger on 11/3/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Mapview IBOutlet
    
    /*
     The map. The view controller is set up as the map view's delegate.
     */
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // The "locations" array is an array of dictionary objects that are similar to the JSON
        // data that you can download from parse.
        let studentLocations = CreateStudentEntries.studentEntries
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        for location in studentLocations {
            
            if let latitude = location.latitude, let longitude = location.longitude, let firstName = location.firstName, let lastName = location.lastName, let mediaURL = location.mediaURL {
                
                // Notice that the float values are being used to create CLLocationDegree values.
                // This is a version of the Double type.
                let latitudeCoordinate = CLLocationDegrees(latitude)
                let longitudeCoordinate = CLLocationDegrees(longitude)
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: latitudeCoordinate, longitude: longitudeCoordinate)
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(firstName) \(lastName)"
                annotation.subtitle = mediaURL
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
            }
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
    }
    
    // MARK: - MKMapViewDelegate
    
    /*
     Here we create a view with a "right callout accessory view". This is what is displayed when
     a user taps on a pin on the map.
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }

        return pinView
    }
    
    /*
     This delegate method is implemented to open the system browser to the URL specified in the
     annotationViews subtitle property when the user taps on the annotationView.
     */
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let linkToOpen = view.annotation?.subtitle!, let url = URL(string: linkToOpen) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
}
