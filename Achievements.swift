//
//  Achievements.swift
//  Asphalt
//
//  Created by Alexander Bekert on 15/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import Foundation

struct Results {
    
    static func commitNewLocalBest(result: Int) {
        previousResult = result

        if result > localBestResult {
            localBestResult = result
        }
        
        if result > todayBestResult {
            todayBestResult = result
        }
    }
    
    static var localBestResult: Int {
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "localBestResult")
        }
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("localBestResult")
        }
    }
    
    static var previousResult: Int {
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "previousResult")
        }
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("previousResult")
        }
    }
    
    static var todayBestResult: Int {
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "todayBestResult")
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "todayBestResultDate")
        }
        get {
            let resultDate: NSDate! = NSUserDefaults.standardUserDefaults().objectForKey("todayBestResultDate") as NSDate!
            if resultDate == nil {
                return 0
            }
            let yesterdaysBorder = NSDate(timeIntervalSinceNow: -3600 * 24)
            if yesterdaysBorder.compare(resultDate) != NSComparisonResult.OrderedDescending {
                return NSUserDefaults.standardUserDefaults().integerForKey("todayBestResult")
            } else {
                return 0
            }
        }
    }
    
    static var attempt = 0
}