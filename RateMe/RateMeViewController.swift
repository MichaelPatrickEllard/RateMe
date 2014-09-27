//
//  RateMeViewController.swift
//  RateMe
//
//  Created by Rescue Mission Software on 9/27/14.
//  Copyright (c) 2014 Rescue Mission Software. All rights reserved.
//

enum RateMeNSCoderKeys : String {
    case URLString = "URLString"
}


import UIKit

class RateMeViewController: UIViewController, NSURLConnectionDataDelegate {
    
    // MARK: Instance Variables
    
    var rulesAllowRating : Bool? = nil

    var rulesURL : String
    
    var shouldRate : Bool {
        
        var returnValue = false
        
        if rulesUpdated && rulesAllowRating == .Some(true) {
            
            returnValue = true
        }
            
        return returnValue
    }
    
    private var rulesUpdated : Bool = false
    private var rulesData : NSMutableData!

    
    // MARK: Initializers & Deinitalizers
    
    // TODO: the methods for encoding and decoding the view controller should be tested.
    

    required init(coder aDecoder: NSCoder) {
        
        self.rulesURL = aDecoder.decodeObjectOfClass(NSString.classForCoder(), forKey: RateMeNSCoderKeys.URLString.toRaw()) as String
        
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(self.rulesURL, forKey: RateMeNSCoderKeys.URLString.toRaw())
    }
    
    init(rulesURL: String) {
        
        self.rulesURL = rulesURL
        
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
    
    @IBAction func dismiss(sender: AnyObject) {
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkRules() {
        
        let url = NSURL.URLWithString(rulesURL)
        
        let urlRequest = NSURLRequest(URL: url)
        
        let connection = NSURLConnection(request: urlRequest, delegate: self)
        
    }
    
    // MARK: NSURLConnectionDelegate && NSURLConnectionDataDelegate Methods
    
    func connection(connection: NSURLConnection!,
        didReceiveResponse response: NSURLResponse!) {
            
            rulesData = NSMutableData()
            
    }
    
    
    func connection(connection: NSURLConnection!,
        didReceiveData data: NSData!)
    {
        rulesData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        
        rulesUpdated = true
        
        let dataString = NSString(data: rulesData, encoding: 4)
        
        NSLog("I got the data!  It looks like this: '%@'", dataString)
        
        if dataString == "YES" {
            rulesAllowRating = true
        }
        
    }
    
    func connection(connection: NSURLConnection!,
        didFailWithError error: NSError!) {
            NSLog("Bad news! The request for RateMe rules failed with the following error: %@", error)
    }


}
