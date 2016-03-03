//
//  MarkersLabelsAndColors.swift
//  Asphalt
//
//  Created by Alexander Bekert on 30/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import SpriteKit

// MARK: Achievements
extension Markers {
    
    private enum Scope {
        case week
        case today
        case alltime
    }
    
    internal func showAchievementForMarkerIfNeeded(marker marker: Marker) -> SKNode? {
        let number = marker.number
        
        var label : SKNode!
        
        // Debug info
//        if number == 3 {
//            label = theWorldRecordLabelWithName("Nickname")
//        } else if number == 4 {
//            label = thisWeekRecordLabelWithName("Nickname")
//        } else if number == 5 {
//            label = todayRecordLabelWithName("Nickname")
//        } else if number == 6 {
//            label = yourAlltimeBestLabel()
//        } else if number == 7 {
//            label = yourTodayBestLabel()
//        } else if number == 8 {
//            label = previousLabel()
//        } else if number == 9 {
//            label = friendsBestLabelWithName("Peter.Shardiko", scope: .alltime)
//        } else if number == 10 {
//            label = friendsBestLabelWithName("Peter.Shardiko", scope: .week)
//        } else if number == 11 {
//            label = friendsBestLabelWithName("Peter.Shardiko", scope: .today)
//        }
//
//        if label != nil {
//            return showAchievementLabel(label!, nearMarker: marker)
//        }

        if number == Results.globalAllTimeBestResult.score {
            label = theWorldRecordLabelWithName(Results.globalAllTimeBestResult.name)
        } else if number == Results.globalWeekBestResult.score {
            label = thisWeekRecordLabelWithName(Results.globalWeekBestResult.name)
        } else if number == Results.globalTodayBestResult.score {
            label = todayRecordLabelWithName(Results.globalTodayBestResult.name)
        } else if number == Results.localBestResult {
            label = yourAlltimeBestLabel()
        } else if number == Results.todayBestResult {
            label = yourTodayBestLabel()
        } else if number == Results.previousResult && Results.attempt > 0 {
            label = previousLabel()
        }

        if label != nil {
            return showAchievementLabel(label!, nearMarker: marker)
        }

        let friendsAlltimeResults = Results.friendsAlltimeTop10
        for result in friendsAlltimeResults {
            if number == result.score {
                label = friendsBestLabelWithName(result.name, scope: .alltime)
                return showAchievementLabel(label, nearMarker: marker)
            }
        }
        
        let friendsWeekResults = Results.friendsWeekTop10
        for result in friendsWeekResults {
            if number == result.score {
                label = friendsBestLabelWithName(result.name, scope: .week)
                return showAchievementLabel(label, nearMarker: marker)
            }
        }
        
        let friendsTodayResults = Results.friendsTodayTop10
        for result in friendsTodayResults {
            if number == result.score {
                label = friendsBestLabelWithName(result.name, scope: .today)
                return showAchievementLabel(label, nearMarker: marker)
            }
        }
        
        return nil
    }
    
    private func showAchievementLabel(label: SKNode, nearMarker marker: Marker) -> SKNode {
        let yPosition = marker.position.y - Marker.size.height * 0.1
        if marker.position.x <= 0 && marker.doubledMarker == nil ||
            marker.position.x > 0 && marker.doubledMarker != nil {
                label.position = CGPoint(x: (screenSize.width * 0.5 + marker.position.x) * 0.5, y: yPosition)
                label.zRotation = -0.2
                let freeSpace = (screenSize.width * 0.5) - marker.position.x - (Marker.size.width * 0.4)
                fitLabel(label, intoWidth: freeSpace)
        } else {
            label.position = CGPoint(x: (-screenSize.width * 0.5 + marker.position.x) * 0.5, y: yPosition)
            label.zRotation = 0.2
            let freeSpace = (screenSize.width * 0.5) + marker.position.x - (Marker.size.width * 0.4)
            fitLabel(label, intoWidth: freeSpace)
        }
        
        let layer = marker.parent!
        layer.zPosition = 5
        layer.addChild(label)
        
        labels.append(label)
        print("Add score label")
        return label
    }
    
    private func fitLabel(label: SKNode, intoWidth width: CGFloat) {
        let fullWidth = labelWidth(label)
        let aspectFit = width / fullWidth
        if aspectFit < 1 {
            label.setScale(aspectFit > 0.6 ? aspectFit : 0.6)
        }
    }
    
    private func labelWidth(label: SKNode) -> CGFloat {
        var maxWidth: CGFloat = 0
        for child in label.children {
            let node = child 
            if node.frame.size.width > maxWidth {
                maxWidth = node.frame.size.width
            }
        }
        return maxWidth
    }
    
    // MARK: Your Results

    private func yourAlltimeBestLabel() -> SKNode {
        let color = SKColor(red: 0.6, green: 1, blue: 0.6, alpha: 1)
        
        let labelNode = SKLabelNode(fontNamed: DisplayHelper.FontName)
        labelNode.text = NSLocalizedString("My all time best 1 row", comment: "My")
        labelNode.verticalAlignmentMode = .Bottom
        labelNode.horizontalAlignmentMode = .Center
        labelNode.fontColor = color
        
        let secondRow = labelNode.copy() as! SKLabelNode
        secondRow.text = NSLocalizedString("My all time best 2 row", comment: "best")
        secondRow.verticalAlignmentMode = .Top
        
        let node = SKNode()
        node.addChild(labelNode)
        node.addChild(secondRow)
        
        return node
    }
    
    private func yourTodayBestLabel() -> SKNode {
        let color = SKColor.whiteColor()

        let labelNode = SKLabelNode(fontNamed: DisplayHelper.FontName)
        labelNode.text = NSLocalizedString("My today best 1 row", comment: "My")
        labelNode.verticalAlignmentMode = .Center
        labelNode.horizontalAlignmentMode = .Center
        labelNode.fontColor = color
        
        let secondRow = labelNode.copy() as! SKLabelNode
        secondRow.text = NSLocalizedString("My today best 2 row", comment: "today's")
        
        let thirdRow = labelNode.copy() as! SKLabelNode
        thirdRow.text = NSLocalizedString("My today best 3 row", comment: "best")
        
        secondRow.position = CGPoint(x: 0, y: 0)
        labelNode.position = CGPoint(x: 0, y: secondRow.position.y + secondRow.frame.size.height / 2)
        labelNode.verticalAlignmentMode = .Bottom
        thirdRow.position = CGPoint(x: 0, y: secondRow.position.y + -secondRow.frame.size.height * 0.4)
        thirdRow.verticalAlignmentMode = .Top

        let node = SKNode()
        node.addChild(labelNode)
        node.addChild(secondRow)
        node.addChild(thirdRow)
        
        return node
    }
    
    private func previousLabel() -> SKNode {
        let color = SKColor.whiteColor()
        
        let labelNode = SKLabelNode(fontNamed: DisplayHelper.FontName)
        labelNode.text = NSLocalizedString("My previous result 1 row", comment: "Previous")
        labelNode.verticalAlignmentMode = .Bottom
        labelNode.horizontalAlignmentMode = .Center
        labelNode.fontColor = color
        
        let secondRow = labelNode.copy() as! SKLabelNode
        secondRow.text = NSLocalizedString("My previous result 2 row", comment: "result")
        secondRow.verticalAlignmentMode = .Top
        
        let node = SKNode()
        node.addChild(labelNode)
        node.addChild(secondRow)
        
        return node
    }
    
    // MARK: Friends Results
    
    private func friendsBestLabelWithName(name: String, scope: Scope) -> SKNode {
        let labelNode = SKLabelNode(fontNamed: DisplayHelper.FontName)
        let label = NSLocalizedString("My friend's nick-name", comment: "Friend's")
        labelNode.text = label.stringByReplacingOccurrencesOfString("%player%", withString: name)
        labelNode.verticalAlignmentMode = .Bottom
        labelNode.horizontalAlignmentMode = .Center
        
        let secondRow = labelNode.copy() as! SKLabelNode
        switch scope {
        case .today:
            let color = SKColor.whiteColor()
            secondRow.text = NSLocalizedString("today", comment: "today")
            labelNode.fontColor = color
            secondRow.fontColor = color
        case .week:
            let color = SKColor(red: 0.8, green: 1, blue: 0.8, alpha: 1)
            secondRow.text = NSLocalizedString("week", comment: "week")
            labelNode.fontColor = color
            secondRow.fontColor = color
        case .alltime:
            let color = SKColor(red: 0.6, green: 1, blue: 0.6, alpha: 1)
            secondRow.text = NSLocalizedString("all time", comment: "best")
            labelNode.fontColor = color
            secondRow.fontColor = color
        }
        secondRow.verticalAlignmentMode = .Top
        
        let node = SKNode()
        node.addChild(labelNode)
        node.addChild(secondRow)
        
        return node
    }

    // MARK: World Results
    
    private func theWorldRecordLabelWithName(name: String) -> SKNode {
        let color = SKColor(red: 1, green: 1, blue: 0.4, alpha: 1)

        let labelNode = SKLabelNode(fontNamed: DisplayHelper.FontName)
        labelNode.text = NSLocalizedString("The World Record of all time 1 row", comment: "the World")
        labelNode.verticalAlignmentMode = .Center
        labelNode.horizontalAlignmentMode = .Center
        labelNode.fontColor = color
        
        let secondRow = labelNode.copy() as! SKLabelNode
        secondRow.text = NSLocalizedString("The World Record of all time 2 row", comment: "Record by")
        
        let thirdRow = labelNode.copy() as! SKLabelNode
        thirdRow.text = name
        
        secondRow.position = CGPoint(x: 0, y: 0)
        labelNode.position = CGPoint(x: 0, y: secondRow.position.y + secondRow.frame.size.height / 2)
        labelNode.verticalAlignmentMode = .Bottom
        thirdRow.position = CGPoint(x: 0, y: secondRow.position.y - secondRow.frame.size.height * 0.4)
        thirdRow.verticalAlignmentMode = .Top

        let node = SKNode()
        node.addChild(labelNode)
        node.addChild(secondRow)
        node.addChild(thirdRow)

        let atlas = SKTextureAtlas(named: "Drawings")
        let cupTexture = atlas.textureNamed("the-world-cup")
        let cupNode = SKSpriteNode(texture: cupTexture)
        node.addChild(cupNode)
        
        return node
    }
    
    private func thisWeekRecordLabelWithName(name: String) -> SKNode {
        let labelNode = SKLabelNode(fontNamed: DisplayHelper.FontName)
        labelNode.text = NSLocalizedString("The World Record of the week 1 row", comment: "this week")
        labelNode.verticalAlignmentMode = .Center
        labelNode.horizontalAlignmentMode = .Center
        labelNode.fontColor = SKColor(red: 0.973, green: 0.97, blue: 0.775, alpha: 1)
        
        let secondRow = labelNode.copy() as! SKLabelNode
        secondRow.text = NSLocalizedString("The World Record of the week 2 row", comment: "best by")
        
        let thirdRow = labelNode.copy() as! SKLabelNode
        thirdRow.text = name
        
        secondRow.position = CGPoint(x: 0, y: 0)
        labelNode.position = CGPoint(x: 0, y: secondRow.position.y + secondRow.frame.size.height / 2)
        labelNode.verticalAlignmentMode = .Bottom
        thirdRow.position = CGPoint(x: 0, y: secondRow.position.y - secondRow.frame.size.height * 0.4)
        thirdRow.verticalAlignmentMode = .Top

        let node = SKNode()
        node.addChild(labelNode)
        node.addChild(secondRow)
        node.addChild(thirdRow)
        
        return node
    }

    private func todayRecordLabelWithName(name: String) -> SKNode {
        let labelNode = SKLabelNode(fontNamed: DisplayHelper.FontName)
        labelNode.text = NSLocalizedString("The World Record of today 1 row", comment: "today's")
        labelNode.verticalAlignmentMode = .Center
        labelNode.horizontalAlignmentMode = .Center
        labelNode.fontColor = SKColor(red: 0.973, green: 0.97, blue: 0.775, alpha: 1)
        
        let secondRow = labelNode.copy() as! SKLabelNode
        secondRow.text = NSLocalizedString("The World Record of today 2 row", comment: "best by")
        
        let thirdRow = labelNode.copy() as! SKLabelNode
        thirdRow.text = name
        
        secondRow.position = CGPoint(x: 0, y: 0)
        labelNode.position = CGPoint(x: 0, y: secondRow.position.y + secondRow.frame.size.height / 2)
        labelNode.verticalAlignmentMode = .Bottom
        thirdRow.position = CGPoint(x: 0, y: secondRow.position.y - secondRow.frame.size.height * 0.4)
        thirdRow.verticalAlignmentMode = .Top

        let node = SKNode()
        node.addChild(labelNode)
        node.addChild(secondRow)
        node.addChild(thirdRow)
        
        return node
    }
}

/*
// MARK: Markers color
extension Markers {
    internal func updateColor() {
        if colorAttributes == nil {
            if let path = NSBundle.mainBundle().pathForResource("Colors", ofType: "plist") {
                colorAttributes = NSArray(contentsOfFile: path)
            }
        }
        
        for element in colorAttributes {
            let dictionary = element as NSDictionary
            let number = Int(dictionary.objectForKey("Number") as NSNumber)
            if counter == number {
                let red = CGFloat(dictionary.objectForKey("Red") as NSNumber)
                let green = CGFloat(dictionary.objectForKey("Green") as NSNumber)
                let blue = CGFloat(dictionary.objectForKey("Blue") as NSNumber)
                
                color = SKColor(red: red, green: green, blue: blue, alpha: 1)
                println("New color with red: \(red), green: \(green), blue: \(blue)")
            }
        }
    }
}
*/