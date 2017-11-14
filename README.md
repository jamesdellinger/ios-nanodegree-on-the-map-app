<img src="https://s3-us-west-1.amazonaws.com/udacity-content/degrees/catalog-images/nd003.png" alt="iOS Developer Nanodegree logo" height="70" >

# On the Map App

![Platform iOS](https://img.shields.io/badge/nanodegree-iOS-blue.svg)

This repository contains the On the Map app project for the iOS Networking with Swift course in Udacity's iOS Nanodegree.

With the following user-friendly tweaks:

1. First screen user sees upon app opening is meme editor screen. Like camera in Snapchat, users would open this app to
    create and send out a funny meme that just popped into their mind. Boom. Also, imagine how bad it would be opening up 
    to an empty collection view on first-time-ever app launch. 
    
    No one is gonna open this app to enjoy its 
    table and collection view meme browsing experience. (Though, it is possible to browse through the library of old memes 
    from long ago, should one desire.):

    <img src="https://github.com/jamesdellinger/ios-nanodegree-meme-me-version-2-app/blob/master/Screenshots/Screen%20Shot%202017-10-22%20at%209.35.29%20PM.png" height="400">

2. Collection and table views uniformly display the most ideal crops of meme images. No matter if the meme image's orientation
    is landscape or portrait, thumbnail crop includes all, or at least the bulk of, the top and bottom white meme text:

    <img src="https://github.com/jamesdellinger/ios-nanodegree-meme-me-version-2-app/blob/master/Screenshots/Screen%20Shot%202017-10-22%20at%209.27.32%20PM.png" height="300">

    <img src="https://github.com/jamesdellinger/ios-nanodegree-meme-me-version-2-app/blob/master/Screenshots/Screen%20Shot%202017-10-22%20at%209.27.46%20PM.png" height="300">

3. When a picture is loaded into the meme editor, top and bottom meme text fields always automatically readjust to top of
    meme image, no matter if image is landscape or portrait. User doesn't have to rotate phone to landscape to get the text
    fields to the top and bottom of a landscape image (though app does support rotation, should user desire to do so). (But really, as of 2017, who even rotates their phones to landscape?):
    
    <img src="https://github.com/jamesdellinger/ios-nanodegree-meme-me-version-2-app/blob/master/Screenshots/Screen%20Shot%202017-10-22%20at%209.35.58%20PM.png" height="400">

    <img src="https://github.com/jamesdellinger/ios-nanodegree-meme-me-version-2-app/blob/master/Screenshots/Screen%20Shot%202017-10-22%20at%209.49.40%20PM.png" height="400">
    
4. Top and Bottom text fields auto-shrink size of text down to a minimum size. This keeps really long meme labels from
    overrunning the width of the meme image, no matter how narrow or wide it is. After the minimum text size is reached, only
    then does the label get truncated:
    
    <img src="https://github.com/jamesdellinger/ios-nanodegree-meme-me-version-2-app/blob/master/Screenshots/Screen%20Shot%202017-10-22%20at%2010.23.05%20PM.png" height="400">
    
    <img src="https://github.com/jamesdellinger/ios-nanodegree-meme-me-version-2-app/blob/master/Screenshots/Screen%20Shot%202017-10-22%20at%2010.24.31%20PM.png" height="400">
    
5. Finally, when saving a meme, app auto-crops out app chrome, borders, empty space, and only saves the actual meme
   image, itself:
    
    <img src="https://github.com/jamesdellinger/ios-nanodegree-meme-me-version-2-app/blob/master/Screenshots/Screen%20Shot%202017-10-22%20at%209.36.19%20PM.png" height="400">
