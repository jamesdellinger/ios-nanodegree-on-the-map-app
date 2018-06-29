<img src="https://s3-us-west-1.amazonaws.com/udacity-content/degrees/catalog-images/nd003.png" alt="iOS Developer Nanodegree logo" height="70">

# iOS Developer Nanodegree: On the Map App

*Create an app with a responsive UI that reads and writes from RESTful networked APIs.*

![Platform iOS](https://img.shields.io/badge/nanodegree-iOS-blue.svg)

This repository contains the On the Map app project for the iOS Networking with Swift course in Udacity's iOS Nanodegree.

The On the Map app displays a map that shows information posted by other students. The map will contain pins that show the locations where other students have reported studying. By tapping on the pin, users can see a URL for something the student find interesting. The user will be able to add their own data by posting a string that can be geo-coded to a location and a URL.

My implementation contains the following unique user-friendly tweaks:

1. A more visually pleasing custom activity indicator spinner and gray-tinted overlay that appears underneath it. They are defined
    inside a custom class, and managed with a custom controller class. This makes it easy to call and dismiss the activity
    spinner during any network call, each with one line of code, from any view controller in the app:

    <img src="https://github.com/jamesdellinger/ios-nanodegree-on-the-map-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-11-13%20at%2020.56.28.png" height="400">

    <img src="https://github.com/jamesdellinger/ios-nanodegree-on-the-map-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-11-13%20at%2020.56.54.png" height="400">

    <img src="https://github.com/jamesdellinger/ios-nanodegree-on-the-map-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-11-13%20at%2020.57.44.png" height="400">

2. After user adds or updates their location information and taps 'FINISH,' the table and map views are automatically reloaded
    as the tab bar view controller containing them is popped back to. This is accomplished via a custom popToRootViewController()
    method defined in an extension to the UINavigationController class. Once the animation is completed, the custom method's
    completion handler calls the method that reloads the data and view for the map and table views.

    This means that the user doesn't have to tap the 'refresh' button in order to see the new location data they just entered get
    displayed. The new data will be right there waiting for them when the map/table view appears after they tap 'FINISH':

    <img src="https://github.com/jamesdellinger/ios-nanodegree-on-the-map-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-11-13%20at%2020.57.47.png" height="400">

### Project Grading and Evaluation

[Project Review](https://github.com/jamesdellinger/ios-nanodegree-on-the-map-app/blob/master/ios-nanodegree-on-the-map-app-review.pdf)

[Project Grading Rubric](https://github.com/jamesdellinger/ios-nanodegree-on-the-map-app/blob/master/on-the-map-app-specs-and-rubric.pdf)
