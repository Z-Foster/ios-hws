//
//  DetailViewController.swift
//  Project3
//
//  Created by Zach Foster on 2/21/16.
//  Copyright © 2016 Zach Foster. All rights reserved.
//

import UIKit
import Social

class DetailViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!

    var detailItem: String? {
        didSet {
            // Update the view.
            title = detailItem
            configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let imageView = detailImageView {
                imageView.image = UIImage(named: detail)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "shareTapped")
        configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.hidesBarsOnTap = false
    }

    func shareTapped() {
        let activityViewController = UIActivityViewController(activityItems: [detailImageView.image!], applicationActivities: [])
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func shareFacebook() {
        let fbVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        fbVC.setInitialText("Check out this cool storm picture!")
        fbVC.addImage(detailImageView.image!)
        fbVC.addURL(NSURL(string: "http://www.photolib.noaa.gov/nssl"))
        presentViewController(fbVC, animated: true, completion: nil)
    }
}

