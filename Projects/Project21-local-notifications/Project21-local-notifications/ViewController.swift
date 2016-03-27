//
//  ViewController.swift
//  Project21-local-notifications
//
//  Created by Zach Foster on 3/15/16.
//  Copyright © 2016 Zach Foster. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func registerLocal(sender: UIButton) {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }

    @IBAction func scheduleLocal(sender: UIButton) {
        guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else {
            return
        }
        
        if settings.types == .None {
            let ac = UIAlertController(title: "Can't schedule", message: "We don't have permission to schedule a notification.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            return
        }
        
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
        notification.alertBody = "Hey you! Yeah you! Swipe to unlock."
        notification.alertAction = "be awesome!"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["CustomField": "w00t"]
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
}

