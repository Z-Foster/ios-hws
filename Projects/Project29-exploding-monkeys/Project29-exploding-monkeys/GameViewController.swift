//
//  GameViewController.swift
//  Project29-exploding-monkeys
//
//  Created by Zach Foster on 3/17/16.
//  Copyright (c) 2016 Zach Foster. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
  
  var currentGame: GameScene!
  @IBOutlet weak var playerNumber: UILabel!
  @IBOutlet weak var launchButton: UIButton!
  @IBOutlet weak var angleLabel: UILabel!
  @IBOutlet weak var angleSlider: UISlider!
  
  @IBOutlet weak var velocitySlider: UISlider!

  @IBOutlet weak var velocityLabel: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()

    if let scene = GameScene(fileNamed:"GameScene") {
      // Configure the view.
      let skView = self.view as! SKView
      skView.showsFPS = true
      skView.showsNodeCount = true
      
      /* Sprite Kit applies additional optimizations to improve rendering performance */
      skView.ignoresSiblingOrder = true
      
      /* Set the scale mode to scale to fit the window */
      scene.scaleMode = .AspectFill
      
      skView.presentScene(scene)
      currentGame = scene
      currentGame.viewController = self
      
      angleChanged(angleSlider)
      velocityChanged(velocitySlider)
    }
  }

  @IBAction func angleChanged(sender: UISlider) {
    angleLabel.text = "Angle: \(Int(angleSlider.value))°"
  }
  
  @IBAction func velocityChanged(sender: UISlider) {
    velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
  }
  
  @IBAction func launch(sender: UIButton) {
    angleSlider.hidden = true
    angleLabel.hidden = true
    
    velocitySlider.hidden = true
    velocityLabel.hidden = true
    
    launchButton.hidden = true
    
    currentGame.launch(angle: Int(angleSlider.value),
      velocity: Int(velocitySlider.value))
  }
  
  func activatePlayerNumber(number: Int) {
    if number == 1 {
      playerNumber.text = "<<< PLAYER ONE"
    } else {
      playerNumber.text = "PLAYER TWO >>>"
    }
    
    angleSlider.hidden = false
    angleLabel.hidden = false
    
    velocitySlider.hidden = false
    velocityLabel.hidden = false
    
    launchButton.hidden = false
  }
  
  override func shouldAutorotate() -> Bool {
    return true
  }

  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
      return .AllButUpsideDown
    } else {
      return .All
    }
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}
