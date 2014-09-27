//
//  ViewController.swift
//  RateMe
//
//  Created by Rescue Mission Software on 9/27/14.
//  Copyright (c) 2014 Rescue Mission Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

    @IBAction func rateButtonPressed(sender: AnyObject) {
        
        if RateMeViewController.shouldRate() {
            
            let rateMeVC = RateMeViewController()
            
            presentViewController(rateMeVC, animated: true, completion: nil)
            
        }
        
    }

}

