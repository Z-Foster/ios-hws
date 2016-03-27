//
//  BuildingNode.swift
//  Project29-exploding-monkeys
//
//  Created by Zach Foster on 3/17/16.
//  Copyright © 2016 Zach Foster. All rights reserved.
//

import UIKit
import GameKit
import SpriteKit

class BuildingNode: SKSpriteNode {
  
  var currentImage: UIImage!
  
  
  func setup() {
    name = "building"
    
    currentImage = drawBuilding(size: size)
    texture = SKTexture(image: currentImage)
    
    configurePhysics()
  }
  
  func configurePhysics() {
    physicsBody = SKPhysicsBody(texture: texture!, size: size)
    
    physicsBody?.dynamic = false
    physicsBody?.categoryBitMask = CollisionType.Building.rawValue
    physicsBody?.contactTestBitMask = CollisionType.Banana.rawValue
  }
  
  func drawBuilding(size size: CGSize) -> UIImage {
    // 1 Create a new Core Graphics context the size of our building.
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    let context = UIGraphicsGetCurrentContext()
    
    // 2 Fill it with a rectangle that's one of three colors.
    let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    var color: UIColor
    
    switch GKRandomSource.sharedRandom().nextIntWithUpperBound(3) {
    case 0:
      color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
    case 1:
      color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
    default:
      color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
    }
    
    CGContextSetFillColorWithColor(context, color.CGColor)
    CGContextAddRect(context, rectangle)
    CGContextDrawPath(context, .Fill)
    
    // 3 Draw windows all over the building in one of two colors: yellow or gray
    let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99,
      alpha: 1)
    let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34,
      alpha: 1)
    
    for var row: CGFloat = 10; row < size.height - 10; row += 40 {
      for var col: CGFloat = 10; col < size.width - 10; col += 40 {
        if RandomInt(min: 0, max: 1) == 0 {
          CGContextSetFillColorWithColor(context, lightOnColor.CGColor)
        } else {
          CGContextSetFillColorWithColor(context, lightOffColor.CGColor)
        }
        
        CGContextFillRect(context, CGRect(x: col, y: row,
          width: 15, height: 20))
      }
    }
    
    // 4 Pull out the result as a UIImage and return it for elsewhere
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img
  }
  
  
  func hitAtPoint(point: CGPoint) {
    // 1 Figure out where the building was hit in CG coordinates.
    let convertedPoint = CGPoint(x: point.x + size.width / 2.0,
      y: abs(point.y - (size.height / 2.0)))
    
    // 2 Create a new core graphics context the size of our current sprite.
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    let context = UIGraphicsGetCurrentContext()
    
    // 3 Draw current building image to context.
    currentImage.drawAtPoint(CGPoint(x: 0, y: 0))
    
    // 4 Create an ellipse at the collision point.
    CGContextAddEllipseInRect(context, CGRect(x: convertedPoint.x - 32,
      y: convertedPoint.y - 32, width: 64, height: 64))
    
    // 5 Set the blend mode to clear, draw the ellipse.
    CGContextSetBlendMode(context, .Clear)
    CGContextDrawPath(context, .Fill)
    
    // 6 Covert back to image, cleanup context, set image, update physics.
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    texture = SKTexture(image: img)
    currentImage = img
    
    configurePhysics() 
  }
}
