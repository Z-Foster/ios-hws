//
//  ViewController.swift
//  Project19-capital-cities
//
//  Created by Zach Foster on 3/14/16.
//  Copyright © 2016 Zach Foster. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Creat Annotations
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")
        
        // Display Annotations
        mapView.addAnnotations([london, oslo, paris, rome, washington])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // 1 Define a reuse identifier so we reuse annotation views as much as possible
        let reuseIdentifier = "Capital"
        
        // 2 Check if annotation is one of ours.
        if annotation.isKindOfClass(Capital.self) {
            // 3 Try to get annotation view from map view's pool of unused views.
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)
        
            if annotationView == nil {
                // 4 Create a new MKPinAnnotationView if we can't find one to reuse.
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Capital")
                annotationView?.canShowCallout = true
                
                // 5 Add a button of type .DetailDisclosure to the annotationView to display more info.
                
                let btn = UIButton(type: .DetailDisclosure)
                annotationView?.rightCalloutAccessoryView = btn
            } else {
                // 6 Reuse annotation view if we found one to reuse.
                annotationView?.annotation = annotation
            }
            
            return annotationView
        } else {
            // 7 Return nil if annotation isn't of type Capital.
            return nil
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let capital = view.annotation as! Capital
        let placeName = capital.title
        let placeInfo = capital.info
        
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
}

