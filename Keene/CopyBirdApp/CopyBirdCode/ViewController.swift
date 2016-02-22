//
//  ViewController.swift
//  CopyBirdCode
//
//  Created by e2014785 on 1/14/16.
//  Copyright © 2016 e2014785. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    
    var fileReader = FileReader()
    //(<table id="tableStudentSchedMatrix".*<\/table>)
    
    @IBOutlet weak var webView: UIWebView!
    let bundle = NSBundle.mainBundle()
    
    let u = NSBundle.mainBundle().URLForResource("sched", withExtension:"html")
    var fileContent:String?
    
    var matches = [NSString()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSBundle.mainBundle().URLForResource("writeFile", withExtension:"html")
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
        
        
        fileContent = try? String(contentsOfURL: u!)
        matches = matchesForRegexInText("(<table id=\"tableStudentSchedMatrix\".*<\\/table>)", text: fileContent)
        
        
        compact(matches[0])
        //testcode
        
        
    }
    
    var compactString:String? = nil
    
    func compact(middle: NSString) {
        compactString = fileReader.readFileContent("top", typeOfResource: "txt") + (middle as String) + fileReader.readFileContent("closer", typeOfResource: "txt")
        
        fileReader.writeFileContent(compactString!, nameOfResource: "writeFile", typeOfResource: "html")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: NSRegularExpressionOptions.DotMatchesLineSeparators)
            let nsString = text as NSString
            let results = regex.matchesInString(text,
                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substringWithRange($0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
}

