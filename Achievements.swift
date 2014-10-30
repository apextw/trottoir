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
        
        if result > globalTodayBestResult || result > friendsOnlyAllTimeBestResult.score {
            GameCenterManager.sharedInstance.reportScore(result, completion: { () -> () in
                GameCenterManager.sharedInstance.updateResults()
            })
        } else {
            GameCenterManager.sharedInstance.reportScore(result, completion: nil)
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
    
    static var globalAllTimeBestResult: Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("Global AllTime Best")
        }
    }
    
    static var globalWeekBestResult: Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("Global Week Best")
        }
    }
    
    static var globalTodayBestResult: Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("Global Today Best")
        }
    }

    static var friendsOnlyAllTimeBestResult: (score: Int, name: String) {
        get {
            let score = NSUserDefaults.standardUserDefaults().integerForKey("FriendsOnly AllTime Best Score")
            let name = NSUserDefaults.standardUserDefaults().objectForKey("FriendsOnly AllTime Best Name") as String?
            
            if name == nil {
                return (score, "")
            } else {
                return (score, name!)
            }
        }
    }
}