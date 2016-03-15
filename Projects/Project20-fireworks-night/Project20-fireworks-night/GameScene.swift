//
//  GameScene.swift
//  Project20-fireworks-night
//
//  Created by Zach Foster on 3/14/16.
//  Copyright (c) 2016 Zach Foster. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - Properties
    var gameTimer: NSTimer!
    var fireworks = [SKNode]()
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var score: Int = 0 {
        didSet {
            // My code here if I implement a score.
        }
    }
    
    
    // MARK: - Setup
    override func didMoveToView(view: SKView) {
        // Set background
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -1
        background.blendMode = .Replace
        addChild(background)
        
        // Create a timer that launches fireworks every 6s.
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: "launchFireworks", userInfo: nil, repeats: true)
    }
    
    // MARK: - Touches
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        checkForTouches(touches)
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        checkForTouches(touches)
    }
    
    func checkForTouches(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.locationInNode(self)
        let nodes = nodesAtPoint(location)
        
        for node in nodes {
            if node.isKindOfClass(SKSpriteNode.self) {
                let sprite = node as! SKSpriteNode
                if sprite.name == "firework" {
                    for parent in fireworks {
                        let firework = parent.children.first as! SKSpriteNode
                        
                        if firework.name == "selected" && firework.color != sprite.color {
                            firework.name = "firework"
                            firework.colorBlendFactor = 1
                        }
                    }
                    sprite.name = "selected"
                    sprite.colorBlendFactor = 0
                }
            }
        }
    }
   
    // MARK: - Update
    override func update(currentTime: CFTimeInterval) {
        for (index, firework) in fireworks.enumerate().reverse() {
            if firework.position.y > 900 {
                fireworks.removeAtIndex(index)
                firework.removeFromParent()
            }
        }
    }
    
    // MARK: - Game functions
    func launchFireworks() {
        let movementAmount: CGFloat = 1800
        
        switch GKRandomSource.sharedRandom().nextIntWithUpperBound(4) {
        case 0:
            // Fire five, straight up.
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
        case 1:
            // Fire five in a fan.
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
        case 2:
            // Fire five from left to right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
        case 3:
            // Fire five from right to left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
        default:
            break
        }
        
    }
    
    func createFirework(xMovement xMovement: CGFloat, x: Int, y: Int) {
        // 1 Create SKNode as a firework container. Place it at x,y
        let container = SKNode()
        container.position = CGPoint(x: x, y: y)
        
        // 2 Create rocket sprite node, name it "firework" and add it to container node.
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.name = "firework"
        container.addChild(firework)
        
        // 3 Give the firework sprite node a random color.
        switch GKRandomSource.sharedRandom().nextIntWithUpperBound(3) {
        case 0:
            firework.color = UIColor.cyanColor()
            firework.colorBlendFactor = 1
        case 1:
            firework.color = UIColor.greenColor()
            firework.colorBlendFactor = 1
        case 2:
            firework.color = UIColor.redColor()
            firework.colorBlendFactor = 1
        default:
            break
        }
        // 4 Create a UIBezierPath to represent the movement of the firework.
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: xMovement, y: 1000))
        
        // 5 Tell the container node to follow that path.
        let move = SKAction.followPath(path.CGPath, asOffset: true, orientToPath: true, speed: 200)
        container.runAction(move)
        
        // 6 Create particles behind the rocket to make it look like the fireworks are lit.
        let trailEmitter = SKEmitterNode(fileNamed: "fuse")!
        trailEmitter.position = CGPoint(x: 0, y: -22)
        container.addChild(trailEmitter)
        
        // 7 Add the firework to the fireworks array, and the scene.
        fireworks.append(container)
        addChild(container)
    }
    
    func explodeFirework(firework: SKNode) {
        let emitter = SKEmitterNode(fileNamed: "explode")!
        emitter.position = firework.position
        addChild(emitter)
        
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerate().reverse() {
            let firework = fireworkContainer.children[0] as! SKSpriteNode
            
            if firework.name == "selected" {
                // destroy firework
                explodeFirework(fireworkContainer)
                fireworks.removeAtIndex(index)
                
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
}
