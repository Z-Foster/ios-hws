//
//  MasterViewController.swift
//  Project7
//
//  Created by Zach Foster on 2/26/16.
//  Copyright © 2016 Zach Foster. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [[String: String]]()


    override func viewDidLoad() {
        super.viewDidLoad()

        let urlString: String
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        if let url = NSURL(string: urlString) {
            guard let data = NSData(contentsOfURL: url) else {
                return showError()
            }
            let json = JSON(data: data)
            if json["metadata"]["responseInfo"]["status"] == 200 {
                parseJSON(json)
            } else {
                showError()
            }
        } else {
            showError()
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    func parseJSON(json: JSON) {
        for result in json["results"].arrayValue {
            let title = result["title"].stringValue
            let body = result["body"].stringValue
            let sigCount = result["signatureCount"].stringValue
            let resultDict = ["title": title, "body": body, "sigCount": sigCount]
            
            objects.append(resultDict)
        }
        tableView.reloadData()
    }
    
    func showError() {
        let alertController = UIAlertController(title: "Load Error", message: "There was a problem loading the feed. Please check your internet connection and try again.", preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        alertController.addAction(alertAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
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
        cell.textLabel!.text = object["title"]
        cell.detailTextLabel!.text = object["body"]
        return cell
    }

}

