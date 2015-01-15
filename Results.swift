//
//  Achievements.swift
//  Asphalt
//
//  Created by Alexander Bekert on 15/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import Foundation

public struct Results {
    
    static func commitNewLocalBest(result: Int) {

        _lastResultDescription = lastResultDescriptionForResult(result)
        
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
    
    private static var _lastResultDescription: String = ""
    
    public static var lastResultDescription: String {
        get {
            return _lastResultDescription
        }
    }
    
    private static func lastResultDescriptionForResult(score: Int) -> String {
        if score > Results.localBestResult {
            let choise = Int(arc4random() % 3)
            println(choise)
            switch choise {
            case 0:
                let result = globalTodayBestResult
                if result.score > 0 && result.name != "" {
                    if score >= result.score {
                        return "World record for today!"
                    } else {
                        let difference = result.score - score
                        return "\(difference) more to beat today's world"
                    }
                }
            case 1:
                let result = globalWeekBestResult
                if result.score > 0 && result.name != "" {
                    if score >= result.score {
                        return "New record of the week!"
                    } else {
                        let difference = result.score - score
                        return "\(difference) more to beat global week"
                    }
                }
            case 2:
                let result = globalAllTimeBestResult
                if result.score > 0 && result.name != "" {
                    if score >= result.score {
                        return "New World Record!"
                    } else {
                        let difference = result.score - score
                        return "\(difference) more to beat the World #1"
                    }
                }
            default:
                return "Your new highscore!"
            }
            return "Your new highscore!"
        } else {
            let choise = Int(arc4random() % 4)
            println(choise)
            switch choise {
            case 0:
                if score >= todayBestResult {
                    return "Your best for today!"
                } else {
                    let difference = todayBestResult - score
                    return "\(difference) more to beat today's best"
                }
            case 1:
                if score > previousResult {
                    return "Better than previous!"
                } else if score == previousResult {
                    return "Just like result before"
                } else {
                    let difference = previousResult - score
                    return "\(difference) more to beat previous"
                }
            case 2:
                if let friendNo1 = friendsAlltimeTop10.first {
                    if friendNo1.score > 0 && friendNo1.name != "" {
                        if score > friendNo1.score {
                            return "Better than \(friendNo1.name)"
                        } else if score < friendNo1.score {
                            let difference = friendNo1.score - score
                            return "\(difference) more to beat \(friendNo1.name)"
                        } else {
                            return "Same as \(friendNo1)"
                        }
                    }
                }
                
                let difference = localBestResult - score
                return "\(difference) more to beat your high"
            default:
                let difference = localBestResult - score
                return "\(difference) more to beat your high"
            }
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