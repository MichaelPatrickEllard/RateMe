//
//  ViewController.swift
//  RateMe
//
//  Created by Rescue Mission Software on 9/27/14.
//  Copyright (c) 2014 Rescue Mission Software. All rights reserved.
//

import UIKit

// TODO: The URL for a sample rules file.  Replace this with the address of the rules file that you'll be using.
let rateRulesURL = "http://www.rescuemissionsoftware.com/XXXX0000/SimpleRuleNo.txt"

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
    
    // Mark: RateMeDelegate Methods
    
    func readyToRate() {
        
        UIView.animateWithDuration(2.0) {
            
            self.rateButton.alpha = 1
        
        }
        
    }

}

