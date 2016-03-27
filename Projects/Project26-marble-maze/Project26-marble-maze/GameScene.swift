//
//  GameScene.swift
//  Project26-marble-maze
//
//  Created by Zach Foster on 3/16/16.
//  Copyright (c) 2016 Zach Foster. All rights reserved.
//

import SpriteKit
import CoreMotion

enum CollisionTypes: UInt32 {
    case Player = 1
    case Wall = 2
    case Star = 4
    case Vortex = 8
    case Finish = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager!
    var scoreLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var gameOver = false
    
    
    // MARK: - Setup
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .Replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        addChild(scoreLabel)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        loadLevel()
        createPlayer()
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.categoryBitMask = CollisionTypes.Player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.Star.rawValue | CollisionTypes.Vortex.rawValue | CollisionTypes.Finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.Wall.rawValue
        
        addChild(player)
    }
    
    // MARK: - Load Level
    func loadLevel() {
        if let levelPath = NSBundle.mainBundle().pathForResource("level1", ofType: "txt") {
            if let levelString = try? String(contentsOfFile: levelPath) {
                let lines = levelString.componentsSeparatedByString("\n")
                
                for (row, line) in lines.reverse().enumerate() {
                    for (column, letter) in line.characters.enumerate() {
                        let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                        switch letter {
                        case "x":
                            loadWall(position)
                        case "v":
                            loadVortex(position)
                        case "s":
                            loadStar(position)
                        case "f":
                            loadFinish(position)
                        default:
                            break
                        }
                        
                    }
                }
            }
        }
    }
    
    func loadWall(position: CGPoint) {
        let wallNode = SKSpriteNode(imageNamed: "block")
        wallNode.position = position
        
        wallNode.physicsBody = SKPhysicsBody(rectangleOfSize: wallNode.size)
        wallNode.physicsBody?.categoryBitMask = CollisionTypes.Wall.rawValue
        wallNode.physicsBody?.dynamic = false
        
        addChild(wallNode)
    }
    
    func loadVortex(position: CGPoint) {
        let vortexNode = SKSpriteNode(imageNamed: "vortex")
        vortexNode.name = "vortex"
        vortexNode.position = position
        
        let rotateAction = SKAction.rotateByAngle(CGFloat(M_PI), duration: 1)
        let rotateForever = SKAction.repeatActionForever(rotateAction)
        vortexNode.runAction(rotateForever)
        
        vortexNode.physicsBody = SKPhysicsBody(circleOfRadius: vortexNode.size.width / 2)
        vortexNode.physicsBody?.dynamic = false
        
        vortexNode.physicsBody?.categoryBitMask = CollisionTypes.Vortex.rawValue
        vortexNode.physicsBody?.contactTestBitMask = CollisionTypes.Player.rawValue
        vortexNode.physicsBody?.collisionBitMask = 0
        
        addChild(vortexNode)
    }
    
    func loadStar(position: CGPoint) {
        let starNode = SKSpriteNode(imageNamed: "star")
        starNode.name = "star"
        starNode.position = position
        
        starNode.physicsBody = SKPhysicsBody(circleOfRadius: starNode.size.width / 2)
        starNode.physicsBody?.dynamic = false
        
        starNode.physicsBody?.categoryBitMask = CollisionTypes.Star.rawValue
        starNode.physicsBody?.contactTestBitMask = CollisionTypes.Player.rawValue
        starNode.physicsBody?.collisionBitMask = 0
        
        addChild(starNode)
    }
    
    func loadFinish(position: CGPoint) {
        let finishNode = SKSpriteNode(imageNamed: "finish")
        finishNode.name = "finish"
        finishNode.position = position
        
        finishNode.physicsBody = SKPhysicsBody(circleOfRadius: finishNode.size.width / 2)
        finishNode.physicsBody?.dynamic = false
        
        finishNode.physicsBody?.categoryBitMask = CollisionTypes.Finish.rawValue
        finishNode.physicsBody?.contactTestBitMask = CollisionTypes.Player.rawValue
        finishNode.physicsBody?.collisionBitMask = 0
        
        addChild(finishNode)
    }
    
    // MARK: - Touches
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.locationInNode(self)
            lastTouchPosition = location
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.locationInNode(self)
            lastTouchPosition = location
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        lastTouchPosition = nil
    }
   
    // MARK: - Update
    override func update(currentTime: CFTimeInterval) {
        if !gameOver {
    #if (arch(i386) || arch(x86_64))
            if let currentTouch = lastTouchPosition {
                let touchDifference = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
                physicsWorld.gravity = CGVector(dx: touchDifference.x / 100, dy: touchDifference.y / 100)
            }
    #else
            if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * -50)
            }
    #endif
        }
    }
    
    // MARK: - Collision
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.node == player {
            playerCollidedWithNode(contact.bodyB.node!)
        } else if contact.bodyB.node == player {
            playerCollidedWithNode(contact.bodyA.node!)
        }
    }
    
    func playerCollidedWithNode(node: SKNode) {
        if node.name == "vortex" {
            gameOver = true
            
            node.physicsBody?.dynamic = false
            
            let moveToVortex = SKAction.moveTo(node.position, duration: 0.2)
            let shrink = SKAction.scaleTo(0.001, duration: 0.2)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([moveToVortex, shrink, remove])
            
            player.runAction(sequence) { [unowned self] in
                self.createPlayer()
                self.gameOver = false
            }
            score -= 1
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            // Next Level?
            score += 10
            player.removeFromParent()
            self.createPlayer()
        }
    }
}
