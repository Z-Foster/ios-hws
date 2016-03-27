//: Playground - noun: a place where people can play

import UIKit

extension Int {
    mutating func plusOne() {
        self += 1
    }
    
    static func random(min min: Int, max: Int) -> Int {
        if max < min {
            return min
        }
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }
}

var myInt = 0
myInt.plusOne()
myInt
Int.random(min: 0, max: 10)

extension String {
    mutating func trim() {
        self = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}

var testString = "    yay \n wooty"
//testString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
testString.trim()