//
//  AppRater.swift
//  Asphalt
//
//  Created by Alexander Bekert on 13/01/15.
//  Copyright (c) 2015 Alexander Bekert. All rights reserved.
//

import Foundation


public class AppRater {

    public class func goToRatingPage() {
        
        let AppID = "935314042"
        let reviewUrlTemplate = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=APP_ID&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
        
        let urlString = reviewUrlTemplate.stringByReplacingOccurrencesOfString("APP_ID", withString: AppID)
        println("Processing to the App Store. URL: \(urlString)")
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
            doNotShowDialogInFuture()
        }
    }
    
    private class func doNotShowDialogInFuture()
    {
        let key = AppRater.keyForCurrentVersion()
        NSUserDefaults.standardUserDefaults().setBool(true, forKey:key)
    }

    
    private class func keyForCurrentVersion() -> String
    {
        let base = "Do Not Show Rate Me Dialog For Version "

        if let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] {
            let appVersion = nsObject as String
            return base + appVersion
        }
        
        return base
    }

    public class func shouldShowRateMeDialog() -> Bool
    {
        let key = AppRater.keyForCurrentVersion()
        return !NSUserDefaults.standardUserDefaults().boolForKey(key)
    }

    
}
