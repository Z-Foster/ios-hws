//
//  Person.swift
//  Project10
//
//  Created by Zach Foster on 2/28/16.
//  Copyright © 2016 Zach Foster. All rights reserved.
//

import UIKit

class Person: NSObject {
    
    var name: String
    var imagePath: String
    
    init(name: String, imagePath: String){
        self.name = name
        self.imagePath = imagePath
    }
}
