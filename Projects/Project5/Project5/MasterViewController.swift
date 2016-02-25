//
//  MasterViewController.swift
//  Project5
//
//  Created by Zach Foster on 2/23/16.
//  Copyright © 2016 Zach Foster. All rights reserved.
//

import UIKit
import GameKit

class MasterViewController: UITableViewController {

    var objects = [String]()
    var allWords = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "promptForAnswer")
        
        if let startWordsPath = NSBundle.mainBundle().pathForResource("start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allWords = startWords.componentsSeparatedByString("\n")
            }
        } else {
            allWords = ["silkworm"]
        }
        
        startGame()
    }

    // MARK: - Game functions
    
    func startGame() {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(allWords) as! [String]
        title = allWords[0]
        objects.removeAll(keepCapacity: true)
        tableView.reloadData()
    }
    
    func promptForAnswer() {
        let answerPrompt = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .Alert)
        answerPrompt.addTextFieldWithConfigurationHandler(nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Default) {
            // Use closure capture list to capture self and answerPrompt as unowned.
            [unowned self, answerPrompt] (action: UIAlertAction!) in
            // Could have just done "action in" or "_ in"
            let answer = answerPrompt.textFields![0]
            if let answerText = answer.text {
                self.submitAnswer(answerText)
            }
        }
        answerPrompt.addAction(submitAction)
        presentViewController(answerPrompt, animated: true, completion: nil)
    }
    
    func submitAnswer(answer: String) {
        let lowerAnswer = answer.lowercaseString
        
        let errorTitle: String
        let errorMessage: String
        
        if wordIsPossible(lowerAnswer) {
            if wordIsOriginal(lowerAnswer) {
                if wordIsReal(lowerAnswer) {
                    objects.insert(answer, atIndex: 0)
                    
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    
                    return
                } else {
                    errorTitle = "Word not recognised"
                    errorMessage = "Real words only!"
                }
            } else {
                errorTitle = "Duplicate word"
                errorMessage = "You've already entered that word!"
            }
        } else {
            errorTitle = "Word not possible"
            errorMessage = "You can't make \(lowerAnswer) from \(title!)"
        }
        
        let errorController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .Alert)
        let errorAlertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        errorController.addAction(errorAlertAction)
        presentViewController(errorController, animated: true, completion: nil)
    }
    
    func wordIsPossible(word: String) -> Bool {
        var tempWord = title!.lowercaseString
        
        for letter in word.characters {
            if let pos = tempWord.rangeOfString(String(letter)) {
                tempWord.removeAtIndex(pos.startIndex)
            } else {
                return false
            }
        }
        return true
    }
    
    func wordIsOriginal(word: String) -> Bool {
        return !objects.contains(word)
    }
    
    func wordIsReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.characters.count)
        let misspelledRange = checker.rangeOfMisspelledWordInString(word, range: range, startingAt: 0, wrap: false, language: "en")
        // return true if no misspelledRange is found.
        return misspelledRange.location == NSNotFound
    }
    
    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }
    
    // MARK: - Memory Warning
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

