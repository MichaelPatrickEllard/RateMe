//
//  RateMeViewController.swift
//  RateMe
//
//  Created by Rescue Mission Software on 9/27/14.
//  Copyright (c) 2014 Rescue Mission Software. All rights reserved.
//

@objc protocol RateMeDelegate {
    
    optional func rulesRetrieved() -> ()
    optional func rulesRequestFailed(error : NSError!) -> ()
    optional func rated() -> ()
    optional func askLater() -> ()
    optional func stopAsking() -> ()
    
}

private enum RateMeNSCoderKeys : String {
    case URLString = "RateMeURLString"
    case AppID = "RateMeAppID"
    case Delegate = "RateMeDelegate"
}

private enum RateMeRatingResponse : Int {
    case NeverAsked = 0
    case AskLater
    case Rated
    case StopAsking
}

private enum RateMeUserDefaultsKeys : String {
    case LastVersionRated = "RateMeLastVersionRated"
    case DateOfLastRating = "RateMeDateLastRated"
    case LastRatingResponse = "RateMeLastResponse"
}

enum RateMeRulesStatus {
    case NotRequested
    case RequestInProgress
    case RulesReceived
    case RequestFailed
}


import UIKit

class RateMeViewController: UIViewController, NSURLConnectionDataDelegate {
    
    // MARK: Instance Variables
    
    private var rulesAllowRating : Bool? = nil
    private(set) var rulesStatus = RateMeRulesStatus.NotRequested
    private(set) var rulesReceivedTimestamp : NSDate? = nil
    
    private var rulesData : NSMutableData!
    
    var rulesURL : String

    weak var delegate : RateMeDelegate?
    
    let appID : String
    
    var minimumIntervalAfterAskLater : NSTimeInterval = 60 * 60 * 24 * 2       //  2 days in seconds
    var minimumIntervalAfterRating : NSTimeInterval = 60 * 60 * 24 * 30        //  30 days in seconds
    var minimumIntervalAfterStopAsking : NSTimeInterval = 60 * 60 * 24 * 90    //  90 days in seconds
    
    var shouldRate : Bool {
        
        var returnValue = false
        
        if rulesStatus == .RulesReceived && rulesAllowRating == .Some(true) {
            
            let currentVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String

            let defaults = NSUserDefaults.standardUserDefaults()
            
            let defaultsLastRatedVersion = defaults.objectForKey(RateMeUserDefaultsKeys.LastVersionRated.toRaw()) as String?
            
            //  Switch statements on tuples don't seem to like optionals. To make the code tidy, there has to be some string value for lastRatedVersion, even if it's an empty string. This doesn't feel Swift-like, and I would welcome suggestions about how to make it better.
            
            let lastRatedVersion = defaultsLastRatedVersion == nil ? "" : defaultsLastRatedVersion!
            
            let responseValueFromDefaults = defaults.integerForKey(RateMeUserDefaultsKeys.LastRatingResponse.toRaw())
            
            if let lastResponse = RateMeRatingResponse.fromRaw(responseValueFromDefaults) {
            
                switch (lastResponse, lastRatedVersion) {
                    
                    case (.NeverAsked, _):
                    
                        returnValue = true
                    
                    case (.AskLater, _):
                    
                        if sufficientTimeSinceLastResponse(minimumIntervalAfterAskLater) {
                            
                            returnValue = true
                        }
                    
                    case (.Rated, currentVersion), (.StopAsking, currentVersion):
                        
                        break   // Do nothing. Wait for a new version to ask again.
                    
                    case (.Rated, _):
                    
                        if sufficientTimeSinceLastResponse(minimumIntervalAfterRating) {
                            
                            returnValue = true
                        }
                    
                    case (.StopAsking, _):
                    
                        if sufficientTimeSinceLastResponse(minimumIntervalAfterStopAsking) {
                            
                            returnValue = true
                        }
                    
                }
                
            } else {
                
                NSLog("Unexpected Last Rating Response in NSUserDefaults of %ld", responseValueFromDefaults)
                
            }

        }
            
        return returnValue
    }

    
    // MARK: Initializers & Deinitalizers
    
    // TODO: the methods for encoding and decoding the view controller should be tested.
    

    required init(coder aDecoder: NSCoder) {
        
        self.rulesURL = aDecoder.decodeObjectOfClass(NSString.classForCoder(), forKey: RateMeNSCoderKeys.URLString.toRaw()) as String
        self.appID = aDecoder.decodeObjectOfClass(NSString.classForCoder(), forKey: RateMeNSCoderKeys.AppID.toRaw()) as String
        self.delegate = aDecoder.decodeObjectForKey(RateMeNSCoderKeys.Delegate.toRaw()) as RateMeDelegate?

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
        
        recordRatingResponse(.AskLater)
        dismiss()
        
        delegate?.askLater?()
    }
    
    @IBAction func stopAsking() {
        
        recordRatingResponse(.StopAsking)
        dismiss()
        
        delegate?.stopAsking?()
    }
    
    private func dismiss() {
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkRules() {
        
        switch (rulesStatus) {
            
            case .RequestInProgress:
                
                break   //  There's already a request going on.
                
            default:
                
                //  If we're starting a new rules request, let's forget about the results of any previous requests.
            
                rulesStatus = .RequestInProgress
                rulesAllowRating = nil
                rulesReceivedTimestamp = nil
                
                let url = NSURL.URLWithString(rulesURL)
                
                //  Setting a shorter than usual timeout here.  We don't want to frustrate the user.  If we can't get the data in 5 seconds, we dont' want to bother them with a rating link which might take longer than that to load.
                
                let urlRequest = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 5)
                
                let connection = NSURLConnection(request: urlRequest, delegate: self)
                
        }
        
    }
    
    private func recordRatingResponse(response: RateMeRatingResponse) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let device = UIDevice.currentDevice()
        
        let versionString = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String
        
        defaults.setObject(NSDate(), forKey: RateMeUserDefaultsKeys.DateOfLastRating.toRaw())
        defaults.setObject(versionString, forKey: RateMeUserDefaultsKeys.LastVersionRated.toRaw())
        defaults.setInteger(response.toRaw(), forKey: RateMeUserDefaultsKeys.LastRatingResponse.toRaw())
        
    }
    
    private func sufficientTimeSinceLastResponse(requiredTimeInterval: NSTimeInterval) -> Bool {
        
        var returnValue = false
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let lastResponseDate = defaults.objectForKey(RateMeUserDefaultsKeys.DateOfLastRating.toRaw()) as? NSDate {
            
            if NSDate().timeIntervalSinceDate(lastResponseDate) > requiredTimeInterval {
                
                returnValue = true
                
            }
            
        }
        
        return returnValue
        
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
        
        var error : NSError?
        
        let jsonObject : AnyObject? = NSJSONSerialization.JSONObjectWithData(rulesData, options:NSJSONReadingOptions.AllowFragments, error: &error)
        
        if error == nil {
            
            if let rulesDict = jsonObject as? NSDictionary {
                
                if let versionRules = rulesDict["shouldRateByAppVersion"] as? Dictionary<String, Bool> {
            
                    let appVersionString = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String
                    
                    //  If we have a rule for this specific version, use it.  Otherwise use the default rule.
            
                    let versionRuleForRating : Bool? = versionRules[appVersionString]
                    
                    if let versionRule = versionRuleForRating {
                        
                        rulesAllowRating = versionRule
                        
                    } else if let defaultRule = versionRules["default"] {
                        
                        rulesAllowRating = defaultRule
                        
                    } else {
                        
                        error = NSError(domain: "Getting Version Info from Rules Dictionary", code: 2, userInfo: rulesDict)
                    }
                    
                    if rulesAllowRating != nil {
                
                        rulesStatus = .RulesReceived
                        rulesReceivedTimestamp = NSDate()
                        
                    }
                    
                    if rulesAllowRating == .Some(true) {
                        delegate?.rulesRetrieved?()
                    }
                    
                } else {
                    
                    error = NSError(domain: "Parsing Rules Dictionary", code: 1, userInfo: rulesDict)
                    
                }
                
            }
            
        }
        
        if rulesStatus != .RulesReceived {  // We failed one of the tests above
            
            rulesStatus = .RequestFailed
            delegate?.rulesRequestFailed?(error)
            
        }
        
    }
    
    func connection(connection: NSURLConnection!,
        didFailWithError error: NSError!) {
            
            rulesStatus = .RequestFailed

            delegate?.rulesRequestFailed?(error)
    }


}
