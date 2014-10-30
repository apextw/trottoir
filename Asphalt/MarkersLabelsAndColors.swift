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
    internal func showAchievementForMarkerIfNeeded(#marker: Marker) -> SKNode? {
        let number = marker.number
        var label: SKNode? = nil
        
        if number == Results.localBestResult {
            label = localBestLabel()
        } else if number == Results.globalAllTimeBestResult {
            label = theWorldRecordLabel()
        } else if number == Results.friendsOnlyAllTimeBestResult.score {
            label = friendsBestLabelWithName(Results.friendsOnlyAllTimeBestResult.name)
        } else if number == Results.globalWeekBestResult {
            label = thisWeekRecordLabel()
        } else if number == Results.globalTodayBestResult {
            label = todayRecordLabel()
        } else if number == Results.todayBestResult {
            label = yourTodayBestLabel()
        } else if number == Results.previousResult {
            label = previousLabel()
        }
        
        if label != nil {
            return showAchievementLabel(label!, nearMarker: marker)
        }

        return nil
    }
    
    private func showAchievementLabel(label: SKNode, nearMarker marker: Marker) -> SKNode {
        let xShift = screenSize.width * 0.5 - border
        if marker.position.x <= 0 && marker.doubledMarker == nil ||
            marker.position.x > 0 && marker.doubledMarker != nil {
                label.position = CGPoint(x: (screenSize.width * 0.5 + marker.position.x) * 0.5, y: marker.position.y)
                label.zRotation = -0.2
        } else {
            label.position = CGPoint(x: (-screenSize.width * 0.5 + marker.position.x) * 0.5, y: marker.position.y)
            label.zRotation = 0.2
        }
        
        let layer = marker.parent!
        layer.addChild(label)
        
        labels.append(label)
        println("Add your best label")
        return label
    }
    
    private func localBestLabel() -> SKNode {
        let labelNode = SKLabelNode(fontNamed: "Chalkduster")
        labelNode.text = "Your"
        labelNode.verticalAlignmentMode = .Bottom
        labelNode.horizontalAlignmentMode = .Center
        
        let secondRow = labelNode.copy() as SKLabelNode
        secondRow.text = "best"
        secondRow.verticalAlignmentMode = .Top
        
        let node = SKNode()
        node.addChild(labelNode)
        node.addChild(secondRow)
        
        return node
    }
    
    private func yourTodayBestLabel() -> SKNode {
        let labelNode = SKLabelNode(fontNamed: "Chalkduster")
        labelNode.text = "Your"
        labelNode.verticalAlignmentMode = .Center
        labelNode.horizontalAlignmentMode = .Center
        labelNode.position = CGPoint(x: 0, y: labelNode.frame.size.height * 0.85)
        
        let secondRow = labelNode.copy() as SKLabelNode
        secondRow.text = "today"
        secondRow.verticalAlignmentMode = .Center
        secondRow.position = CGPoint(x: 0, y: 0)
        
        let thirdRow = labelNode.copy() as SKLabelNode
        thirdRow.text = "best"
        thirdRow.verticalAlignmentMode = .Center
        thirdRow.position = CGPoint(x: 0, y: -labelNode.frame.size.height * 0.7)
        
        let node = SKNode()
        node.addChild(labelNode)
        node.addChild(secondRow)
        node.addChild(thirdRow)
        
        return node
    }
    
    private func previousLabel() -> SKNode {
        let labelNode = SKLabelNode(fontNamed: "Chalkduster")
        labelNode.fontSize = 25
        labelNode.text = "Previous"
        labelNode.verticalAlignmentMode = .Center
        labelNode.horizontalAlignmentMode = .Center
        
        return labelNode
    }
    
    private func theWorldRecordLabel() -> SKNode {
        let labelNode = SKLabelNode(fontNamed: "Chalkduster")
        labelNode.text = "The"
        labelNode.verticalAlignmentMode = .Center
        labelNode.horizontalAlignmentMode = .Center
        labelNode.position = CGPoint(x: 0, y: labelNode.frame.size.height * 0.85)
        labelNode.fontColor = SKColor(red: 0.973, green: 0.97, blue: 0.775, alpha: 1)
        
        let secondRow = labelNode.copy() as SKLabelNode
        secondRow.text = "World"
        secondRow.position = CGPoint(x: 0, y: 0)
        
        let thirdRow = labelNode.copy() as SKLabelNode
        thirdRow.text = "Record"
        thirdRow.position = CGPoint(x: 0, y: -labelNode.frame.size.height * 0.6)
        
        let node = SKNode()
        node.addChild(labelNode)
        node.addChild(secondRow)
        node.addChild(thirdRow)
        
        return node
    }

    private func friendsBestLabelWithName(name: String) -> SKNode {
        let labelNode = SKLabelNode(fontNamed: "Chalkduster")
        labelNode.text = "\(name)'s"
        labelNode.verticalAlignmentMode = .Bottom
        labelNode.horizontalAlignmentMode = .Center
        
        let secondRow = labelNode.copy() as SKLabelNode
        secondRow.text = "best"
        secondRow.verticalAlignmentMode = .Top
        
        let node = SKNode()
        node.addChild(labelNode)
        node.addChild(secondRow)
        
        return node
    }
    
    private func thisWeekRecordLabel() -> SKNode {
        let labelNode = SKLabelNode(fontNamed: "Chalkduster")
        labelNode.text = "This"
        labelNode.verticalAlignmentMode = .Center
        labelNode.horizontalAlignmentMode = .Center
        labelNode.position = CGPoint(x: 0, y: labelNode.frame.size.height * 0.85)
        labelNode.fontColor = SKColor(red: 0.973, green: 0.97, blue: 0.775, alpha: 1)
        
        let secondRow = labelNode.copy() as SKLabelNode
        secondRow.text = "week"
        secondRow.position = CGPoint(x: 0, y: 0)
        
        let thirdRow = labelNode.copy() as SKLabelNode
        thirdRow.text = "record"
        thirdRow.position = CGPoint(x: 0, y: -labelNode.frame.size.height * 0.6)
        
        let node = SKNode()
        node.addChild(labelNode)
        node.addChild(secondRow)
        node.addChild(thirdRow)
        
        return node
    }

    private func todayRecordLabel() -> SKNode {
        let labelNode = SKLabelNode(fontNamed: "Chalkduster")
        labelNode.text = "Today"
        labelNode.verticalAlignmentMode = .Bottom
        labelNode.horizontalAlignmentMode = .Center
        labelNode.fontColor = SKColor(red: 0.973, green: 0.97, blue: 0.775, alpha: 1)
        
        let secondRow = labelNode.copy() as SKLabelNode
        secondRow.text = "record"
        secondRow.verticalAlignmentMode = .Top
        
        let node = SKNode()
        node.addChild(labelNode)
        node.addChild(secondRow)
        
        return node
    }

}

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