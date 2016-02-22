//
// AEXML.swift
//
// Copyright (c) 2014 Marko Tadić <tadija@me.com> http://tadija.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

/**
This is base class for holding XML structure.

You can access its structure by using subscript like this: `element["foo"]["bar"]` which would
return `<bar></bar>` element from `<element><foo><bar></bar></foo></element>` XML as an `AEXMLElement` object.
*/
public class AEXMLElement: NSObject {
    
    // MARK: Properties
    
    /// Every `AEXMLElement` should have its parent element instead of `AEXMLDocument` which parent is `nil`.
    public private(set) weak var parent: AEXMLElement?
    
    /// Child XML elements.
    public private(set) var children: [AEXMLElement] = [AEXMLElement]()
    
    /// XML Element name (defaults to empty string).
    public var name: String
    
    /// XML Element value.
    public var value: String?
    
    /// XML Element attributes (defaults to empty dictionary).
    public var attributes: [String : String]
    
    /// String representation of `value` property (if `value` is `nil` this is empty String).
    public var stringValue: String { return value ?? String() }
    
    /// String representation of `value` property with special characters escaped (if `value` is `nil` this is empty String).
    public var escapedStringValue: String {
        // we need to make sure "&" is escaped first. Not doing this may break escaping the other characters
        var escapedString = stringValue.stringByReplacingOccurrencesOfString("&", withString: "&amp;", options: .LiteralSearch)
        
        // replace the other four special characters
        let escapeChars = ["<" : "&lt;", ">" : "&gt;", "'" : "&apos;", "\"" : "&quot;"]
        for (char, echar) in escapeChars {
            escapedString = escapedString.stringByReplacingOccurrencesOfString(char, withString: echar, options: .LiteralSearch)
        }
        
        return escapedString
    }
    
    /// Boolean representation of `value` property (if `value` is "true" or 1 this is `True`, otherwise `False`).
    public var boolValue: Bool { return stringValue.lowercaseString == "true" || Int(stringValue) == 1 ? true : false }
    
    /// Integer representation of `value` property (this is **0** if `value` can't be represented as Integer).
    public var intValue: Int { return Int(stringValue) ?? 0 }
    
    /// Double representation of `value` property (this is **0.00** if `value` can't be represented as Double).
    public var doubleValue: Double { return (stringValue as NSString).doubleValue }
    
    private struct Defaults {
        static let name = String()
        static let attributes = [String : String]()
    }
    
    // MARK: Lifecycle
    
    /**
    Designated initializer - all parameters are optional.
    
    :param: name XML element name.
    :param: value XML element value
    :param: attributes XML element attributes
    
    :returns: An initialized `AEXMLElement` object.
    */
    public init(_ name: String? = nil, value: String? = nil, attributes: [String : String]? = nil) {
        self.name = name ?? Defaults.name
        self.value = value
        self.attributes = attributes ?? Defaults.attributes
    }
    
    // MARK: XML Read
    
    /// This element name is used when unable to find element.
    public static let errorElementName = "AEXMLError"
    
    // The first element with given name **(AEXMLError element if not exists)**.
    public subscript(key: String) -> AEXMLElement {
        if name == AEXMLElement.errorElementName {
            return self
        } else {
            let filtered = children.filter { $0.name == key }
            let errorElement = AEXMLElement(AEXMLElement.errorElementName, value: "element <\(key)> not found")
            return filtered.count > 0 ? filtered.first! : errorElement
        }
    }
    
    /// Returns all of the elements with equal name as `self` **(nil if not exists)**.
    public var all: [AEXMLElement]? { return parent?.children.filter { $0.name == self.name } }
    
    /// Returns the first element with equal name as `self` **(nil if not exists)**.
    public var first: AEXMLElement? { return all?.first }
    
    /// Returns the last element with equal name as `self` **(nil if not exists)**.
    public var last: AEXMLElement? { return all?.last }
    
    /// Returns number of all elements with equal name as `self`.
    public var count: Int { return all?.count ?? 0 }
    
    private func allWithCondition(fulfillCondition: (element: AEXMLElement) -> Bool) -> [AEXMLElement]? {
        var found = [AEXMLElement]()
        if let elements = all {
            for element in elements {
                if fulfillCondition(element: element) {
                    found.append(element)
                }
            }
            return found.count > 0 ? found : nil
        } else {
            return nil
        }
    }
    
    /**
    Returns all elements with given value.
    
    :param: value XML element value.
    
    :returns: Optional Array of found XML elements.
    */
    public func allWithValue(value: String) -> [AEXMLElement]? {
        let found = allWithCondition { (element) -> Bool in
            return element.value == value
        }
        return found
    }
    
    /**
    Returns all elements with given attributes.
    
    :param: attributes Dictionary of Keys and Values of attributes.
    
    :returns: Optional Array of found XML elements.
    */
    public func allWithAttributes(attributes: [String : String]) -> [AEXMLElement]? {
        let found = allWithCondition { (element) -> Bool in
            var countAttributes = 0
            for (key, value) in attributes {
                if element.attributes[key] == value {
                    countAttributes += 1
                }
            }
            return countAttributes == attributes.count
        }
        return found
    }
    
    // MARK: XML Write
    
    /**
    Adds child XML element to `self`.
    
    :param: child Child XML element to add.
    
    :returns: Child XML element with `self` as `parent`.
    */
    public func addChild(child: AEXMLElement) -> AEXMLElement {
        child.parent = self
        children.append(child)
        return child
    }
    
    /**
    Adds child XML element to `self`.
    
    :param: name Child XML element name.
    :param: value Child XML element value.
    :param: attributes Child XML element attributes.
    
    :returns: Child XML element with `self` as `parent`.
    */
    public func addChild(name name: String, value: String? = nil, attributes: [String : String]? = nil) -> AEXMLElement {
        let child = AEXMLElement(name, value: value, attributes: attributes)
        return addChild(child)
    }
    
    /// Removes `self` from `parent` XML element.
    public func removeFromParent() {
        parent?.removeChild(self)
    }
    
    private func removeChild(child: AEXMLElement) {
        if let childIndex = children.indexOf(child) {
            children.removeAtIndex(childIndex)
        }
    }
    
    private var parentsCount: Int {
        var count = 0
        var element = self
        while let parent = element.parent {
            count += 1
            element = parent
        }
        return count
    }
    
    private func indentation(var count: Int) -> String {
        var indent = String()
        while count > 0 {
            indent += "\t"
            count -= 1
        }
        return indent
    }
    
    /// Complete hierarchy of `self` and `children` in **XML** escaped and formatted String
    public var xmlString: String {
        var xml = String()
        
        // open element
        xml += indentation(parentsCount - 1)
        xml += "<\(name)"
        
        if attributes.count > 0 {
            // insert attributes
            for (key, value) in attributes {
                xml += " \(key)=\"\(value)\""
            }
        }
        
        if value == nil && children.count == 0 {
            // close element
            xml += " />"
        } else {
            if children.count > 0 {
                // add children
                xml += ">\n"
                for child in children {
                    xml += "\(child.xmlString)\n"
                }
                // add indentation
                xml += indentation(parentsCount - 1)
                xml += "</\(name)>"
            } else {
                // insert string value and close element
                xml += ">\(escapedStringValue)</\(name)>"
            }
        }
        
        return xml
    }
    
}

// MARK: -

/**
This class is inherited from `AEXMLElement` and has a few addons to represent **XML Document**.

XML Parsing is also done with this object.
*/
public class AEXMLDocument: AEXMLElement {
    
    private struct Defaults {
        static let version = 1.0
        static let encoding = "utf-8"
        static let standalone = "no"
        static let documentName = "AEXMLDocument"
    }
    
    /// Default options used by NSXMLParser
    public struct NSXMLParserOptions {
        var shouldProcessNamespaces = false
        var shouldReportNamespacePrefixes = false
        var shouldResolveExternalEntities = false
    }
    
    // MARK: Properties
    
    /// This is only used for XML Document header (default value is 1.0).
    public let version: Double
    
    /// This is only used for XML Document header (default value is "utf-8").
    public let encoding: String
    
    /// This is only used for XML Document header (default value is "no").
    public let standalone: String
    
    /// Options for NSXMLParser (default values are `false`)
    public let xmlParserOptions: NSXMLParserOptions
    
    /// Root (the first child element) element of XML Document **(AEXMLError element if not exists)**.
    private let errorElement = AEXMLElement(AEXMLElement.errorElementName, value: "XML Document must have root element.")
    public var root: AEXMLElement { return children.count == 1 ? children.first! : errorElement }
    
    // MARK: Lifecycle
    
    /**
    Designated initializer - Creates and returns XML Document object.
    
    :param: version Version value for XML Document header (defaults to 1.0).
    :param: encoding Encoding value for XML Document header (defaults to "utf-8").
    :param: standalone Standalone value for XML Document header (defaults to "no").
    :param: root Root XML element for XML Document (defaults to `nil`).
    :param: xmlParserOptions Options for NSXMLParser (defaults to `false` for all).
    
    :returns: An initialized XML Document object.
    */
    public init(version: Double = Defaults.version,
        encoding: String = Defaults.encoding,
        standalone: String = Defaults.standalone,
        root: AEXMLElement? = nil,
        xmlParserOptions: NSXMLParserOptions = NSXMLParserOptions())
    {
        // set document properties
        self.version = version
        self.encoding = encoding
        self.standalone = standalone
        self.xmlParserOptions = xmlParserOptions
        
        // init super with default name
        super.init(Defaults.documentName)
        
        // document has no parent element
        parent = nil
        
        // add root element to document (if any)
        if let rootElement = root {
            addChild(rootElement)
        }
    }
    
    /**
    Convenience initializer - used for parsing XML data (by calling `loadXMLData:` internally).
    
    :param: version Version value for XML Document header (defaults to 1.0).
    :param: encoding Encoding value for XML Document header (defaults to "utf-8").
    :param: standalone Standalone value for XML Document header (defaults to "no").
    :param: xmlData XML data to parse.
    :param: xmlParserOptions Options for NSXMLParser (defaults to `false` for all).
    
    :returns: An initialized XML Document object containing the parsed data. Throws error if the data could not be parsed.
    */
    public convenience init(version: Double = Defaults.version,
        encoding: String = Defaults.encoding,
        standalone: String = Defaults.standalone,
        xmlData: NSData,
        xmlParserOptions: NSXMLParserOptions = NSXMLParserOptions()) throws
    {
        self.init(version: version, encoding: encoding, standalone: standalone, xmlParserOptions: xmlParserOptions)
        try loadXMLData(xmlData)
    }
    
    // MARK: Read XML
    
    /**
    Creates instance of `AEXMLParser` (private class which is simple wrapper around `NSXMLParser`) and starts parsing the given XML data.
    
    :param: data XML which should be parsed.
    
    :returns: `NSError` if parsing is not successfull, otherwise `nil`.
    */
    public func loadXMLData(data: NSData) throws {
        children.removeAll(keepCapacity: false)
        let xmlParser = AEXMLParser(xmlDocument: self, xmlData: data)
        try xmlParser.parse()
    }
    
    // MARK: Override
    
    /// Override of `xmlString` property of `AEXMLElement` - it just inserts XML Document header at the beginning.
    public override var xmlString: String {
        var xml =  "<?xml version=\"\(version)\" encoding=\"\(encoding)\" standalone=\"\(standalone)\"?>\n"
        for child in children {
            xml += child.xmlString
        }
        return xml
    }
    
}

// MARK: -

private class AEXMLParser: NSObject, NSXMLParserDelegate {
    
    // MARK: Properties
    
    let xmlDocument: AEXMLDocument
    let xmlData: NSData
    
    var currentParent: AEXMLElement?
    var currentElement: AEXMLElement?
    var currentValue = String()
    var parseError: NSError?
    
    // MARK: Lifecycle
    
    init(xmlDocument: AEXMLDocument, xmlData: NSData) {
        self.xmlDocument = xmlDocument
        self.xmlData = xmlData
        currentParent = xmlDocument
        super.init()
    }
    
    // MARK: XML Parse
    
    func parse() throws {
        let parser = NSXMLParser(data: xmlData)
        parser.delegate = self
        
        parser.shouldProcessNamespaces = xmlDocument.xmlParserOptions.shouldProcessNamespaces
        parser.shouldReportNamespacePrefixes = xmlDocument.xmlParserOptions.shouldReportNamespacePrefixes
        parser.shouldResolveExternalEntities = xmlDocument.xmlParserOptions.shouldResolveExternalEntities
        
        let success = parser.parse()
        if !success {
            throw parseError ?? NSError(domain: "net.tadija.AEXML", code: 1, userInfo: nil)
        }
    }
    
    // MARK: NSXMLParserDelegate
    
    @objc func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentValue = String()
        currentElement = currentParent?.addChild(name: elementName, attributes: attributeDict)
        currentParent = currentElement
    }
    
    @objc func parser(parser: NSXMLParser, foundCharacters string: String) {
        currentValue += string
        let newValue = currentValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        currentElement?.value = newValue == String() ? nil : newValue
    }
    
    @objc func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentParent = currentParent?.parent
        currentElement = nil
    }
    
    @objc func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        self.parseError = parseError
    }
    
}//
//  PowerAPIApp.swift
//  PowerAPIApp
//
//  Copyright © 2016 Judge Madan. All rights reserved.
//

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
}//
//  Student.swift
//  PowerAPIApp
//
//  Copyright © 2016 Judge Madan. All rights reserved.
//
//Equivalent to the PHP PowerAPI "Parser" class
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
}//
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
//
//  Section.swift
//  PowerAPIApp
//
//  Copyright © 2016 Judge Madan. All rights reserved.
//

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
}//
//  Parser.swift
//  PowerAPIApp
//
//  1/25/16.
//  Copyright © 2016 Judge Madan. All rights reserved.
//

class SoapClient : NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate{
    var serviceTicket = String() //unique to implementation
    var userID = String()
    
    private func parse(data: NSData)->Bool {
        do{
            let xmlDoc = try AEXMLDocument(xmlData: data)
            //print(xmlDoc.xmlString)
            let userSession = xmlDoc.root["soapenv:Body"]["ns:loginResponse"]["return"]["userSessionVO"]
            serviceTicket = userSession["serviceTicket"].stringValue
            userID = userSession["userId"].stringValue
            print("TICKET: \(serviceTicket)\n")
            print("USER ID: \(userID)\n")
            return true
        }catch{
            print("Authentication XML Parse Failed with error: \(error)")
            return false
        }

        //print(elements.description)
    }
    //Below is the code for making requests
    func myAuthenticate(user username : String, with password : String){
        let soapString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:env=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:ns1=\"http://publicportal.rest.powerschool.pearson.com/xsd\"><env:Body><ns1:login><param0>\(username)</param0><param1>\(password)</param1><param2>2</param2></ns1:login></env:Body></env:Envelope>"
        soapCall(soapString, withNotification: "authentication_finished")
    }
    func fetchTranscript(){
        let soapString = "<?xml version='1.0' encoding='UTF-8'?> <env:Envelope xmlns:env=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:ns1=\"http://publicportal.rest.powerschool.pearson.com/xsd\"> <env:Body> <ns1:getStudentData> <param0> <userId>6356</userId> <serviceTicket>\(serviceTicket)</serviceTicket> <serverInfo> <apiVersion>2.2.2</apiVersion> </serverInfo> <serverCurrentTime>2012-12-26T21:47:23.792Z</serverCurrentTime> <userType>2</userType> </param0> <param1>\(userID)</param1> <param2> <includes>1</includes> </param2> </ns1:getStudentData> </env:Body> </env:Envelope>"
        soapCall(soapString, withNotification: "transcript_fetched")
    }
    func soapCall(soapString : String, withNotification notificationID : String){
        let url:NSURL = NSURL(string: "https://powerschool.isb.ac.th/pearson-rest/services/PublicPortalServiceJSON")!
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        request.setValue("application/soap+xml; charset=utf-8;action='http://publicportal.rest.powerschool.pearson.com/xsd#login'", forHTTPHeaderField: "Content-Type")
        request.setValue("\(soapString.characters.count)", forHTTPHeaderField: "Content-Length")
        //request.setValue("Basic cGVhcnNvbjptMGJBcFA1", forHTTPHeaderField: "Authorization")
        //request.setValue("PHP-SOAP/5.5.27", forHTTPHeaderField: "User-Agent")
        request.HTTPBody = soapString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            switch notificationID {
            case "authentication_finished":
                //NSString(data: data!, encoding: NSUTF8StringEncoding)! //used to return data from authentication
                let success = self.parse(data!) //notification object is true if success
                NSNotificationCenter.defaultCenter().postNotificationName(notificationID, object: success)
            case "transcript_fetched":
                NSNotificationCenter.defaultCenter().postNotificationName(notificationID, object: data)
            default:
                break
            }
        }
        task.resume()
    }
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        //print(challenge.protectionSpace.authenticationMethod)
        //below is the powerschool authentication - the credential storage persistence could get me into trouble
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential,NSURLCredential(user: "pearson", password: "m0bApP5", persistence: NSURLCredentialPersistence.None))
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        print("redirecting: \(request.description)");
        let newRequest : NSURLRequest? = request
        completionHandler(newRequest)
    }
}
