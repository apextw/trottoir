//
//  Achievements.swift
//  Asphalt
//
//  Created by Alexander Bekert on 15/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public struct Results {
    
    static func commitNewLocalBest(_ result: Int) {

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
    
    fileprivate static var _lastResultDescription: (firstRow: String, secondRow: String) = ("", "")
    
    public static var lastResultDescription: (firstRow: String, secondRow: String) {
        get {
            return _lastResultDescription
        }
    }
    
    fileprivate static func lastResultDescriptionForResult(_ score: Int) -> (firstRow: String, secondRow: String) {
//        return degugResult ();
        
        if score < 10 {
            return localizedResultDescriptionFor("Less than ten score", score: score)
        } else if score > Results.localBestResult {
            return resultDescriptionForNewLocalBestScore(score)
        } else {
            var choice : Int
            if todayBestResult == 0 {
                choice = Int(arc4random() % 2)
            } else {
                choice = Int(arc4random() % 3)
            }
            
            switch choice {
            case 0:
                return resultDescriptionInCompareToPreviousResult(score)
            case 1:
                return resultDescriptionInCompareToFriends(score)
            case 2:
                // Your today best
                if score >= todayBestResult {
                    return localizedResultDescriptionFor("Your best for today!")
                } else {
                    let difference = todayBestResult - score
                    return localizedResultDescriptionFor("More score to beat your today's best", score: difference)
                }
            default:
                break
            }
        }
        
        let difference = localBestResult - score
        return localizedResultDescriptionFor("More score to beat your highscore", score: difference)
    }
    
//    static private func degugResult() -> (firstRow: String, secondRow: String) {
        //        return ("many-many-many symbols", "");
        
        //        return localizedResultDescriptionFor("Less than ten score", score: score)
        //        return localizedResultDescriptionFor("Your best for today!")
        //        return localizedResultDescriptionFor("More score to beat your today's best", score: 43)
        //        return localizedResultDescriptionFor("More score to beat your highscore", score: 43)
        // World Records
        //        return localizedResultDescriptionFor("The World record for today!")
        //        return localizedResultDescriptionFor("The World record of the week!")
        //        return localizedResultDescriptionFor("The World Record of all time!")
        //        return localizedResultDescriptionFor("More score to beat the World record for today", score: 43)
        //        return localizedResultDescriptionFor("More score to beat the World record of the week", score: 43)
        //        return localizedResultDescriptionFor("More score to beat the World record of all time", score: 43)
        // Friends
        //        return localizedResultDescriptionFor("Higher than your friend's all time record", score: 43, player: "Peter.Shardiko")
        //        return localizedResultDescriptionFor("More score to beat your friend's all time record", score: 43, player: "Peter.Shardiko")
        //        return localizedResultDescriptionFor("Higher than your friend's week record", score: 43, player: "Peter.Shardiko")
        //        return localizedResultDescriptionFor("More score to beat your friend's week record", score: 43, player: "Peter.Shardiko")
        //        return localizedResultDescriptionFor("Higher than your friend's today record", score: 43, player: "Peter.Shardiko")
        //        return localizedResultDescriptionFor("More score to beat your friend's today record", score: 43, player: "Peter.Shardiko")
        
        //        return localizedResultDescriptionFor("Higher than your friend #1", player: "Peter.Shardiko")
        //        return localizedResultDescriptionFor("More score to beat your friend #1", score: 43, player: "Peter.Shardiko")
        //        return localizedResultDescriptionFor("Same as your friend #1", player: "Peter.Shardiko")
        //        return localizedResultDescriptionFor("Tell your friends about it")
        
        // Compare to previous result
        //        return localizedResultDescriptionFor("Breakthrough!")
        //        return localizedResultDescriptionFor("Much better than previous!")
        //        return localizedResultDescriptionFor("Better than previous!")
        //        return localizedResultDescriptionFor("Slightly better than previous!")
//                return localizedResultDescriptionFor("The same as before")
        //        return localizedResultDescriptionFor("More score to beat previous", score: 43)
//    }
    
    static fileprivate func localizedResultDescriptionFor(_ description: String, score: Int? = nil, player: String? = nil) -> (firstRow: String, secondRow: String) {
        if score == nil && player == nil {
            let firstRow = NSLocalizedString("Result 1 row: \(description)", comment: description)
            let secondRow = NSLocalizedString("Result 2 row: \(description)", comment: description)
            return (firstRow, secondRow)
        }
        
        var firstRow = NSLocalizedString("Result 1 row: \(description)", comment: description)
        var secondRow = NSLocalizedString("Result 2 row: \(description)", comment: description)

        if score != nil {
            firstRow = firstRow.replacingOccurrences(of: "%score%", with: score!.description)
            secondRow = secondRow.replacingOccurrences(of: "%score%", with: score!.description)
        }
        
        if player != nil {
            firstRow = firstRow.replacingOccurrences(of: "%player%", with: player!)
            secondRow = secondRow.replacingOccurrences(of: "%player%", with: player!)
        }
        
        return (firstRow, secondRow)
    }
    
    static fileprivate func resultDescriptionForNewLocalBestScore(_ score: Int) -> (firstRow: String, secondRow: String) {
        
        var choice = Int(arc4random() % 5)
        
        // If you have no friends — don't try to access them
        if friendsAlltimeTop10.count < 1 {
            choice = Int(arc4random() % 3)
        }

        switch choice {
        case 0:
            // Today world record
            let result = globalTodayBestResult
            if result.score > 0 && result.name != "" {
                if score >= result.score {
                    return localizedResultDescriptionFor("The World record for today!")
                } else {
                    let difference = result.score - score
                    return localizedResultDescriptionFor("More score to beat the World record for today", score: difference)
                }
            }
        case 1:
            // Week world record
            let result = globalWeekBestResult
            if result.score > 0 && result.name != "" {
                if score >= result.score {
                    return localizedResultDescriptionFor("The World record of the week!")
                } else {
                    let difference = result.score - score
                    return localizedResultDescriptionFor("More score to beat the World record of the week", score: difference)
                }
            }
        case 2:
            // All time world record
            let result = globalAllTimeBestResult
            if result.score > 0 && result.name != "" {
                if score >= result.score {
                    return localizedResultDescriptionFor("The World Record of all time!")
                } else {
                    let difference = result.score - score
                    return localizedResultDescriptionFor("More score to beat the World record of all time", score: difference)
                }
            }
        case 3:
            // Below your closest friend's all time record
            let closestFriends = resultsAboveAndBelowScore(score, fromResults: friendsAlltimeTop10)
            if let resultAbove = closestFriends.resultAbove {
                if resultAbove.score > score {
                    let difference = resultAbove.score - score
                    return localizedResultDescriptionFor("More score to beat your friend's all time record", score: difference, player: resultAbove.name)
                }
            }
            
        case 4:
            // Above your closest friend's all time record
            let closestFriends = resultsAboveAndBelowScore(score, fromResults: friendsAlltimeTop10)
            if let resultBelow = closestFriends.resultBelow {
                if resultBelow.score < score {
                    let difference = score - resultBelow.score
                    return localizedResultDescriptionFor("Higher than your friend's all time record", score: difference, player: resultBelow.name)
                }
            }
        default:
            break
        }
        
        return localizedResultDescriptionFor("Your new highscore!")
    }
    
    static fileprivate func resultDescriptionInCompareToPreviousResult(_ score: Int) -> (firstRow: String, secondRow: String) {
        let difference = score - previousResult
        if difference > 100 {
            return localizedResultDescriptionFor("Breakthrough!")
        } else if difference > 50 {
            return localizedResultDescriptionFor("Much better than previous!")
        } else if difference > 10 {
            return localizedResultDescriptionFor("Better than previous!")
        } else if difference > 0 {
            return localizedResultDescriptionFor("Slightly better than previous!")
        } else if difference == 0 {
            return localizedResultDescriptionFor("The same as before")
        } else {
            return localizedResultDescriptionFor("More score to beat previous", score: difference)
        }
    }
    
    static fileprivate func resultDescriptionInCompareToFriends(_ score: Int) -> (firstRow: String, secondRow: String) {
        if friendsTodayTop10.count > 1 {
            let closestFriends = resultsAboveAndBelowScore(score, fromResults: friendsTodayTop10)
            
            if Int(arc4random() % 2) == 0 && closestFriends.resultBelow != nil && closestFriends.resultBelow?.score < score {
                // Compare to friend below
                let difference = score - closestFriends.resultBelow!.score
                return localizedResultDescriptionFor("Higher than your friend's today record", score: difference, player: closestFriends.resultBelow!.name)
            } else if closestFriends.resultAbove != nil && closestFriends.resultAbove?.score > score {
                // Compare to friend above
                let difference = closestFriends.resultAbove!.score - score
                return localizedResultDescriptionFor("More score to beat your friend's today record", score: difference, player: closestFriends.resultAbove!.name)
            }
            
        } else if friendsWeekTop10.count > 1 {
            let closestFriends = resultsAboveAndBelowScore(score, fromResults: friendsWeekTop10)
            
            if Int(arc4random() % 2) == 0 && closestFriends.resultBelow != nil && closestFriends.resultBelow?.score < score {
                // Compare to friend below
                let difference = score - closestFriends.resultBelow!.score
                return localizedResultDescriptionFor("Higher than your friend's week record", score: difference, player: closestFriends.resultBelow!.name)
            } else if closestFriends.resultAbove != nil && closestFriends.resultAbove?.score > score {
                // Compare to friend above
                let difference = closestFriends.resultAbove!.score - score
                return localizedResultDescriptionFor("More score to beat your friend's week record", score: difference, player: closestFriends.resultAbove!.name)
            }
            
        } else if friendsAlltimeTop10.count > 1 {
            let closestFriends = resultsAboveAndBelowScore(score, fromResults: friendsAlltimeTop10)
            
            if Int(arc4random() % 2) == 0 && closestFriends.resultBelow != nil && closestFriends.resultBelow?.score < score {
                // Compare to friend below
                let difference = score - closestFriends.resultBelow!.score
                return localizedResultDescriptionFor("Higher than your friend's all time record", score: difference, player: closestFriends.resultBelow!.name)
            } else if closestFriends.resultAbove != nil && closestFriends.resultAbove?.score > score {
                // Compare to friend above
                let difference = closestFriends.resultAbove!.score - score
                return localizedResultDescriptionFor("More score to beat your friend's all time record", score: difference, player: closestFriends.resultAbove!.name)
            }
        } else if let friendNo1 = friendsAlltimeTop10.first {
            // Your friend number 1
            if friendNo1.score > 0 && friendNo1.name != "" {
                if score > friendNo1.score {
                    return localizedResultDescriptionFor("Higher than your friend #1", player: friendNo1.name)
                } else if score < friendNo1.score {
                    let difference = friendNo1.score - score
                    return localizedResultDescriptionFor("More score to beat your friend #1", score: difference, player: friendNo1.name)
                } else {
                    return localizedResultDescriptionFor("Same as your friend #1", player: friendNo1.name)
                }
            }
        }
        
        return localizedResultDescriptionFor("Tell your friends about it")
    }
    
    static fileprivate func resultsAboveAndBelowScore(_ score: Int, fromResults results: [Result]) -> (resultAbove: Result?, resultBelow: Result?) {
        var resultAbove: Result?
        var resultBelow: Result?
        for result in results {
            resultAbove = resultBelow
            resultBelow = result
            if resultBelow?.score < score {
                break
            }
        }
        return (resultAbove, resultBelow)
    }
    
    static var attempt = 0
    
    fileprivate static var _localBestResult: Int!
    
    static var localBestResult: Int {
        set {
            _localBestResult = newValue
            UserDefaults.standard.set(newValue, forKey: "localBestResult")
        }
        get {
            if _localBestResult == nil {
                _localBestResult = UserDefaults.standard.integer(forKey: "localBestResult")
            }
            
            return _localBestResult
        }
    }
    
    fileprivate static var _previousResult: Int!

    static var previousResult: Int {
        set {
            _previousResult = newValue
            UserDefaults.standard.set(newValue, forKey: "previousResult")
        }
        get {
            if _previousResult == nil {
                _previousResult = UserDefaults.standard.integer(forKey: "previousResult")
            }
            
            return _previousResult
        }
    }
    
    static var todayBestResult: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: "todayBestResult")
            UserDefaults.standard.set(Date(), forKey: "todayBestResultDate")
        }
        get {
            let resultDate: Date! = UserDefaults.standard.object(forKey: "todayBestResultDate") as! Date!
            if resultDate == nil {
                return 0
            }
            let yesterdaysBorder = Date(timeIntervalSinceNow: -3600 * 24)
            if yesterdaysBorder.compare(resultDate) != ComparisonResult.orderedDescending {
                return UserDefaults.standard.integer(forKey: "todayBestResult")
            } else {
                return 0
            }
        }
    }
    
    
    
    fileprivate static var _globalAllTimeBestResult: Result!
    
    static var globalAllTimeBestResult: Result {
        get {
            if _globalAllTimeBestResult == nil {
                _globalAllTimeBestResult = Result.loadFromUserDefaultsForKey("Global AllTime Best")
            }
            
            return _globalAllTimeBestResult
        }
        set {
            _globalAllTimeBestResult = newValue
            _globalAllTimeBestResult.saveToUserDefaultsWithKey("Global AllTime Best")
        }
    }
    
    
    
    fileprivate static var _globalWeekBestResult: Result!
    
    static var globalWeekBestResult: Result {
        get {
            if _globalWeekBestResult == nil {
                _globalWeekBestResult = Result.loadFromUserDefaultsForKey("Global Week Best")
            }
        
            return _globalWeekBestResult
        }
        set {
            _globalWeekBestResult = newValue
            _globalWeekBestResult.saveToUserDefaultsWithKey("Global Week Best")
        }
    }
    
    
    
    fileprivate static var _globalTodayBestResult: Result!
    
    static var globalTodayBestResult: Result {
        get {
            if _globalTodayBestResult == nil {
                _globalTodayBestResult = Result.loadFromUserDefaultsForKey("Global Today Best")
            }
        
            return _globalTodayBestResult
        }
        set {
            _globalTodayBestResult = newValue
            _globalTodayBestResult.saveToUserDefaultsWithKey("Global Today Best")
        }
    }
    
    
    
    fileprivate static var _friendsAlltimeTop10: [Result]!

    static var friendsAlltimeTop10: [Result] {
        get {
            if _friendsAlltimeTop10 == nil {
                _friendsAlltimeTop10 = loadResultListForKey("Friendsonly Alltime Top 10")
            }
        
            return _friendsAlltimeTop10
        }
        set {
            _friendsAlltimeTop10 = newValue
            saveResultList(newValue, withKey: "Friendsonly Alltime Top 10")
        }
    }
    

    
    fileprivate static var _friendsWeekTop10: [Result]!

    static var friendsWeekTop10: [Result] {
        get {
            if _friendsWeekTop10 == nil {
                _friendsWeekTop10 = loadResultListForKey("Friendsonly Week Top 10")
            }

            return _friendsWeekTop10
        }
        set {
            _friendsWeekTop10 = newValue
            saveResultList(newValue, withKey: "Friendsonly Week Top 10")
        }
    }

    
    
    fileprivate static var _friendsTodayTop10: [Result]!
    
    static var friendsTodayTop10: [Result] {
        get {
            if _friendsTodayTop10 == nil {
                _friendsTodayTop10 = loadResultListForKey("Friendsonly Today Top 10")
            }
            
            return _friendsTodayTop10
        }
        set {
            _friendsTodayTop10 = newValue
            saveResultList(newValue, withKey: "Friendsonly Today Top 10")
        }
    }
    
    
    
    fileprivate static func loadResultListForKey(_ key: String) -> [Result] {
        if let data = UserDefaults.standard.object(forKey: key) as? Data {
            if let results = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Result] {
                return results
            }
        }
        return []
    }
    
    fileprivate static func saveResultList(_ results: [Result], withKey key: String) {
        let data = NSKeyedArchiver.archivedData(withRootObject: results)
        UserDefaults.standard.set(data, forKey: key)
    }

}
