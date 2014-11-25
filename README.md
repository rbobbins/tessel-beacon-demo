tessel-beacon-demo
==================

This application demonstrates how to use a Tessel as an iBeacon that can interact with your phone.

Requirements
============

  - You must be a registered Apple Developer. You can install the app on an iOS simulator without being one, but you can't run bluetooth in the iOS simulator.
  - You must have the Tessel BLE module. The application will guide you through setting it up correctly.
  
Features
========

  - _Tessel Beacon Monitoring_ : User can decide whether or not monitor for boundary changes when entering/exiting the region of the Tessel. If the user decides to monitor for boundary changes, they'll get notified each time they *enter* the region of a Tessel. This happens regardless of whether the app is currently in the foreground. Also, the app will ping [http://tessel-beacon-server.herokuapp.com](http://tessel-beacon-server.herokuapp.com) each time it enters the region of a Tessel. Currently, the app does not include notifications when exiting the region of a Tessel. 
  - _Tessel Beacon Ranging_ : When the app is in the foreground, user can range the Tessel Beacon. While ranging is enabled, the app will display the proximity to the Tessel Beacon in realtime. scans for Tessel beacon. 
  

Installation
============
1. Fork/clone this repo.
1. If this is your first time building an iOS app, you'll probably have to install Cocoapods. Cocoapods is like NPM for iOS apps. To install: `sudo gem install cocoapods`. Yes, Cocoapods is a gem. If you don't have Ruby installed, you'll have to do that first. Dependencies are just turtles all the way down.
1. `cd` to your local repo, and run `pod install`. 
1. To run the app, build the TesselBeaconDemo target to an *iOS device*. As mentioned above, you've got to be a registered Apple Developer to do this.


Running Tests
=============
1. To run the specs (this app is well-tested), build the Specs target.

