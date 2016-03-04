//
//  GameScene.swift
//  Project14
//
//  Created by Zach Foster on 3/3/16.
//  Copyright (c) 2016 Zach Foster. All rights reserved.
//

import SpriteKit
import GameKit

class GameScene: SKScene {
    
    var slots = [WhackSlot]()
    
    var popupTime = 0.85
    
    var gameScore: SKLabelNode!
    var score: Int = 0 {
        didSet {
            self.gameScore.text = "Score: \(score)"
        }
    }
    
    var numRounds = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .Replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .Left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        for i in 0..<5 { createSlotAt(CGPoint(x: 100 + (i * 170), y: 410))}
        for i in 0..<4 { createSlotAt(CGPoint(x: 180 + (i * 170), y: 320))}
        for i in 0..<5 { createSlotAt(CGPoint(x: 100 + (i * 170), y: 230))}
        for i in 0..<4 { createSlotAt(CGPoint(x: 180 + (i * 170), y: 140))}
        
        RunAfterDelay(1.0) { [unowned self] in
            self.createEnemy()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        if let touch = touches.first {
            let location = touch.locationInNode(self)
            let nodes = nodesAtPoint(location)
        
            for node in nodes {
                if node.name == "charEnemy" {
                    let thisSlot = node.parent!.parent as! WhackSlot
                    if !thisSlot.visible { continue }
                    if thisSlot.isHit { continue }
                    
                    thisSlot.charNode.xScale = 0.85
                    thisSlot.charNode.yScale = 0.85
                    
                    thisSlot.hit()
                    score += 1
                    
                    runAction(SKAction.playSoundFileNamed("whack", waitForCompletion: false))
                    
                } else if node.name == "charFriend" {
                    let thisSlot = node.parent!.parent as! WhackSlot
                    if !thisSlot.visible { continue }
                    if thisSlot.isHit { continue }
                    
                    thisSlot.hit()
                    score -= 5
                    
                    runAction(SKAction.playSoundFileNamed("whackBad", waitForCompletion: false))
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func createSlotAt(pos: CGPoint) {
        let slot = WhackSlot()
        slot.configureAtPosition(pos)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        numRounds += 1
        if numRounds >= 30 {
            gameOver()
            return
        }
        
        popupTime *= 0.991
        
        slots = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(slots) as! [WhackSlot]
        slots[0].show(hideTime: popupTime)
        
        if RandomInt(min: 0, max: 12) > 4 {
            slots[1].show(hideTime: popupTime)
        }
        if RandomInt(min: 0, max: 12) > 8 {
            slots[2].show(hideTime: popupTime)
        }
        if RandomInt(min: 0, max: 12) > 10 {
            slots[3].show(hideTime: popupTime)
        }
        if RandomInt(min: 0, max: 12) > 11 {
            slots[4].show(hideTime: popupTime)
        }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        
        RunAfterDelay(RandomDouble(min: minDelay, max: maxDelay)) { [unowned self] in
            self.createEnemy()
        }
    }
    
    func gameOver() {
        for slot in slots {
            slot.hide()
        }
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: 512, y: 384)
        gameOver.zPosition = 1
        addChild(gameOver)
    }
}
