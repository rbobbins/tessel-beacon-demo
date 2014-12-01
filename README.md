tessel-beacon-demo
==================

This application demonstrates how to use a Tessel + BLE module as an iBeacon. 

Features
========

  - **Tessel Beacon Monitoring** : User can decide whether or not monitor for boundary changes when entering/exiting the region of the Tessel. If the user decides to monitor for boundary changes, they'll get notified each time they *enter* the region of a Tessel. This happens regardless of whether the app is currently in the foreground. 

  Also, the app will ping [http://tessel-beacon-server.herokuapp.com](http://tessel-beacon-server.herokuapp.com) each time it enters the region of a Tessel. Currently, the app does not include notifications when exiting the region of a Tessel. 
  - **Tessel Beacon Ranging** : When the app is in the foreground, user can range the Tessel Beacon. While ranging is enabled, the app will display the proximity to the Tessel Beacon in realtime. scans for Tessel beacon. 
  
Prerequisites
============

  - You must be registered as an Apple Developer. This is a requirement for running the app on a physical device. (You don't need to be an Apple developer to run the app in the simulator; however, bluetooth does not work in the simulator)
  - You must have the Tessel BLE module. The application will guide you through setting it up correctly.


Getting Started
===============
1. Fork/clone this repo.
1. If this is your first time building an iOS app, you'll probably have to install Cocoapods. Cocoapods is like NPM for iOS apps. To install: `sudo gem install cocoapods`. Yes, Cocoapods is a Ruby gem. If you don't have Ruby installed, you'll have to do that first. Dependencies are just turtles all the way down.
1. `cd` to your local clone of the repo, and run `pod install`. 
1. To run the app, build the TesselBeaconDemo target to an *iOS device*. As mentioned above, you've got to be a registered Apple Developer to do this.


Running Tests
=============
1. To run the specs (this app is well-tested), build the Specs target.

# About this application
## Philosophies
A lot of demo iOS apps dump all the logic into view controllers. _Look! It's only 1 file_. I don't love this - it makes demo apps a very different from "real" applications, and it makes them harder to test.

I believe demo apps are just lightweight versions of production apps, and they should be written up to production standards. If anything, demo code should be *better* than production code. Demo apps are frequently used by people trying to learn iOS development, and it doesn't do anyone any good if they're led to believe that dumping everything into a view controller is a good idea. It's never a good idea. 

That being said, this app uses view controllers for displaying text and handling gestures. Everything beyond that is handled by other objects.

## A quick outline of objects used
This application has lots of tests, and those tests outline the behavior of each object in great detail. I believe that tests should serve as documentation. However, that's not really what people expect from a Readme. So, here's a quick 1-line description of each object in the app


- *MainViewController*: Allows user to toggle monitoring and ranging on/off. Gets notified of events from the TesselBeaconManager, and logs those events accordingly.
- *RegistrationViewController*: Explains what it means to "register" a Tessel, and allows the user to opt-in to doing so.
- *TesselInformationViewController*: Shows the user their registered Tessel UUID, and allows them to email a code snippet to themself, or copy/paste the Tessel UUID to the clipboard.
- *TesselBeaconManager*: Wraps a `CLLocationManager` to provide Tessel-specific functionality - i.e, it only handles beacon related location events - not GPS-based location events
- *TesselRegistrationRepository*: Registers the Tessel with the remote server, and maintains knowledge of the registered Tessel UUID.
- *TesselCheckinRepository*: Posts checkins to the remote server. Could easily be extended to also fetch old checkins from the server.


## Technologies used
- *Cedar*: Cedar as an iOS testing framework; at time of writing, this app has 76 tests.
- *KSPromise*: KSPromise is a lightweight promise library for Objective-C. It's based on the JavaScript Promises spec *[what's this called?]*. It's not (yet) a popular pattern in iOS development, but I like to use it - it makes writing beahvioral tests much easier.
- *AFNetworking*: AFNetworking is a highly popular networking library for iOS. It's almost definitely overkill for this application - this app only makes 2 network requests. However, this application is open-source. If you decide to fork it and use it as a seed for your own application, you'll probably want to make more network requests. AFNetworking is great for that. 


