//
//  GameScene.swift
//  Project17-swifty-ninja
//
//  Created by Zach Foster on 3/13/16.
//  Copyright (c) 2016 Zach Foster. All rights reserved.
//

import SpriteKit
import AVFoundation

enum ForceBomb {
    case Never, Always, Default
}

enum SequenceType: Int {
    case OneNoBomb, One, TwoWithOneBomb, Two, Three, Four, Chain, FastChain
}

class GameScene: SKScene {
    
    var gameScore: SKLabelNode!
    var score: Int = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var livesImages = [SKSpriteNode]()
    var lives: Int = 3 {
        didSet {
            runAction(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
            var life: SKSpriteNode!
            
            if lives == 2 {
                life = livesImages[0]
            } else if lives == 1 {
                life = livesImages[1]
            } else {
                life = livesImages[2]
                endGame(triggeredByBomb: false)
            }
            life.texture = SKTexture(imageNamed: "sliceLifeGone")
            
            life.xScale = 1.3
            life.yScale = 1.3
            life.runAction(SKAction.scaleTo(1, duration: 0.1))
        }
    }
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var activeSlicePoints = [CGPoint]()
    
    var swooshSoundActive = false
    var bombSoundEffect: AVAudioPlayer!
    
    var activeEnemies = [SKSpriteNode]()
    
    var popupTime = 0.9
    var sequence: [SequenceType]!
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    
    var gameEnded = false
    
    // MARK - UI setup
    
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background .zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        
        sequence = [.OneNoBomb, .OneNoBomb, .TwoWithOneBomb, .TwoWithOneBomb, .Three, .One, .Chain]
        
        for _ in 0 ... 1000 {
            let nextSequence = SequenceType(rawValue: RandomInt(min: 2, max: 7))!
            sequence.append(nextSequence)
        }
        
        RunAfterDelay(2) { [unowned self] in
            self.tossEnemies()
        }
    }
    
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.horizontalAlignmentMode = .Left
        gameScore.fontSize = 48
        
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
    }
    
    func createLives() {
        for i in 0..<3  {
            let lifeNode = SKSpriteNode(imageNamed: "sliceLife")
            lifeNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(lifeNode)
            
            livesImages.append(lifeNode)
        }
    }
    
    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 2
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = UIColor.whiteColor()
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    // MARK - Touch handling
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        activeSlicePoints.removeAll(keepCapacity: true)
        
        guard let touch = touches.first else { return }
        
        activeSlicePoints.append(touch.locationInNode(self))
        redrawActiveSlice()
        
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.locationInNode(self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !swooshSoundActive {
            playSwooshSound()
        }
        
        let nodes = nodesAtPoint(location)
        for node in nodes {
            if node.name == "enemy" {
                // 1 Create a particle effect over the penguin
                let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy")!
                emitter.position = node.position
                addChild(emitter)
                
                // 2 Clear penguin's node name so we can't swipe it again.
                node.name = ""
                
                // 3 Disable dynamic physics so it doesn't keep falling.
                node.physicsBody?.dynamic = false
                
                // 4 Scale and fade out the penguin at the same time.
                let scaleOut = SKAction.scaleTo(0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOutWithDuration(0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                // 5 After fading, remove from scene
                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                node.runAction(seq)
                
                // 6 Increase score
                score += 1
                
                // 7 Remove from activeEnemies. Must cast because nodesAtPoint doesn't return SKSpriteNodes.
                let index = activeEnemies.indexOf(node as! SKSpriteNode)!
                activeEnemies.removeAtIndex(index)
                
                // 8 Play sound
                runAction(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
            } else if node.name == "bomb" {
                // Similar steps as swiping a penguin. Reference parent node so we affect the bomb and it's fuse effect.
                let emitter = SKEmitterNode(fileNamed: "sliceHitBomb")!
                emitter.position = node.parent!.position
                addChild(emitter)
                
                node.name = ""
                node.parent?.physicsBody?.dynamic = false
                
                let scaleOut = SKAction.scaleTo(0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOutWithDuration(0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                node.parent?.runAction(seq)
                
                let index = activeEnemies.indexOf(node.parent as! SKSpriteNode)!
                activeEnemies.removeAtIndex(index)
                
                runAction(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        activeSliceBG.runAction(SKAction.fadeOutWithDuration(0.25))
        activeSliceFG.runAction(SKAction.fadeOutWithDuration(0.25))
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if let touches = touches {
            touchesEnded(touches, withEvent: event)
        }
    }
    
    // MARK - Update
    
    override func update(currentTime: NSTimeInterval) {
        var isBomb = false
        
        if activeEnemies.count > 0 {
            for node in activeEnemies {
                if node.position.y < -140 {
                    node.removeAllActions()
                    if node.name == "enemy" {
                        node.name = ""
                        lives -= 1
                        node.removeFromParent()
                        if let index = activeEnemies.indexOf(node) {
                            activeEnemies.removeAtIndex(index)
                        }
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        if let index = activeEnemies.indexOf(node) {
                            activeEnemies.removeAtIndex(index)
                        }
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                RunAfterDelay(popupTime) { [unowned self] in
                    self.tossEnemies()
                }
                
                nextSequenceQueued = true
            }
        }
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                isBomb = true
                break
            }
        }
        
        if !isBomb {
            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }
        }
    }
    
    // MARK - Draw slices
    
    func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        let path = UIBezierPath()
        path.moveToPoint(activeSlicePoints.first!)
        
        while activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst()
        }
        
        for slicePoint in activeSlicePoints {
            path.addLineToPoint(slicePoint)
        }
        
        activeSliceBG.path = path.CGPath
        activeSliceFG.path = path.CGPath
    }
    
    // MARK - Sound
    
    func playSwooshSound() {
        swooshSoundActive = true
        
        let randomNumber = RandomInt(min: 1, max: 3)
        let swooshAction = SKAction.playSoundFileNamed("swoosh\(randomNumber).caf", waitForCompletion: true)
        runAction(swooshAction) { [unowned self] in
            self.swooshSoundActive = false
        }
    }
    
    // Mark - Enemies
    
    func tossEnemies() {
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .OneNoBomb:
            createEnemy(forceBomb: .Never)
        case .One:
            createEnemy()
        case .TwoWithOneBomb:
            createEnemy(forceBomb: .Never)
            createEnemy(forceBomb: .Always)
        case .Two:
            createEnemy()
            createEnemy()
        case .Three:
            createEnemy()
            createEnemy()
            createEnemy()
        case .Four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
        case .Chain:
            createEnemy()
            for i in 1...4 {
                RunAfterDelay(chainDelay / 5.0 * Double(i)) { [unowned self] in
                    self.createEnemy()
                }
            }
        case .FastChain:
            createEnemy()
            for i in 1...4 {
                RunAfterDelay(chainDelay / 10.0 * Double(i)) { [unowned self] in
                    self.createEnemy()
                }
            }
        }
        
        sequencePosition += 1
        nextSequenceQueued = false
    }
    
    func createEnemy(forceBomb forceBomb: ForceBomb = .Default) {
        var enemy: SKSpriteNode
        var enemyType = RandomInt(min: 0, max: 6)
        
        if forceBomb == .Never {
            enemyType = 1
        } else if forceBomb == .Always {
            enemyType = 0
        }
        
        if enemyType == 0 {
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }
            
            let path = NSBundle.mainBundle().pathForResource("sliceBombFuse.caf", ofType: nil)!
            let url = NSURL(fileURLWithPath: path)
            let sound = try! AVAudioPlayer(contentsOfURL: url)
            bombSoundEffect = sound
            sound.play()
            
            let emitter = SKEmitterNode(fileNamed: "sliceFuse")!
            emitter.position = CGPoint(x: 76, y: 64)
            enemy.addChild(emitter)
            
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            runAction(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        let randomPosition = CGPoint(x: RandomInt(min: 64, max: 960), y: -128)
        enemy.position = randomPosition
        
        let randomAngularVelocity = CGFloat(RandomInt(min: -6, max: 6)) / 2.0
        
        var randomXVelocity = 0
        if randomPosition.x < 256 {
            randomXVelocity = RandomInt(min: 8, max: 15)
        } else if randomPosition.x < 512 {
            randomXVelocity = RandomInt(min: 3, max: 5)
        } else if randomPosition.x < 768 {
            randomXVelocity = -RandomInt(min: 3, max: 5)
        } else {
            randomXVelocity = -RandomInt(min: 3, max: 15)
        }
        
        let randomYVelocity = RandomInt(min: 24, max: 32)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody!.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody!.angularVelocity = randomAngularVelocity
        enemy.physicsBody!.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    // MARK - End game
    
    func endGame(triggeredByBomb triggeredByBomb: Bool) {
        if gameEnded {
            return
        }
        
        gameEnded = true
        physicsWorld.speed = 0
        userInteractionEnabled = false
        
        if bombSoundEffect != nil {
            bombSoundEffect.stop()
            bombSoundEffect = nil
        }
        
        if triggeredByBomb {
            for i in 0..<3 {
                livesImages[i].texture = SKTexture(imageNamed: "sliceLifeGone")
            }
        }
    }
}
