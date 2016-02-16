//
//  Marker.swift
//  Asphalt
//
//  Created by Alexander Bekert on 12/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import SpriteKit

protocol MarkerActivationProtocol {
    func markerDidActivated(sender: Marker)
    func markerWillHideUnactivated(sender: Marker)
    func markedDidActivatedSecondTime(sender: Marker)
}

struct SquareTexture {
    static private let texture1 = SKTextureAtlas(named: "Asphalt").textureNamed("square-1")
    static private let texture2 = SKTextureAtlas(named: "Asphalt").textureNamed("square-2")
    static private let texture3 = SKTextureAtlas(named: "Asphalt").textureNamed("square-3")
    static private let textures = [texture1, texture2, texture3]
    
    static var texture: SKTexture {
        get {
            let index = Int(arc4random() % 3)
            return textures[index]
        }
    }
}

class Marker : SKSpriteNode {
    
    class internal func markerWithLabel(label: String, number: Int) -> Marker {
        let marker = Marker(texture: SquareTexture.texture, size: Marker.size)
        marker.userInteractionEnabled = true
        marker.name = "marker"
        marker.zPosition = 5
        marker.title = label
        marker.number = number
//        marker.setScale(DisplayHelper.MarkerSizeMultiplier)
        
        return marker
    }
    
    override var color: SKColor {
        set {
            super.color = newValue
            label.color = newValue
        }
        get {
            return super.color
        }
    }
    
    override var colorBlendFactor: CGFloat {
        set {
            super.colorBlendFactor = newValue
            label.colorBlendFactor = newValue
        }
        get {
            return super.colorBlendFactor
        }
    }

    
    var doubledMarker: Marker? = nil
    var delegate: MarkerActivationProtocol!
    var number: Int = 0
    
    private var label: SKLabelNode = SKLabelNode(fontNamed: DisplayHelper.FontName)
    
    var title: String {
        get {
            return label.text!
        }
        set (newTitle) {
            label.text = newTitle
            if label.parent == nil {
                label.horizontalAlignmentMode = .Center
                label.verticalAlignmentMode = .Center
                label.fontColor = SKColor.whiteColor()
                label.zPosition = 1
                self.addChild(label)
            }
        }
    }
    
    class var size: CGSize {
        get {
            return SquareTexture.texture1.size()
//            let textureSize = SquareTexture.texture1.size()
//            let multiplier = DisplayHelper.MarkerSizeMultiplier
//            return CGSize(width: textureSize.width * multiplier, height: textureSize.height * multiplier)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        activateMarker()
        for touch: AnyObject in touches {
            let touchLocationInScene = touch.locationInNode(self.scene!)
            let touchprint = Touchprint.touchprintWithTouchLocation(touchLocationInScene)
            
            let touchLocation = touch.locationInNode(self)
            touchprint.position = touchLocation
            touchprint.colorBlendFactor = self.colorBlendFactor
            touchprint.color = self.color
            touchprint.zPosition = -0.1
            
            self.addChild(touchprint)
        }
    }
    
    private func touchprintAngle() -> CGFloat {
        let doubleValue = (Double((arc4random() % 1000)) % M_PI_2) - M_PI_4
        return CGFloat(doubleValue)
    }

    var isActivated = false
    
    func activateMarker() {
        if !isActivated {
            
//            let cicolor = self.color.CIColor
//            let red = cicolor.red() - 0.1
//            let green = cicolor.green() - 0.1
//            let blue = cicolor.blue() - 0.1
//            
//            let newColor = SKColor(red: red, green: green, blue: blue, alpha: 1)
//            
//            self.color = newColor
//            self.colorBlendFactor = 0.1
//            applyFilterToLabel()
        } else if delegate != nil {
            delegate.markedDidActivatedSecondTime(self)
            return
        }
        
        isActivated = true

        if delegate != nil {
            delegate.markerDidActivated(self)
        }
    }
    
    func applyFilterToLabel() {
        let effectNode = SKEffectNode()
        let externalEffectNode = SKEffectNode()
        
        guard let filter = CIFilter(name: "CIBumpDistortion") else {
            return
        }
        filter.setDefaults()
        filter.setValue(50, forKey: "inputRadius")
        filter.setValue(1, forKey: "inputScale")
        effectNode.filter = filter

        guard let externalFilter = CIFilter(name: "CISharpenLuminance") else {
            return
        }
        externalFilter.setDefaults()
        externalFilter.setValue(10, forKey: "inputSharpness")
        externalEffectNode.filter = externalFilter

        self.addChild(externalEffectNode)
        externalEffectNode.addChild(effectNode)
        label.removeFromParent()
//        label.setScale(1.2)
        effectNode.addChild(label)
//        self.addChild(effectNode)
        
        effectNode.shouldCenterFilter = true
        effectNode.shouldEnableEffects = true
        effectNode.shouldRasterize = true
        
        externalEffectNode.shouldCenterFilter = true
        externalEffectNode.shouldEnableEffects = true
        externalEffectNode.shouldRasterize = true
    }
    
    deinit {
        print("Marker \(number) deinit")
    }
}