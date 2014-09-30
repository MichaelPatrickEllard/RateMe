
This project is a prototype of a rating request system.  

This rating request system has some of the features found in other rating request systems:

-   It checks for internet connectivity
-   It makes sure that users who have already rated the app are not asked again for the same version, or asked too soon for the next version.
-   It makes sure users who have declined to rate the app are not asked again for the same version, or asked too soon for the next version.
-   It makes sure that users who have asked to be reminded later are not asked too soon.

One unique feature of this rating system is that it also checks a remote server for rules about rating, and makes sure that it is appropriate to rate.  You might want to set the server's rating rules to turn off ratings for an app if:

-   You have a new version coming out in a few days, and you'd rather wait to ask users to rate the new version
-   There is an unexpected problem with your app, and you don't want to encourage ratings for a buggy version
-   You need to withdraw an app from the store for a time, and there is no app to rate

SampleRateMeRules.json is included in the project and is an example of what a rating file might look like:

    {"rulesVersion":"0.1",
        "shouldRateByAppVersion":{
        "1.0":true,
        "1.1":false,
        "default":true
        }
    }

This file indicates that rating requests:

-   Should be made for version 1.0
-   Should not be made for version 1.1
-   Should be made for any other version  

It is not necessary to specify individual versions, but you should always specify a default. Once you've specified a default, that will take care of all unspecified cases.

RateMe is designed to be modular -- it shouldn't require significant changes to the rest of your code to incorporate the rating request system into your code.

The expectation is is that your app will have particular conditions when rating requests are appropriate, and that these conditions are best identified by your app's own logic. Shortly before it is time to request a rating, the app should create an instance of the RateMeViewController and run its checkRules() method. This will ensure that it will have had a chance to check with the remote server before asking the user to rate the app.

When the conditions seem right for a rating request, your app should check the shouldRate calculated property on the RateMeViewController to see if it is appropriate to ask the user to rate the app.  shouldRate considers a variety of factors, such as:

-   Whether the app had internet access when checkRules() was run
-   Whether checkRules() completed successfully
-   How recently the user was last asked to rate the app
-   What the user's response was that last time he or she was asked to rate

If shouldRate returns true, then your app should present the RateMeViewController in order to request a rating.  It is expected that developers will customize the RateMeViewController.xib in order to create an interface that matches the rest of their app.  



The original version of this code was written at SwiftHack @GitHub on September 27, 2014.