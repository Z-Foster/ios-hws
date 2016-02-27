//
//  DetailViewController.swift
//  Project7
//
//  Created by Zach Foster on 2/26/16.
//  Copyright © 2016 Zach Foster. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    var webView: WKWebView!
    var detailItem: [String:String]!
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard detailItem != nil else {
            return
        }
        
        if let body = detailItem["body"], title = detailItem["title"] {
            var html = "<html>"
            html +=  "<head>"
            html +=  "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
            html +=  "<style> body { font-size: 150%; } </style>"
            html +=  "</head>"
            html +=  "<body>"
            html +=  "<h2>\(title)</h2>"
            html +=  "<p>\(body)</p>"
            html +=  "</body>"
            html +=  "</html>"
            webView.loadHTMLString(html, baseURL: nil)
        }
    }

}
