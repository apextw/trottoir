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
        return GKLocalPlayer.localPlayer().isAuthenticated
    }
    
    static let sharedInstance = GameCenterManager()
    
    override init() {
        print("Init")
    }
    
    func autenticatePlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController : UIViewController?, error : Error?) -> Void in
            //handle authentication
            if viewController != nil {
                print("Game Center: Need to Log In")
                if self.gameViewController != nil {
                    self.pauseCurrentScene()
                    self.gameViewController.present(viewController!, animated: true, completion: nil)
                }
            } else if localPlayer.isAuthenticated {
                print("Game Center: Successfully autenticated")
                self.updateResults()
                self.resumeCurrentScene()
            } else {
                print("Game Center: Autentication failed")
                self.resumeCurrentScene()
            }
        }
    }
    
    let defaultLeaderboardId = "trottoir.leaderboard"
    
    func presentGameCenterViewController() {
        // If player is not authenticated in Game Center — bring him to Game Center App
        if !self.enabled {
            UIApplication.shared.openURL(URL(string:"gamecenter:")!)
            return
        }
        
        if gameViewController == nil {
            return
        }
        
        pauseCurrentScene()
        
        // Present View Controller
        let gcvc = GKGameCenterViewController()
        gcvc.gameCenterDelegate = self
        gcvc.viewState = .leaderboards
        gcvc.leaderboardIdentifier = defaultLeaderboardId
        gameViewController.present(gcvc, animated: true, completion: nil)
    }
    
    fileprivate func pauseCurrentScene() {
        let skView = self.gameViewController.view as! SKView
        skView.isPaused = true
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameViewController.dismiss(animated: true, completion: { () -> Void in
            self.resumeCurrentScene()
        })
    }
    
    fileprivate func resumeCurrentScene() {
        let skView = self.gameViewController.view as! SKView
        skView.isPaused = false
    }

    
    func reportScore(_ scoreValue: Int, completion: (() -> ())?) {
        let score = GKScore(leaderboardIdentifier: defaultLeaderboardId)
        score.value = Int64(scoreValue)
        score.context = 0
        GKScore.report([score], withCompletionHandler: { (error) -> Void in
            if error == nil {
                print("Game Center: Score successfully reported")
            } else {
//                print("Game Center: Score report failed. \(error!.description)")
            }
            
            completion?()
        })
    }
        
    func updateResults() {
        GKLeaderboard.loadLeaderboards { (leaderboards, error) -> Void in
            if error != nil {
//                print("Game Center: Leaderboards loading failed.  \(error!.description)")
                return
            }
            
            print("Game Center: Successfully received leaderboards")
            for element in leaderboards! {
                let leaderboard = element
                if leaderboard.identifier == self.defaultLeaderboardId {
                    print("Game Center: Default leaderboard found")
                    self.retreiveDataFromLeaderboard(leaderboard as GKLeaderboard)
                    break
                }
            }
        }
    }
    
    fileprivate func retreiveDataFromLeaderboard(_ leaderboard: GKLeaderboard) {
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
    
    fileprivate func loadGlobalAlltimeBestFromLeaderboard(_ leaderboard: GKLeaderboard, completion: @escaping () -> ()) {
        leaderboard.playerScope = .global
        let range = NSRange(location: 1, length: 1)
        leaderboard.range = range
        leaderboard.timeScope = .allTime
        leaderboard.loadScores { (scores, error) -> Void in
            if error != nil {
//                print("Game Center: Error during receiving global alltime best.  \(error!.description)")
                return
            }
            
            if let score = scores?.first {
                let result = Result(score: score)
                result.saveToUserDefaultsWithKey("Global AllTime Best")
                print("Game Center: Successfully received global alltime best. It is \(result.score) by \(result.name)")
            } else {
                print("Game Center: Global alltime best does not exist")
            }
            
            completion()
        }
    }
    
    fileprivate func loadGlobalWeekBestFromLeaderboard(_ leaderboard: GKLeaderboard, completion: @escaping () -> ()) {
        leaderboard.playerScope = .global
        let range = NSRange(location: 1, length: 1)
        leaderboard.range = range
        leaderboard.timeScope = .week
        leaderboard.loadScores { (scores, error) -> Void in
            if error != nil {
//                print("Game Center: Error during receiving global week best.  \(error!.description)")
                return
            }
            
            if let score = scores?.first {
                let result = Result(score: score)
                Results.globalWeekBestResult = result
                print("Game Center: Successfully received global week best. It is \(result.score) by \(result.name)")
            } else {
                print("Game Center: Global week best does not exist")
            }
            
            completion()
        }
    }
    
    fileprivate func loadGlobalTodayBestFromLeaderboard(_ leaderboard: GKLeaderboard, completion: @escaping () -> ()) {
        leaderboard.playerScope = .global
        let range = NSRange(location: 1, length: 1)
        leaderboard.range = range
        leaderboard.timeScope = .today
        leaderboard.loadScores { (scores, error) -> Void in
            if error != nil {
//                print("Game Center: Error during receiving global today best.  \(error!.description)")
                return
            }
            
            if let score = scores?.first {
                let result = Result(score: score)
                Results.globalTodayBestResult = result
                print("Game Center: Successfully received global today best. It is \(result.score) by \(result.name)")
            } else {
                print("Game Center: Global today best does not exist")
            }
            
            completion()
        }
    }
    
    fileprivate func loadFriendsAlltimeTop10FromLeaderboard(_ leaderboard: GKLeaderboard, completion: @escaping () -> ()) {
        leaderboard.playerScope = .friendsOnly
        let range = NSRange(location: 1, length: 10)
        leaderboard.range = range
        leaderboard.timeScope = .allTime
        leaderboard.loadScores { (scores, error) -> Void in
            if error != nil {
//                print("Game Center: Error during receiving friendsonly alltime best.  \(error!.description)")
                return
            }
            
            var friendsResults: [Result] = []
            
            if scores != nil {
                for score in scores! {
                    let result = Result(score: score)
                    let rank = score.rank
                    if result.name == GKLocalPlayer.localPlayer().alias {
                        print("Game Center: Friendsonly alltime Top 10. My place is #\(rank) with score \(result.score)")
                    } else {
                        friendsResults.append(result)
                        print("Game Center: Friendsonly alltime Top 10. #\(rank) is \(result.score) by \(result.name)")
                    }
                }
            }
            
            Results.friendsAlltimeTop10 = friendsResults
            
            completion()
        }
    }
    
    fileprivate func loadFriendsWeekTop10FromLeaderboard(_ leaderboard: GKLeaderboard, completion: @escaping () -> ()) {
        leaderboard.playerScope = .friendsOnly
        let range = NSRange(location: 1, length: 10)
        leaderboard.range = range
        leaderboard.timeScope = GKLeaderboardTimeScope.week
        leaderboard.loadScores { (scores, error) -> Void in
            if error != nil {
//                print("Game Center: Error during receiving friendsonly alltime best.  \(error!.description)")
                return
            }
            
            var friendsResults: [Result] = []
            
            if scores != nil {
                for score in scores! {
                    let result = Result(score: score)
                    let rank = score.rank
                    if result.name == GKLocalPlayer.localPlayer().alias {
                        print("Game Center: Friendsonly week Top 10. My place is #\(rank) with score \(result.score)")
                    } else {
                        friendsResults.append(result)
                        print("Game Center: Friendsonly week Top 10. #\(rank) is \(result.score) by \(result.name)")
                    }
                }
            }
            
            Results.friendsWeekTop10 = friendsResults
            
            completion()
        }
    }
    
    fileprivate func loadFriendsTodayTop10FromLeaderboard(_ leaderboard: GKLeaderboard, completion: @escaping () -> ()) {
        leaderboard.playerScope = .friendsOnly
        let range = NSRange(location: 1, length: 10)
        leaderboard.range = range
        leaderboard.timeScope = GKLeaderboardTimeScope.today
        leaderboard.loadScores { (scores, error) -> Void in
            if error != nil {
//                print("Game Center: Error during receiving friendsonly alltime best.  \(error!.description)")
                return
            }
            
            var friendsResults: [Result] = []

            if scores != nil {
                for score in scores! {
                    let result = Result(score: score)
                    let rank = score.rank
                    if result.name == GKLocalPlayer.localPlayer().alias {
                        print("Game Center: Friendsonly today Top 10. My place is #\(rank) with score \(result.score)")
                    } else {
                        friendsResults.append(result)
                        print("Game Center: Friendsonly today Top 10. #\(rank) is \(result.score) by \(result.name)")
                    }
                }
            }
            
            Results.friendsTodayTop10 = friendsResults
            
            completion()
        }
    }


}


