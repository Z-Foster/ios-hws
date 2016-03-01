//
//  GameScene.swift
//  Project11
//
//  Created by Zach Foster on 2/29/16.
//  Copyright (c) 2016 Zach Foster. All rights reserved.
//

import SpriteKit
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var editLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Set background */
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .Replace
        background.zPosition = -1
        addChild(background)
        
        /* Setup score label */
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .Right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        /* Setup edit label */
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        /* Setup physics */
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        physicsWorld.contactDelegate = self
        
        /*Add slots and bouncers. */
        makeSlotAt(CGPoint(x: 128, y: 0), isGood: true)
        makeSlotAt(CGPoint(x: 384, y: 0), isGood: false)
        makeSlotAt(CGPoint(x: 640, y: 0), isGood: true)
        makeSlotAt(CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncerAt(CGPoint(x: 0, y: 0))
        makeBouncerAt(CGPoint(x: 256, y: 0))
        makeBouncerAt(CGPoint(x: 512, y: 0))
        makeBouncerAt(CGPoint(x: 768, y: 0))
        makeBouncerAt(CGPoint(x: 1024, y: 0))
    }
    
    func makeBouncerAt(position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width/2.0)
        bouncer.physicsBody!.contactTestBitMask = bouncer.physicsBody!.collisionBitMask
        bouncer.physicsBody!.dynamic = false
        
        addChild(bouncer)
    }
    
    func makeSlotAt(position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotBase.name = "good"
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotBase.name = "bad"
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOfSize: slotBase.size)
        slotBase.physicsBody!.dynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotateByAngle(CGFloat(M_PI_2), duration: 10)
        let spinForever = SKAction.repeatActionForever(spin)
        slotGlow.runAction(spinForever)
    }
    
    func collisionBetweenBall(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            score += 1
            destroyBall(ball)
        } else if object.name == "bad" {
            score -= 1
            destroyBall(ball)
        }
    }
    
    func createBall(position: CGPoint) {
        let ball = SKSpriteNode(imageNamed: "ballRed")
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2.0)
        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
        ball.physicsBody!.restitution = 0.4
        ball.position = CGPoint(x: position.x, y: UIScreen.mainScreen().bounds.height)
        ball.name = "ball"
        addChild(ball)
    }
    
    func createBox(position: CGPoint) {
        let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
        let box = SKSpriteNode(color: RandomColor(), size: size)
        box.zRotation = RandomCGFloat(min: 0, max: 3)
        box.position = position
        
        box.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        box.physicsBody!.dynamic = false
        
        addChild(box)
    }
    
    func destroyBall(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.node!.name == "ball" {
            collisionBetweenBall(contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node!.name == "ball" {
            collisionBetweenBall(contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        if let touch = touches.first {
            let location = touch.locationInNode(self)
            
            let objects = nodesAtPoint(location) as [SKNode]
            if objects.contains(editLabel) {
                editingMode = !editingMode
            } else {
                if editingMode {
                    createBox(location)
                } else {
                    createBall(location)
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
