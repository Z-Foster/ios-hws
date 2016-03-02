//
//  Person.swift
//  Project10
//
//  Created by Zach Foster on 2/28/16.
//  Copyright © 2016 Zach Foster. All rights reserved.
//

import UIKit

class Person: NSObject, NSCoding {
    
    var name: String
    var imagePath: String
    
    init(name: String, imagePath: String){
        self.name = name
        self.imagePath = imagePath
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        imagePath = aDecoder.decodeObjectForKey("imagePath") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(imagePath, forKey: "imagePath")
    }
}
