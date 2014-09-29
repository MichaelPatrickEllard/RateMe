//
//  ViewController.swift
//  RateMe
//
//  Created by Rescue Mission Software on 9/27/14.
//  Copyright (c) 2014 Rescue Mission Software. All rights reserved.
//

import UIKit

// TODO: The URL for a sample rules file.  Replace this with the address of the rules file that you'll be using.
let rateRulesURL = "http://www.rescuemissionsoftware.com/XXXX0000/SimpleRuleYes.txt"

// TODO: The app ID for the Meetup app.  Replace this with the app ID for your app.
let appID = "375990038"

class ViewController: UIViewController, RateMeDelegate {
    
    @IBOutlet var rateButton: UIButton!
    
    let rateMeVC = RateMeViewController(rulesURL: rateRulesURL, appID: appID)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        rateButton.alpha = 0
        
        rateMeVC.delegate = self
        rateMeVC.checkRules()
        
    }

    @IBAction func rateButtonPressed(sender: AnyObject) {
        
        presentViewController(rateMeVC, animated: true, completion: nil)
        
    }
    
    //  Mark: RateMeDelegate Methods.  
    //  All of these methods are optional.  You don't have to implement any of them if you don't want to.
    
    func readyToRate() {
        
        UIView.animateWithDuration(2.0) {
            
            self.rateButton.alpha = 1
        
        }
        
        NSLog("RateMe View Controller is ready to rate")
        
    }
    
    func rulesRequestFailed(error : NSError!) {
        
        NSLog("The request for RateMe rules failed with the following error: %@", error)
        
    }
    
    func rated() {
        NSLog("User chose to rate the app.")
    }
    
    func askLater() {
        NSLog("User said to ask later")
    }
    
    func stopAsking() {
        NSLog("User said to stop asking")
    }

}

