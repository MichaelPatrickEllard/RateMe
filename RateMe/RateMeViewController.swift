//
//  RateMeViewController.swift
//  RateMe
//
//  Created by Rescue Mission Software on 9/27/14.
//  Copyright (c) 2014 Rescue Mission Software. All rights reserved.
//


import UIKit

class RateMeViewController: UIViewController {
    
    // MARK: Initializers & Deinitalizers
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // TODO: Update if needed
    }
    
    override init() {
        super.init(nibName: "RateMeViewController", bundle: NSBundle.mainBundle())
    }
    
    deinit {
        
        NSLog("OK, it's over.  This RateMe view controller instance is going away")
    }
    
    // MARK: View Controller Life-cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        NSLog("I am now showing a beautiful view controller")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Custom Methods
    
    class func shouldRate() -> Bool {
        return true
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }


}
