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

        var needToReportScore = false
        
        if result > localBestResult {
            localBestResult = result
            needToReportScore = true
        }
        
        if result > todayBestResult {
            todayBestResult = result
            needToReportScore = true
        }
        
        if result > friendsTodayTop10.last?.score {
            needToReportScore = true
        }
        
        if result < previousResult {
            needToReportScore = false
        }
        
        previousResult = result
        
        if needToReportScore {
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
    
    static var globalAllTimeBestResult: Result {
        get {
            return Result.loadFromUserDefaultsForKey("Global AllTime Best");
        }
    }
    
    static var globalWeekBestResult: Result {
        get {
            return Result.loadFromUserDefaultsForKey("Global Week Best");
        }
    }
    
    static var globalTodayBestResult: Result {
        get {
            return Result.loadFromUserDefaultsForKey("Global Today Best");
        }
    }
    
    static var friendsAlltimeTop10: [Result] {
        get {
            if let data = NSUserDefaults.standardUserDefaults().objectForKey("Friendsonly Alltime Top 10") as? NSData {
                if let results = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Result] {
                    return results
                }
            }
            return []
        }
    }
    
    static var friendsWeekTop10: [Result] {
        get {
            if let data = NSUserDefaults.standardUserDefaults().objectForKey("Friendsonly Week Top 10") as? NSData {
                if let results = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Result] {
                    return results
                }
            }
            return []
        }
    }

    static var friendsTodayTop10: [Result] {
        get {
            if let data = NSUserDefaults.standardUserDefaults().objectForKey("Friendsonly Today Top 10") as? NSData {
                if let results = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Result] {
                    return results
                }
            }
            return []
        }
    }

}