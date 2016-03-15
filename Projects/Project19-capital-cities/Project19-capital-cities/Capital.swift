//
//  Capital.swift
//  Project19-capital-cities
//
//  Created by Zach Foster on 3/14/16.
//  Copyright © 2016 Zach Foster. All rights reserved.
//

import UIKit
import MapKit

class Capital: NSObject, MKAnnotation {
    
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String?
    

    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
