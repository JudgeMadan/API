//
//  SwiftFileReader.swift
//  CopyBirdCode
//
//  Created by e2014785 on 1/15/16.
//  Copyright © 2016 e2014785. All rights reserved.
//

import Foundation

class FileReader {
    
    var bundle = NSBundle.mainBundle()

   
    func readFileContent(nameOfResource: String, typeOfResource: String) -> String {
        
        var path = bundle.pathForResource(nameOfResource, ofType: "txt")
        
        var fileContent: String? = nil;
        
        do {
            fileContent = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            
            
            
        } catch _ as NSError {
            
            print("Error")
        }
    
     
        return fileContent!
    }
    
    
    func writeFileContent(writingContent: String, nameOfResource: String, typeOfResource: String) {
        var error: NSError?
        
        do {
        try writingContent.writeToFile(bundle.pathForResource(nameOfResource, ofType: typeOfResource)!, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            
        }
    }

    
    func writeFileContent(writingContent: String, nameOfResource: String, typeOfResource: String, printResult: Bool) {
        var error: NSError?
        
        do {
            try writingContent.writeToFile(bundle.pathForResource(nameOfResource, ofType: typeOfResource)!, atomically: true, encoding: NSUTF8StringEncoding)
            
            
        } catch {
            
        }
    }
    
    
    
}