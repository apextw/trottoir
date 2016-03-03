//
//  Button.swift
//  Asphalt
//
//  Created by Alexander Bekert on 21/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import SpriteKit

protocol ButtonProtocol {
    func didTouchDownButton(sender: Button, position: CGPoint)
    func didTouchUpInsideButton(sender: Button, position: CGPoint)
}

class Button: SKLabelNode {
    
    var delegate: ButtonProtocol? = nil
    var enabled: Bool {
        set {
            userInteractionEnabled = newValue
        }
        get {
            return userInteractionEnabled
        }
    }
    
    override init() {
        super.init()
        enabled = true
    }
    
    required override init(fontNamed fontName: String?) {
        super.init(fontNamed: fontName)
        enabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setSelected(selected: Bool) {
        if selected {
            self.setScale(1.2)
        } else {
            self.setScale(1)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! 
        let touchPoint = touch.locationInNode(self)
        delegate?.didTouchDownButton(self, position: touchPoint)
//        setSelected(true)
    }
    
//    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
//        let touch = touches.anyObject() as UITouch
//        let touchPoint = touch.locationInNode(self.parent)
//        if CGRectContainsPoint(self.frame, touchPoint) {
//            setSelected(true)
//        } else {
//            setSelected(false)
//        }
//    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! 
        let touchPoint = touch.locationInNode(self.parent!)
//        setSelected(false)
        if delegate != nil && CGRectContainsPoint(self.frame, touchPoint) {
            delegate!.didTouchUpInsideButton(self, position: touchPoint)
        }
    }
}