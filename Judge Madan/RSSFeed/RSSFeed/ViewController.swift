//
//  ViewController.swift
//  RSSFeed
//
//  Copyright (c) 2015 Judge Madan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FeedModelDelegate, UITableViewDelegate, UITableViewDataSource {

    let feedModel:FeedModel = FeedModel()
    var articles:[Article] = [Article]()
    var selectedArticle:Article?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.layoutMargins = UIEdgeInsetsZero
        
        
        self.feedModel.delegate = self
        
        // Request to download articles in background
        self.feedModel.getArticles()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func articlesReady() {
        self.articles = self.feedModel.articles
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as! UITableViewCell
        
        /* LAYOUT 1
        // Grab elements using the tag
        let label:UILabel? = cell.viewWithTag(1) as! UILabel?
        let label2:UILabel? = cell.viewWithTag(2) as! UILabel?
        let imageView:UIImageView? = cell.viewWithTag(3) as! UIImageView?
        let imageView2:UIImageView? = cell.viewWithTag(4) as! UIImageView?
        
        // Set properties
        let currentArticle:Article = self.articles[indexPath.row]

        if let titleLabel = label{
            titleLabel.text = currentArticle.articleTitle
        }
        
        if let descriptionLabel = label2 {
            descriptionLabel.text = currentArticle.articleDescription
        }        
        
        // Set insets to zero
        cell.layoutMargins = UIEdgeInsetsZero
        */
        
        let currentArticle:Article = self.articles[indexPath.row]
        cell.textLabel?.text = currentArticle.articleTitle
        cell.detailTextLabel?.text = currentArticle.articleDescription
        
    
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        // Keep track of which article the user selected
        self.selectedArticle = self.articles[indexPath.row]
        
        // Trigger the segue to go to the detail view
        self.performSegueWithIdentifier("toDetailSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get reference to destination view controller
        let detailVC = segue.destinationViewController as! DetailVC
        detailVC.displayedArticle = self.selectedArticle
        
        // Pass a long the selected article
    }
    
    
}