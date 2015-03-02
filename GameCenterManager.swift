//
//  GameCenterManager.swift
//  Asphalt
//
//  Created by Alexander Bekert on 29/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import GameKit
import UIKit
import SpriteKit

class GameCenterManager: NSObject, GKGameCenterControllerDelegate {
    
    var gameViewController: UIViewController!
    var enabled: Bool {
        return GKLocalPlayer.localPlayer().authenticated
    }
    
    class var sharedInstance: GameCenterManager {
        struct Singleton {
            static let instance = GameCenterManager()
        }
        
        return Singleton.instance
    }
    
    override init() {
        println("Init")
    }
    
    func autenticatePlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController : UIViewController!, error : NSError!) -> Void in
            //handle authentication
            if viewController != nil {
                println("Game Center: Need to Log In")
                if self.gameViewController != nil {
                    self.pauseCurrentScene()
                    self.gameViewController.presentViewController(viewController, animated: true, completion: nil)
                }
            } else if localPlayer.authenticated {
                println("Game Center: Successfully autenticated")
                self.updateResults()
                self.resumeCurrentScene()
            } else {
                println("Game Center: Autentication failed")
                self.resumeCurrentScene()
            }
        }
    }
    
    let defaultLeaderboardId = "trottoir.leaderboard"
    
    func presentGameCenterViewController() {
        // If player is not authenticated in Game Center — bring him to Game Center App
        if !self.enabled {
            UIApplication.sharedApplication().openURL(NSURL(string:"gamecenter:")!)
            return
        }
        
        if gameViewController == nil {
            return
        }
        
        pauseCurrentScene()
        
        // Present View Controller
        let gcvc = GKGameCenterViewController()
        gcvc.gameCenterDelegate = self
        gcvc.viewState = .Leaderboards
        gcvc.leaderboardIdentifier = defaultLeaderboardId
        gameViewController.presentViewController(gcvc, animated: true, completion: nil)
    }
    
    private func pauseCurrentScene() {
        let skView = self.gameViewController.view as SKView
        skView.paused = true
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.resumeCurrentScene()
        })
    }
    
    private func resumeCurrentScene() {
        let skView = self.gameViewController.view as SKView
        skView.paused = false
    }

    
    func reportScore(scoreValue: Int, completion: (() -> ())?) {
        let score = GKScore(leaderboardIdentifier: defaultLeaderboardId)
        score.value = Int64(scoreValue)
        score.context = 0
        GKScore.reportScores([score], withCompletionHandler: { (error) -> Void in
            if error == nil {
                println("Game Center: Score successfully reported")
            } else {
                println("Game Center: Score report failed. \(error.description)")
            }
            
            completion?()
        })
    }
        
    func updateResults() {
        GKLeaderboard.loadLeaderboardsWithCompletionHandler { (leaderboards, error) -> Void in
            if error != nil {
                println("Game Center: Leaderboards loading failed.  \(error.description)")
                return
            }
            
            println("Game Center: Successfully received leaderboards")
            for element in leaderboards {
                let leaderboard = element as GKLeaderboard
                if leaderboard.identifier == self.defaultLeaderboardId {
                    println("Game Center: Default leaderboard found")
                    self.retreiveDataFromLeaderboard(leaderboard as GKLeaderboard)
                    break
                }
            }
        }
    }
    
    private func retreiveDataFromLeaderboard(leaderboard: GKLeaderboard) {
        loadFriendsAlltimeTop10FromLeaderboard(leaderboard, completion: { () -> () in
            self.loadFriendsWeekTop10FromLeaderboard(leaderboard, completion: { () -> () in
                self.loadFriendsTodayTop10FromLeaderboard(leaderboard, completion: { () -> () in
                    self.loadGlobalTodayBestFromLeaderboard(leaderboard, completion: { () -> () in
                        self.loadGlobalWeekBestFromLeaderboard(leaderboard, completion: { () -> () in
                            self.loadGlobalAlltimeBestFromLeaderboard(leaderboard, completion: { () -> () in })
                        })
                    })
                })
            })
        })
    }
    
    private func loadGlobalAlltimeBestFromLeaderboard(leaderboard: GKLeaderboard, completion: () -> ()) {
        leaderboard.playerScope = .Global
        let range = NSRange(location: 1, length: 1)
        leaderboard.range = range
        leaderboard.timeScope = .AllTime
        leaderboard.loadScoresWithCompletionHandler { (scores, error) -> Void in
            if error != nil {
                println("Game Center: Error during receiving global alltime best.  \(error.description)")
                return
            }
            
            if let firstElement: AnyObject = scores?.first {
                let score = firstElement as GKScore
                let result = Result(score: score)
                result.saveToUserDefaultsWithKey("Global AllTime Best")
                println("Game Center: Successfully received global alltime best. It is \(result.score) by \(result.name)")
            } else {
                println("Game Center: Global alltime best does not exist")
            }
            
            completion()
        }
    }
    
    private func loadGlobalWeekBestFromLeaderboard(leaderboard: GKLeaderboard, completion: () -> ()) {
        leaderboard.playerScope = .Global
        let range = NSRange(location: 1, length: 1)
        leaderboard.range = range
        leaderboard.timeScope = .Week
        leaderboard.loadScoresWithCompletionHandler { (scores, error) -> Void in
            if error != nil {
                println("Game Center: Error during receiving global week best.  \(error.description)")
                return
            }
            
            if let firstElement: AnyObject = scores?.first {
                let score = firstElement as GKScore
                let result = Result(score: score)
                result.saveToUserDefaultsWithKey("Global Week Best")
                println("Game Center: Successfully received global week best. It is \(result.score) by \(result.name)")
            } else {
                println("Game Center: Global week best does not exist")
            }
            
            completion()
        }
    }
    
    private func loadGlobalTodayBestFromLeaderboard(leaderboard: GKLeaderboard, completion: () -> ()) {
        leaderboard.playerScope = .Global
        let range = NSRange(location: 1, length: 1)
        leaderboard.range = range
        leaderboard.timeScope = .Today
        leaderboard.loadScoresWithCompletionHandler { (scores, error) -> Void in
            if error != nil {
                println("Game Center: Error during receiving global today best.  \(error.description)")
                return
            }
            
            if let firstElement: AnyObject = scores?.first {
                let score = firstElement as GKScore
                let result = Result(score: score)
                result.saveToUserDefaultsWithKey("Global Today Best")
                println("Game Center: Successfully received global today best. It is \(result.score) by \(result.name)")
            } else {
                println("Game Center: Global today best does not exist")
            }
            
            completion()
        }
    }
    
    private func loadFriendsAlltimeTop10FromLeaderboard(leaderboard: GKLeaderboard, completion: () -> ()) {
        leaderboard.playerScope = .FriendsOnly
        let range = NSRange(location: 1, length: 10)
        leaderboard.range = range
        leaderboard.timeScope = .AllTime
        leaderboard.loadScoresWithCompletionHandler { (scores, error) -> Void in
            if error != nil {
                println("Game Center: Error during receiving friendsonly alltime best.  \(error.description)")
                return
            }
            
            var friendsResults: [Result] = []
            
            if scores != nil {
                for object in scores {
                    let score = object as GKScore
                    let result = Result(score: score)
                    let rank = score.rank
                    if result.name == GKLocalPlayer.localPlayer().alias {
                        println("Game Center: Friendsonly alltime Top 10. My place is #\(rank) with score \(result.score)")
                    } else {
                        friendsResults.append(result)
                        println("Game Center: Friendsonly alltime Top 10. #\(rank) is \(result.score) by \(result.name)")
                    }
                }
            }
            
            let data = NSKeyedArchiver.archivedDataWithRootObject(friendsResults)
            NSUserDefaults.standardUserDefaults().setObject(data, forKey: "Friendsonly Alltime Top 10")
            
            completion()
        }
    }
    
    private func loadFriendsWeekTop10FromLeaderboard(leaderboard: GKLeaderboard, completion: () -> ()) {
        leaderboard.playerScope = .FriendsOnly
        let range = NSRange(location: 1, length: 10)
        leaderboard.range = range
        leaderboard.timeScope = GKLeaderboardTimeScope.Week
        leaderboard.loadScoresWithCompletionHandler { (scores, error) -> Void in
            if error != nil {
                println("Game Center: Error during receiving friendsonly alltime best.  \(error.description)")
                return
            }
            
            var friendsResults: [Result] = []
            
            if scores != nil {
                for object in scores {
                    let score = object as GKScore
                    let result = Result(score: score)
                    let rank = score.rank
                    if result.name == GKLocalPlayer.localPlayer().alias {
                        println("Game Center: Friendsonly week Top 10. My place is #\(rank) with score \(result.score)")
                    } else {
                        friendsResults.append(result)
                        println("Game Center: Friendsonly week Top 10. #\(rank) is \(result.score) by \(result.name)")
                    }
                }
            }
            
            let data = NSKeyedArchiver.archivedDataWithRootObject(friendsResults)
            NSUserDefaults.standardUserDefaults().setObject(data, forKey: "Friendsonly Week Top 10")
            
            completion()
        }
    }
    
    private func loadFriendsTodayTop10FromLeaderboard(leaderboard: GKLeaderboard, completion: () -> ()) {
        leaderboard.playerScope = .FriendsOnly
        let range = NSRange(location: 1, length: 10)
        leaderboard.range = range
        leaderboard.timeScope = GKLeaderboardTimeScope.Today
        leaderboard.loadScoresWithCompletionHandler { (scores, error) -> Void in
            if error != nil {
                println("Game Center: Error during receiving friendsonly alltime best.  \(error.description)")
                return
            }
            
            var friendsResults: [Result] = []

            if scores != nil {
                for object in scores {
                    let score = object as GKScore
                    let result = Result(score: score)
                    let rank = score.rank
                    if result.name == GKLocalPlayer.localPlayer().alias {
                        println("Game Center: Friendsonly today Top 10. My place is #\(rank) with score \(result.score)")
                    } else {
                        friendsResults.append(result)
                        println("Game Center: Friendsonly today Top 10. #\(rank) is \(result.score) by \(result.name)")
                    }
                }
            }
            
            let data = NSKeyedArchiver.archivedDataWithRootObject(friendsResults)
            NSUserDefaults.standardUserDefaults().setObject(data, forKey: "Friendsonly Today Top 10")
            
            completion()
        }
    }


}


