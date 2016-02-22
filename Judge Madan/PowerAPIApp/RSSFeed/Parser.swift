//
//  Parser.swift
//  RSSFeed
//
//  Copyright (c) 2016 Judge Madan. All rights reserved.
//

import UIKit

class Parser: NSObject, NSXMLParserDelegate {
   
    var articles:[Article] = [Article] ()
    
    // Parser vars
    var currentElement:String = ""
    var foundCharacters:String = ""
    var currentArticle:Article = Article()
    
    override init() {        
        super.init()
    }
    
    func startParsing(feedURL:NSURL) {

        let feedParser:NSXMLParser? = NSXMLParser(contentsOfURL: feedURL)
        
        if let actualFeedParser = feedParser {
            actualFeedParser.delegate = self
            actualFeedParser.parse()
        }
    }
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        
        if elementName == "item" ||
            elementName == "title" ||
            elementName == "description" ||
            elementName == "link" ||
            elementName == "pubDate" {
                
                self.currentElement = elementName
        }
        
        if elementName == "item" {
            self.currentArticle = Article()
        }
        
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        
        if self.currentElement == "item" ||
            self.currentElement == "title" ||
            self.currentElement == "description" ||
            self.currentElement == "link" {
                
                self.foundCharacters += string!
        }
        
    }
    
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "title" {
            let title:String = foundCharacters.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            self.currentArticle.articleTitle = title
        }
            
        else if elementName == "description" {
            let description:String = foundCharacters.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            self.currentArticle.articleDescription = description
        }
            
            
        else if elementName == "link" {
            let link:String = foundCharacters.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            self.currentArticle.articleLink = link
        }
            
            
        else if elementName == "item" {
            self.articles.append(self.currentArticle)
            
        }
        
        self.foundCharacters = ""
        
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        // Use notification center to notify FeedModel
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName("feedHelperFinished", object: self)
    }
        
        
}
