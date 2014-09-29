
This project is a prototype of a rating request system.  

This rating request system has some of the features found in other rating request systems:

-   It checks for internet connectivity
-   It makes sure that users who have already rated the app are not asked again for the same version, or asked too soon for the next version.
-   It makes sure users who have declined to rate the app are not asked again for the same version, or asked too soon for the next version.
-   It makes sure that users who have asked to be reminded later, are not asked to soon.

One unique feature of this rating system is that it also checks a remote server for rules about rating, and makes sure that it is appropriate to rate.  You might want to set the server's rating rules to turn off ratings for an app if:

-   You have a new version coming out in a few days, and you'd rather wait to ask users to rate the new version
-   There is an unexpected problem with your app, and you don't want to encourage ratings for a buggy version
-   You need to withdraw an app from the store for a time, and there is no app to rate

RateMe is designed to be modular -- it shouldn't require significant changes to the rest of your code to incorporate the rating request system into your code.

Shortly before it is time to rate the app, the user should create an instance of the RateMeViewController, and run its checkRules() method.  This will ensure that it will have had a chance to check with the remote server before asking the user to rate the app.

There are two ways that you can know when it is time to rate.

-   You can call the shouldRate() method on the RateMeViewController to see if it is appropriate to ask the user to rate the app.
-   The RateMeViewController's optional delegate can wait for a readyToRate() callback from the RateMeViewController.  

This sample app takes the approach of waiting for the readyToRate() callback -- for most apps, it is more likely that they'll use the shouldRate() method.

The original version of this code was written at SwiftHack @GitHub on September 27, 2014.