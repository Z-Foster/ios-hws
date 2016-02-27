//
//  ViewController.swift
//  Project8
//
//  Created by Zach Foster on 2/26/16.
//  Copyright © 2016 Zach Foster. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController {

    @IBOutlet weak var clueLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var currentAnswer: UITextField!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var level = 1
    let numberOfLevels = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for subview in view.subviews where subview.tag == 1001 {
            let btn = subview as! UIButton
            letterButtons.append(btn)
            btn.addTarget(self, action: "letterTapped:", forControlEvents: .TouchUpInside)
        }
        
        loadLevel()
    }
    
    func loadLevel() {
        var clueString = ""
        var solutionLengthString = ""
        var letterBits = [String]()
        
        if let levelFilePath = NSBundle.mainBundle().pathForResource("level\(level)", ofType: ".txt") {
            if let levelContents = try? String(contentsOfFile: levelFilePath) {
                var lines = levelContents.componentsSeparatedByString("\n")
                lines = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(lines) as! [String]
                
                for (lineArrayIndex, line) in lines.enumerate() {
                    let parts = line.componentsSeparatedByString(":")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(lineArrayIndex + 1). \(clue)\n"
                    
                    let solutionWord = answer.stringByReplacingOccurrencesOfString("|", withString: "")
                    solutionLengthString += "\(solutionWord.characters.count) letters\n"
                    
                    solutions.append(solutionWord)
                    
                    let bits = answer.componentsSeparatedByString("|")
                    letterBits += bits
                }
            }
        }
        
        clueLabel.text = clueString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        answerLabel.text = solutionLengthString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        
        letterButtons = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(letterButtons) as! [UIButton]
        
        if letterBits.count == letterButtons.count {
            for i in 0..<letterBits.count {
                letterButtons[i].setTitle(letterBits[i], forState: .Normal)
            }
        }
    }
    
    func levelUp(action: UIAlertAction!) {
        if level == numberOfLevels {
            level = 1
        } else {
            level += 1
        }

        
        solutions.removeAll(keepCapacity: true)
        
        loadLevel()
        
        for button in letterButtons {
            button.hidden = false
        }
    }

    func letterTapped(button: UIButton) {
        currentAnswer.text = currentAnswer.text! + button.titleLabel!.text!
        activatedButtons.append(button)
        button.hidden = true
    }
    
    @IBAction func submitTapped(sender: UIButton) {
        if let solutionPosition = solutions.indexOf(currentAnswer.text!) {
            activatedButtons.removeAll()
            
            var splitAnswersLengths = answerLabel.text!.componentsSeparatedByString("\n")
            splitAnswersLengths[solutionPosition] = currentAnswer.text!
            answerLabel.text = splitAnswersLengths.joinWithSeparator("\n")
            
            currentAnswer.text = ""
            score += 1
            
            if score % 7 == 0 {
                let alertController = UIAlertController(title: "Good Job", message: "You've completed this level, are you ready for the next level?", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: levelUp))
                presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func clearTapped(sender: UIButton) {
        currentAnswer.text = ""
        
        for button in activatedButtons {
            button.hidden = false
        }
        
        activatedButtons.removeAll()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

