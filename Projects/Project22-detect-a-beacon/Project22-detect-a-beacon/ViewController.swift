//
//  ViewController.swift
//  Project22-detect-a-beacon
//
//  Created by Zach Foster on 3/15/16.
//  Copyright © 2016 Zach Foster. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: - Properties
    @IBOutlet weak var distanceReading: UILabel!
    
    var locationManager: CLLocationManager!
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - Beacon Detecting
    func startScanning() {
        let uuid = NSUUID(UUIDString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon")
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func updateDistance(distance: CLProximity) {
        UIView.animateWithDuration(0.8) { [unowned self] in
            switch distance {
            case .Unknown:
                self.view.backgroundColor = UIColor.grayColor()
                self.distanceReading.text = "UNKNOWN"
            case .Far:
                self.view.backgroundColor = UIColor.redColor()
                self.distanceReading.text = "FAR"
            case .Near:
                self.view.backgroundColor = UIColor.yellowColor()
                self.distanceReading.text = "NEAR"
            case .Immediate:
                self.view.backgroundColor = UIColor.greenColor()
                self.distanceReading.text = "RIGHT HERE"
            }
        }
    }
    
    // MARK: - Delegation
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        if beacons.count > 0 {
            let beacon = beacons[0]
            updateDistance(beacon.proximity)
        } else {
            updateDistance(CLProximity.Unknown)
        }
    }
}

