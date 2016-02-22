//
//  PowerAPIApp.swift
//  PowerAPIApp
//
//  Copyright © 2016 Judge Madan All rights reserved.
//

import Foundation
///This object represents a single assignment that teachers may give their students
class Assignment: NSObject{
    private var _category = String()
    private  var _assDescription = String()
    private  var _name = String()
    private  var _score = String?()
    private  var _percent = String?()
    ///Type of assignment e.g. Formative, Summative
    var category: String{
        return _category
    }
    ///Description of the assignment - sorry about name: "description" is an NSObject property so could not use
    var assDescription: String{
        return _assDescription
    }
    ///The name of the assignment
    var name: String{
        return _name
    }
    ///The lettermark the student received
    var score: String?{
        return _score
    }
    ///The percent score the student received
    var percent: String?{
        return _percent
    }
    init(details: [String: [String: String]?]){
        let category = details["category"]! as [String: String]!
        self._category = category["name"]!
        
        let assignment = details["assignment"]! as [String: String]!
        self._assDescription = assignment["description"]!
        
        self._name = assignment["name"]!
        
        if details["score"]! != nil {
            let score = details["score"]! as [String: String]!
            self._percent = score["percent"]!
            self._score = score["score"]!
        }else{
            self._percent = nil
            self._score = nil
        }
    }
}