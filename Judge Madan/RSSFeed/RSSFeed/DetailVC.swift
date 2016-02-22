//
//  DetailVC.swift
//  RSSFeed
//
//  Copyright (c) 2016 Judge Madan. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {

    var displayedArticle:Article?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let actualArticle = self.displayedArticle {
            
            // Create NSURL for the article URL
            let url:NSURL? = NSURL(string: actualArticle.articleLink)
            
            // Create NSURLRequest for the NSURL
            
            //Check if an actual url object was created
            if let actualURL = url {
                let urlRequest:NSURLRequest = NSURLRequest(URL: url!)
            
                self.webView.loadRequest(urlRequest)
            }
            
            // Pass the request in to the webview to load the page
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
