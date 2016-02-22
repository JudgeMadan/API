//
//  Section.swift
//  PowerAPIApp
//
//  Copyright © 2016 Judge Madan. All rights reserved.
//

import Foundation
///This "Section" object is really just a course.  The
class Section: NSObject{
    private var _assignments = [Assignment]()
    private var _expression = String()
    private var _finalGrades = [String: String]() //confusing stuff right here
    private var _name = String()
    private var _roomName = String()
    private var _teacher = [String: String?]()
    ///An array of all the assignments in the section
    var assignments: [Assignment]{
        return _assignments
    }
    ///an expression that gives the period number and helps with sorting
    var expression: String{
        return _expression
    }
    //A dictionary of the section's final grades - semester 1 and 2 grades are stored in the "S1" and "S2" entries
    var finalGrades: [String: String]{
        return _finalGrades
    }
    ///The name of the course/section
    var name: String{
        return _name
    }
    ///Course's room name (if exists)
    var roomName: String{
        return _roomName
    }
    ///Dictionary containing teacher credentials
    var teacher: [String: String?]{
        return _teacher
    }
    init(details: [String: Any]){
        self._assignments = details["assignments"] as! [Assignment]
        self._expression = (details["section"]as! AEXMLElement)["expression"].stringValue
        self._name = (details["section"] as! AEXMLElement)["schoolCourseTitle"].stringValue
        if details["finalGrades"] != nil {
            for finalGrade in (details["finalGrades"] as! [[String: String]]){
                let reportingTerms = details["reportingTerms"] as! [String: String]
                self._finalGrades[reportingTerms[finalGrade["reportingTermId"]!]!] = finalGrade["percent"]
            }
        }
        _roomName = (details["section"] as! AEXMLElement)["roomName"].stringValue
        let teacher = details["teacher"] as! [String: String]
        self._teacher = ["firstName": teacher["firstName"],"lastName": teacher["lastName"],"email": teacher["email"],"schoolPhone": teacher["schoolPhone"]]
    }
    override init(){
        super.init()
    }
}