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

class ViewController: UIViewController {
    
    let rateMeVC = RateMeViewController(rulesURL: rateRulesURL, appID: appID)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        rateMeVC.checkRules()
    }

    @IBAction func rateButtonPressed(sender: AnyObject) {
        
        if rateMeVC.shouldRate {
            
            presentViewController(rateMeVC, animated: true, completion: nil)
            
        } else {
            
            NSLog("Sorry, but the Rate Me view controller told me not to rate at this time")
        }
        
    }

}

