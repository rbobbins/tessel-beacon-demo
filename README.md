tessel-beacon-demo
==================

This application demonstrates how to use a Tessel as an iBeacon that can interact with your phone.

Requirements
============

  - You must be a registered Apple Developer. You can install the app on an iOS simulator without being one, but you can't run bluetooth in the iOS simulator.
  - Your Tessel must have the BLE module, and be running the code available here: https://github.com/rbobbins/ble-ble113a
  
Features
========

  - App scans for Tessel beacon. In foreground, it will present the user with a pop up and begin logging proximity to the Tessel.
  - If app is in background (or closed) when recognizing a Tessel, it will show a notification.
  

Installation
============
1. Fork/clone this repo.
1. `cd` to your local repo, and run `pod install`
1. To run the specs (this app is well-tested), build the Specs target.
1. To run the app, build the TesselBluetoothDemo target to an *iOS device*. As mentioned above, you've got to be a registered Apple Developer to do this.

