//
//  ViewController.swift
//  RateMe
//
//  Created by Rescue Mission Software on 9/27/14.
//  Copyright (c) 2014 Rescue Mission Software. All rights reserved.
//

import UIKit

let rateRulesURL = "http://www.rescuemissionsoftware.com/XXXX0000/SimpleRuleYes.txt"
let doNotRateRulesURL = "http://www.rescuemissionsoftware.com/XXXX0000/SimpleRuleNo.txt"

class ViewController: UIViewController {
    
    let doNotRateVC = RateMeViewController(rulesURL: doNotRateRulesURL)
    let rateMeVC = RateMeViewController(rulesURL: rateRulesURL)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        rateMeVC.checkRules()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

    @IBAction func rateButtonPressed(sender: AnyObject) {
        
        if rateMeVC.shouldRate {
            
            presentViewController(rateMeVC, animated: true, completion: nil)
            
        } else {
            
            NSLog("Sorry, but the Rate Me view controller told me not to rate at this time")
        }
        
    }

}

