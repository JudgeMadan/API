//
//  FeedModel.swift
//  RSSFeed
//
//  Copyright (c) 2016 Judge Madan. All rights reserved.
//

import UIKit

protocol FeedModelDelegate {
    func articlesReady()
}

class FeedModel: NSObject {
    
    let feedURLString:String = "http://inside.isb.ac.th/pn/feed/"

    var articles:[Article] = [Article]()
    var delegate:FeedModelDelegate?
    var parser:Parser = Parser()
    
    
    func getArticles() {
        
        // Creat URL
        let feedURL:NSURL? = NSURL(string: feedURLString)
        
        // Listen to notification center
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "parserFinished", name: "feedHelperFinished", object: self.parser)
        
        // Kick off feed helper to parse NSURL
        self.parser.startParsing(feedURL!)
        
    }
    
    func parserFinished() {
        
        // Assign parsers list of articles to self.articles
        self.articles = self.parser.articles
        
        // Notify the view controller that the array of articles is ready
        
        // Check if there's an object assigned as the delegate
        // If so, call the articlesReady method on the delegate
        if let actualDelegate = self.delegate {
            actualDelegate.articlesReady()
        }
    }
    
}
