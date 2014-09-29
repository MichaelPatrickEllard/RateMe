//
//  RateMeViewController.swift
//  RateMe
//
//  Created by Rescue Mission Software on 9/27/14.
//  Copyright (c) 2014 Rescue Mission Software. All rights reserved.
//

@objc protocol RateMeDelegate {
    
    optional func readyToRate() -> ()
    optional func rated() -> ()
    optional func askLater() -> ()
    optional func stopAsking() -> ()
    
}

private enum RateMeNSCoderKeys : String {
    case URLString = "RateMeURLString"
    case AppID = "RateMeAppID"
    case Delegate = "RateMeDelegate"
}

// AskLater works out to zero, which is also what we'll get from NSUserDefaults is no rating has ever been set.  Arguably, it would be more Swift-like to have a distinction between "NeverRated" and "AskLater"


private enum RateMeRatingResponse : Int {
    case AskLater
    case Rated
    case StopAsking
}

private enum RateMeUserDefaultsKeys : String {
    case LastVersionRated = "RateMeLastVersionRated"
    case DateOfLastRating = "RateMeDateLastRated"
    case LastRatingResponse = "RateMeLastResponse"
}


import UIKit

class RateMeViewController: UIViewController, NSURLConnectionDataDelegate {
    
    // MARK: Instance Variables
    
    var rulesAllowRating : Bool? = nil

    var rulesURL : String

    weak var delegate : RateMeDelegate?
    
    var shouldRate : Bool {
        
        var returnValue = false
        
        if rulesUpdated && rulesAllowRating == .Some(true) {
            
            returnValue = true
        }
            
        return returnValue
    }
    
    private var rulesUpdated : Bool = false
    private var rulesData : NSMutableData!
    private var appID : String

    
    // MARK: Initializers & Deinitalizers
    
    // TODO: the methods for encoding and decoding the view controller should be tested.
    

    required init(coder aDecoder: NSCoder) {
        
        self.rulesURL = aDecoder.decodeObjectOfClass(NSString.classForCoder(), forKey: RateMeNSCoderKeys.URLString.toRaw()) as String
        self.appID = aDecoder.decodeObjectOfClass(NSString.classForCoder(), forKey: RateMeNSCoderKeys.AppID.toRaw()) as String
        self.delegate = aDecoder.decodeObjectForKey(RateMeNSCoderKeys.Delegate.toRaw()) as? RateMeDelegate

        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(self.rulesURL, forKey: RateMeNSCoderKeys.URLString.toRaw())
        aCoder.encodeObject(self.appID, forKey: RateMeNSCoderKeys.AppID.toRaw())
        
        if let rmDelegate = delegate {
            aCoder.encodeConditionalObject(rmDelegate, forKey: RateMeNSCoderKeys.Delegate.toRaw())
        }
    }
    
    init(rulesURL: String, appID: String) {
        
        self.rulesURL = rulesURL
        self.appID = appID
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
    
    @IBAction func rateApp() {
        
        NSLog("Now rating the app")
        
        let ratingAddress = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=" + appID
        
        //      The URL used above is the best choice for iOS 7.1 and iOS 8.
        //TODO: For iOS 7.0, this URL is recommended: "itms-apps://itunes.apple.com/app/id#########"
        
        let ratingURL = NSURL(string: ratingAddress)
        
        UIApplication.sharedApplication().openURL(ratingURL)
        
        recordRatingResponse(.Rated)
        dismiss()
        
        delegate?.rated?()
    }
    
    @IBAction func askLater() {
        
        NSLog("User said to ask later")
        recordRatingResponse(.AskLater)
        dismiss()
        
        delegate?.askLater?()
    }
    
    @IBAction func stopAsking() {
        
        NSLog("User said to stop asking")
        recordRatingResponse(.StopAsking)
        dismiss()
        
        delegate?.stopAsking?()
    }
    
    private func dismiss() {
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkRules() {
        
        let url = NSURL.URLWithString(rulesURL)
        
        //  Setting a shorter than usual timeout here.  We don't want to frustrate the user.  If we can't get the data in 10 seconds, we dont' want to bother them with a rating link which might take an extended amount of time to load.  Arguably, this timeout should be even shorter.
        
        let urlRequest = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        let connection = NSURLConnection(request: urlRequest, delegate: self)
        
    }
    
    private func recordRatingResponse(response: RateMeRatingResponse) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let device = UIDevice.currentDevice()
        
        let versionString = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String
        
        defaults.setObject(NSDate(), forKey: RateMeUserDefaultsKeys.DateOfLastRating.toRaw())
        defaults.setObject(versionString, forKey: RateMeUserDefaultsKeys.LastVersionRated.toRaw())
        defaults.setInteger(response.toRaw(), forKey: RateMeUserDefaultsKeys.LastRatingResponse.toRaw())
        
    }
    
    // MARK: NSURLConnectionDelegate and NSURLConnectionDataDelegate Methods
    
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
            
            delegate?.readyToRate?()
        }
        
    }
    
    func connection(connection: NSURLConnection!,
        didFailWithError error: NSError!) {
            NSLog("Bad news! The request for RateMe rules failed with the following error: %@", error)
    }


}
