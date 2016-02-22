//
//  Parser.swift
//  PowerAPIApp
//
//  Copyright © 2016 Judge Madan. All rights reserved.
//

import Foundation
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
