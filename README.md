tessel-beacon-demo
==================

This application demonstrates how to build an iOS app that uses a Tessel as an iBeacon, and then posts to an HTTP server each time your iDevice enters the range of a Tessel Beacon.

Table of Contents
=================

* iBeacons: A Quick Overview
* Tessel iBeacon Demo App
	* Features
	* Prerequisites
	* Getting Started
	* Running Tests
	* Application Design
		* Philosophies
		* Important Objects
		* 3rd Party Dependencies
* App in Action
	* Video
	* Screenshots

iBeacons: A Quick Overview
==========================

iBeacon is a relatively new technology (albeit, slightly older than Tessel) that was introduced by Apple in iOS 7. It takes advantage of iOS devices' built-in BLE hardware by allowing iDevices to determine their relative proximity to other BLE devices. Those "other" BLE devices are the iBeacons!

Why use an iBeacon? Apple's example use case is a retail store. Companies might want iBeacons within their stores in order to notify customers when there are relevant deals nearby, or to track the foot traffic within certain departments. 

Any BLE device can act as an iBeacon - including your Tessel! (_To be an "official" iBeacon, you must meet Apple's licensing requirements. This app does not meet Apple's licensing requirements; it's intended to be a tool for developers to learn and to prototype._) Anyway, to function as an iBeacon, a BLE device must advertise:

* 16 byte UUID value (required)
* 2 byte "major" value (optional)
* 2 byte "minor" value (optional)


Apple has a *fantastic* guide to getting started with iBeacons. It talks about the technology, its limitations and advantages, and the Apple API's around iBeacons. That guide is [here](https://developer.apple.com/ibeacon/Getting-Started-with-iBeacon.pdf).

Tessel iBeacon Demo App
=======================

## Features

  - **Tessel Beacon Monitoring** : User can decide whether or not monitor for boundary changes when entering/exiting the region of the Tessel. If the user decides to monitor for boundary changes, they'll get notified each time they *enter* the region of a Tessel, regardless of whether the app is currently running in the foreground. As of right now, notifications are on entry only - not on exiting a region.
  Also, the app will ping [http://tessel-beacon-server.herokuapp.com](http://tessel-beacon-server.herokuapp.com) each time it enters the region of a Tessel. 

  - **Tessel Beacon Ranging** : When the app is in the foreground, user can range the Tessel Beacon. While ranging is enabled, the app will display the proximity to the Tessel Beacon in realtime. scans for Tessel beacon. 
  
## Prerequisites

  - You must be registered as an Apple Developer. This is a requirement for running the app on a physical device. (You don't need to be an Apple developer to run the app in the simulator; however, bluetooth does not work in the simulator)
  - You should have the Tessel BLE module. The application will guide you through setting it up correctly.
  - You should have an iOS device with BLE capabilities. Any device listed here [http://en.wikipedia.org/wiki/List_of_iOS_devices#Features](http://en.wikipedia.org/wiki/List_of_iOS_devices#Features) as having "Bluetooth 4.0" will support BLE.


## Getting Started
1. Fork/clone this repo.
1. If this is your first time building an iOS app, you'll probably have to install Cocoapods. Cocoapods is like NPM for iOS apps. To install: `sudo gem install cocoapods`. Yes, Cocoapods is a Ruby gem. If you don't have Ruby installed, you'll have to do that first. Dependencies are just turtles all the way down.
1. `cd` to your local clone of the repo, and run `pod install`. 
1. To run the app, build the TesselBeaconDemo target to an *iOS device*. As mentioned above, you've got to be a registered Apple Developer to do this.


## Running Tests

To run the specs (this app is well-tested), build the Specs target.

## Application Design

### Philosophies
A lot of demo iOS apps dump all the logic into view controllers. _Look! It's only 1 file_. I don't love this - it makes demo apps a very different from "real" applications, and it makes them harder to test.

I believe demo apps are just lightweight versions of production apps, and they should be written up to production standards. If anything, demo code should be *better* than production code. Demo apps are frequently used by people trying to learn iOS development, and it doesn't do anyone any good if they're led to believe that dumping everything into a view controller is a good idea. It's never a good idea. 

That being said, this app uses view controllers for displaying text and handling gestures. Everything beyond that is handled by other objects.

### Important Objects
This application has lots of tests, and those tests outline the behavior of each object in great detail. I believe that tests should serve as documentation. However, that's not really what people expect from a Readme. So, here's a quick 1-line description of each object in the app

- *MainViewController*: Allows user to toggle monitoring and ranging on/off. Gets notified of events from the TesselBeaconManager, and logs those events accordingly.
- *RegistrationViewController*: Explains what it means to "register" a Tessel, and allows the user to opt-in to doing so.
- *TesselInformationViewController*: Shows the user their registered Tessel UUID, and allows them to email a code snippet to themself, or copy/paste the Tessel UUID to the clipboard.
- *TesselBeaconManager*: Wraps a `CLLocationManager` to provide Tessel-specific functionality - i.e, it only handles beacon related location events - not GPS-based location events
- *TesselRegistrationRepository*: Registers the Tessel with the remote server, and maintains knowledge of the registered Tessel UUID.
- *TesselCheckinRepository*: Posts checkins to the remote server. Could easily be extended to also fetch old checkins from the server.


### 3rd Party Dependencies
- *Cedar*: Cedar as an iOS testing framework; at time of writing, this app has 76 tests.
- *KSPromise*: KSPromise is a lightweight promise library for Objective-C. It's based on the JavaScript Promises spec *[what's this called?]*. It's not (yet) a popular pattern in iOS development, but I like to use it - it makes writing beahvioral tests much easier.
- *AFNetworking*: AFNetworking is a highly popular networking library for iOS. It's almost definitely overkill for this application - this app only makes 2 network requests. However, this application is open-source. If you decide to fork it and use it as a seed for your own application, you'll probably want to make more network requests. AFNetworking is great for that. 

## App in Action
### Video demo

[![ScreenShot](https://raw.github.com/GabLeRoux/WebMole/master/ressources/WebMole_Youtube_Video.png)](http://player.vimeo.com/video/113357904)

### Screenshots
Here are some screenshots that highlight features of the demo app.
<figure style="border: 1px solid #aaa; padding:5px; width: 70%">
<img src="https://raw.githubusercontent.com/rbobbins/tessel-beacon-demo/master/screenshots/first_time_setup.png" style="width: 100%; height: 100%">
<figcaption>Screenshot 1: The first time you use the app, you'll register your Tessel</figcaption>
</figure>


<figure style="border: 1px solid #aaa; padding:5px; width: 70%">
<img src="https://raw.githubusercontent.com/rbobbins/tessel-beacon-demo/master/screenshots/tessel_information.png" style="width: 100%; height: 100%">
<figcaption>Screenshot 2: After registering your Tessel, you'll see the UUID it needs to broadcast</figcaption>
</figure>

<figure style="border: 1px solid #aaa; padding:5px; width: 70%">
<img src="https://raw.githubusercontent.com/rbobbins/tessel-beacon-demo/master/screenshots/email.png" style="width: 100%; height: 100%">
<figcaption>Screenshot 3: You can email yourself the code that the Tessel should run!</figcaption>
</figure>

<figure style="border: 1px solid #aaa; padding:5px; width: 70%">
<img src="https://raw.githubusercontent.com/rbobbins/tessel-beacon-demo/master/screenshots/location_permission.png" style="width: 100%; height: 100%">
<figcaption>Screenshot 4: The first time you turn on any of the iBeacon features, you'll see a location permission pop-up.</figcaption>
</figure>

<figure style="border: 1px solid #aaa; padding:5px; width: 70%">
<img src="https://raw.githubusercontent.com/rbobbins/tessel-beacon-demo/master/screenshots/ranging.png" style="width: 100%; height: 100%">
<figcaption>Screenshot 5: While the app is in the foreground, you can monitor your proximity to the Tessel</figcaption>
</figure>
