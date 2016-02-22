//
//  ViewController.swift
//  PowerAPIApp
//
//  Copyright © 2016 Judge Madan. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let api = PowerAPI.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        userNameField.text = "15998"
        passwordField.text = "3454"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTranscript:", name:"transcript_parsed", object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func handleTranscript(notification : NSNotification){
        print("Student Information: \(api.studentInformation)\n")
        for section in api.sections {
            /*for assignment in section.assignments{
            print("Class: \(section.name), Name:\(assignment.name), Grade: \(assignment.percent)")
            }*/
            if section.finalGrades["S1"] != nil {
                print("Class: \(section.name), S1 Grade: "+section.finalGrades["S1"]!)
            }
            if section.finalGrades["S2"] != nil {
                print("Class: \(section.name), S2 Grade: "+section.finalGrades["S2"]!)
            }
        }
    }
    @IBAction func authenicate(sender: AnyObject) {
        //print("authenicating")
        api.authenticate("powerschool.isb.ac.th", username: userNameField.text!, password: passwordField.text!, fetchTranscript: true)
    }
    
}

