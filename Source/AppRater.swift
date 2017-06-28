//
//  AppRater.swift
//  Asphalt
//
//  Created by Alexander Bekert on 13/01/15.
//  Copyright (c) 2015 Alexander Bekert. All rights reserved.
//

import Foundation


open class AppRater {

    open class func goToRatingPage() {
        
        let AppID = "935314042"
        let reviewUrlTemplate = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=APP_ID&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
        
        let urlString = reviewUrlTemplate.replacingOccurrences(of: "APP_ID", with: AppID)
        print("Processing to the App Store. URL: \(urlString)")
        if let url = URL(string: urlString) {
            UIApplication.shared.openURL(url)
            doNotShowDialogInFuture()
        }
    }
    
    fileprivate class func doNotShowDialogInFuture()
    {
        let key = AppRater.keyForCurrentVersion()
        UserDefaults.standard.set(true, forKey:key)
    }

    
    fileprivate class func keyForCurrentVersion() -> String
    {
        let base = "Do Not Show Rate Me Dialog For Version "

        if let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject {
            let appVersion = nsObject as! String
            return base + appVersion
        }
        
        return base
    }

    open class func shouldShowRateMeDialog() -> Bool
    {
        let key = AppRater.keyForCurrentVersion()
        return !UserDefaults.standard.bool(forKey: key)
    }

}
