//
//  Student.swift
//  PowerAPIApp
//
//  Copyright © 2016 Judge Madan. All rights reserved.
//
//Equivalent to the PHP PowerAPI "Parser" class
import Foundation
class Packager : NSObject {
    class func assignmentCategories(rawAssignmentCategories: AEXMLElement)->[String: [String: String]]{
        var assignmentCategories = [String: [String: String]]()
        for assignmentCategory in rawAssignmentCategories.all!{
            var dict = [String: String]()
            dict["abbreviation"] = assignmentCategory["abbreviation"].stringValue
            dict["description"] = assignmentCategory["description"].stringValue
            dict["id"] = assignmentCategory["id"].stringValue
            dict["name"] = assignmentCategory["name"].stringValue
            assignmentCategories[dict["id"]!]=dict
        }
        return assignmentCategories
    }
    class func assignmentScores(rawAssignmentScores: AEXMLElement)->[String: [String: String]]{
        var assignmentScores = [String: [String: String]]()
        for assignmentScore in rawAssignmentScores.all!{
            var dict = [String: String]()
            dict["assignmentId"] = assignmentScore["assignmentId"].stringValue
            dict["collected"] = assignmentScore["collected"].stringValue
            dict["comment"] = assignmentScore["comment"].stringValue
            dict["exempt"] = assignmentScore["exempt"].stringValue
            dict["id"] = assignmentScore["id"].stringValue
            dict["late"] = assignmentScore["late"].stringValue
            dict["letterGrade"] = assignmentScore["letterGrade"].stringValue
            dict["percent"] = assignmentScore["percent"].stringValue
            dict["score"] = assignmentScore["score"].stringValue
            dict["scoretype"] = assignmentScore["storeType"].stringValue
            assignmentScores[dict["assignmentId"]!]=dict
        }
        return assignmentScores
    }
    class func finalGrades(rawFinalGrades: AEXMLElement)->[String: [[String: String]]]{
        var finalGrades = [String: [[String: String]]]()//dictionary of array of dictionaries of strings - wtf
        for finalGrade in rawFinalGrades.all! {
            var dict = [String: String]()
            dict["dateStored"] = finalGrade["commentValue"].stringValue
            dict["dateStored"] = finalGrade["dateStored"].stringValue
            dict["grade"] = finalGrade["grade"].stringValue
            dict["id"] = finalGrade["id"].stringValue
            dict["percent"] = finalGrade["percent"].stringValue
            dict["reportingTermId"] = finalGrade["reportingTermId"].stringValue
            dict["sectionid"] = finalGrade["sectionid"].stringValue
            dict["storeType"] = finalGrade["storeType"].stringValue
            if(finalGrades[dict["sectionid"]!] == nil){
                finalGrades[dict["sectionid"]!] = [[String: String]]()
            }
            finalGrades[dict["sectionid"]!]!.append(dict)
        }
        return finalGrades
    }
    class func reportingTerms(rawReportingTerms: AEXMLElement)->[String: String]{
        var reportingTerms = [String: String]()//dictionary of dictionaries
        for reportingTerm in rawReportingTerms.all! {
            reportingTerms[reportingTerm["id"].stringValue]=reportingTerm["abbreviation"].stringValue
        }
        return reportingTerms
    }
    class func teachers(rawTeachers: AEXMLElement)->[String: [String: String]]{
        var teachers = [String: [String: String]]()//dictionary of dictionaries
        for teacher in rawTeachers.all! {
            var dict = [String: String]()
            dict["email"] = teacher["email"].stringValue
            dict["firstName"] = teacher["firstName"].stringValue
            dict["id"] = teacher["id"].stringValue
            dict["lastName"] = teacher["lastName"].stringValue
            dict["schoolPhone"] = teacher["schoolPhone"].stringValue
            teachers[dict["id"]!]=dict
        }
        return teachers
    }
    class func assignments(rawAssignments: AEXMLElement,assignmentCategories: [String: [String: String]],assignmentScores: [String: [String: String]])->[String: [Assignment]]{
        var assignments = [String: [Assignment]]() // Dictionary of arrays containing assignments - lol
        for assignment in rawAssignments.all! {
            assignments[assignment["sectionid"].stringValue] = [Assignment]()
            var assignmentDict = [String: String]()
            assignmentDict["abbreviation"] = assignment["abbreviation"].stringValue
            assignmentDict["assignmentid"] = assignment["assignmentid"].stringValue
            assignmentDict["categoryId"] = assignment["categoryId"].stringValue
            assignmentDict["description"] = assignment["description"].stringValue
            assignmentDict["dueDate"] = assignment["dueDate"].stringValue
            assignmentDict["id"] = assignment["id"].stringValue
            assignmentDict["includeinfinalgrades"] = assignment["includeinfinalgrades"].stringValue
            assignmentDict["name"] = assignment["name"].stringValue
            assignmentDict["publishDaysBeforeDue"] = assignment["publishDaysBeforeDue"].stringValue
            assignmentDict["publishonspecificdate"] = assignment["publishonspecificdate"].stringValue
            assignmentDict["publishscores"] = assignment["publishscores"].stringValue
            assignmentDict["sectionid"] = assignment["sectionid"].stringValue
            assignmentDict["type"] = assignment["type"].stringValue
            assignmentDict["weight"] = assignment["weight"].stringValue
            let elAssignment = Assignment(details: ["assignment": assignmentDict,
                "category": assignmentCategories[assignmentDict["categoryId"]!],
                "score": assignmentScores[assignmentDict["id"]!]])
            assignments[assignmentDict["sectionid"]!]?.append(elAssignment)
        }
        return assignments
    }
    class func sections(rawSections: AEXMLElement, assignments: [String: [Assignment]],finalGrades: [String: [[String: String]]], reportingTerms:[String: String], teachers: [String: [String: String]])->[Section]{
        var sections = [Section]()
        for section in rawSections.all! {
            let startDate = section["enrollments"]["startDate"].stringValue
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd\'T\'HH:mm:ss.SSSZ"
            let date = dateFormatter.dateFromString(startDate)
            if(date?.timeIntervalSince1970 > NSDate().timeIntervalSince1970){
                continue
            }
            var assignmentHolder = [Assignment]()
            if assignments[section["id"].stringValue] == nil{
                assignmentHolder = [Assignment]()
            }else{
                assignmentHolder = assignments[section["id"].stringValue]! as [Assignment]!
            }
            var finalGradesHolder = [[String: String]]()
            if finalGrades[section["id"].stringValue] == nil{
                finalGradesHolder = [[String: String]]()
            }else{
                finalGradesHolder = finalGrades[section["id"].stringValue]! as [[String: String]]!
            }
            let detailsArray: [String: Any] = ["assignments": assignmentHolder,
                "finalGrades": finalGradesHolder,
                "reportingTerms": reportingTerms,
                "section": section,
                "teacher": teachers[section["teacherID"].stringValue]! as [String: String]]
            let sect = Section(details: detailsArray)
            sections.append(sect)
        }
        sections.sortInPlace { $0.expression < $1.expression } //nifty swift sorting feature
        return sections
    }
    class func information(rawInformation: AEXMLElement)->[String: String]{
        var dict = [String: String]()
        dict["currentGPA"] = rawInformation["currentGPA"].stringValue
        dict["currentMealBalance"] = rawInformation["currentMealBalance"].stringValue
        dict["currentTerm"] = rawInformation["currentTerm"].stringValue
        dict["dcid"] = rawInformation["dcid"].stringValue
        dict["dob"] = rawInformation["dob"].stringValue
        dict["ethnicity"] = rawInformation["ethnicity"].stringValue
        dict["firstName"] = rawInformation["firstName"].stringValue
        dict["gender"] = rawInformation["gender"].stringValue
        dict["gradeLevel"] = rawInformation["gradeLevel"].stringValue
        dict["id"] = rawInformation["id"].stringValue
        dict["lastName"] = rawInformation["lastName"].stringValue
        dict["middleName"] = rawInformation["middleName"].stringValue
        dict["photoDate"] = rawInformation["photoDate"].stringValue
        dict["startingMealBalance"] = rawInformation["startingMealBalance"].stringValue
        return dict
    }
}