//
//  Touchprint.swift
//  Asphalt
//
//  Created by Alexander Bekert on 17/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import Foundation
import SpriteKit

struct Touchprint {
    static var screenSize: CGSize = CGSize(width: 0, height: 0)
    static private let texture: SKTexture = SKTexture(imageNamed: "touchprint")
    static func touchprintWithTouchLocation(location: CGPoint) -> SKSpriteNode {
        let touchprint = SKSpriteNode(texture: texture)
        touchprint.position = location
        touchprint.zRotation = angleForX(location.x);
        
        return touchprint
    }
    
    static private let maxAngle: CGFloat = 0.8
    
    static private func angleForX(x: CGFloat) -> CGFloat {
        var positionMultiplier = x / (screenSize.width * 0.5)
        
        if positionMultiplier > 1 {
            positionMultiplier = 1
        } else if positionMultiplier < -1 {
            positionMultiplier = -1
        }
        
        return -maxAngle * positionMultiplier
    }
}
