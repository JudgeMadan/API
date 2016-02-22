//
//  PowerAPI.swift
//  PowerAPIApp
//
//  Copyright © 2016 Judge Madan. All rights reserved.
//

import UIKit
/*TODO:
- CHANGE NOTIFICATION WHEN FETCH TRANSCRIPT  TO DELEGATION 
- IMPLEMENT GETTERS AND SETTERS AND DOCUMENTATION
- DOCUMENATION + EXAMPLES
*/
/**
This class is a singleton meaning that only 1 instance ever exists while the application is running. Therefore, we can safetly have multiple viewcontrollers accessing it at once

Here is a rundown of the important variables:
* "studentInformation" variable is a dictionary of student related info (e.g. name, birthday, etc.)
* "sections" are all of the student's courses
* check out quickhelp/documentation for the "section" object to see what goodies are in there
*/
class PowerAPI: NSObject {
    static let sharedInstance = PowerAPI()
    private var _studentInformation = [String: String]()
    private var _sections = [Section]()
    let client = SoapClient()
    private override init(){
        super.init()
        //it would be a good idea to replace this notification with delegation since only powerapi needs to know difference between transcript fetch and parse
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "parseTranscript:", name:"transcript_fetched", object: nil)
    }
    ///Dictionary of Strings containing student information
    var studentInformation: [String: String]{
        return _studentInformation
    }
    ///An array of "Section" objects.  "Sections" are  just a name for courses - you will need to check if they're S1 or S2
    var sections: [Section]{
        return _sections
    }
    /**
    Authenticates the user with the username and password.  When authentication is finished, a notification is sent out under the title "authentication_finished".  If "fetchTranscript" parameter is set true, a notification "transcript_fetched" is sent out after the transcript has been fetched and parsed
    - parameter  url: The url of the powerschool server.
    - parameter  fetch_transcript: You can tell the api to automatically fetch and parse the user's transcript when finished authenicating (usually just set to true
    */
    func authenticate(var url:String, username: String,password: String,fetchTranscript: Bool){
        if url.substringFromIndex(url.endIndex.advancedBy(-1)) != "/" {
            url = url+"/"
        }
        //if user wants to also fetch transcript, do so right after authentication finishes
        if(fetchTranscript){
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchTranscript:", name:"authentication_finished", object: nil)
        }
        client.myAuthenticate(user: username,with: password) //for some reason "client.authenticate calls the wrong function"
    }
    //called when
    func fetchTranscript(){
        client.fetchTranscript()
    }
    func fetchTranscript(notification : NSNotification){
        fetchTranscript()
    }
    func parseTranscript(notification : NSNotification){
        //print(notification.object)
        do{
            let xmlDoc = try AEXMLDocument(xmlData: notification.object as! NSData)
            //print(xmlDoc.xmlString)
            let studentData = xmlDoc.root["soapenv:Body"]["ns:getStudentDataResponse"]["return"]["studentDataVOs"]
            self._studentInformation = Packager.information(studentData["student"])
            let assignmentCategories = Packager.assignmentCategories(studentData["assignmentCategories"])
            let assignmentScores = Packager.assignmentScores(studentData["assignmentScores"])
            let finalGrades = Packager.finalGrades(studentData["finalGrades"])
            let reportingTerms = Packager.reportingTerms(studentData["reportingTerms"])
            let teachers = Packager.teachers(studentData["teachers"])
            let assignments: [String: [Assignment]] = Packager.assignments(studentData["assignments"], assignmentCategories: assignmentCategories, assignmentScores: assignmentScores)
            self._sections = Packager.sections(studentData["sections"], assignments: assignments, finalGrades: finalGrades, reportingTerms: reportingTerms, teachers: teachers)
            //These notifications are part of the final design pattern (screw ios)
            NSNotificationCenter.defaultCenter().postNotificationName("transcript_parsed", object: true)
        }catch{
            NSNotificationCenter.defaultCenter().postNotificationName("transcript_parsed", object: false)
            print("\(error)")
        }
    }
}
