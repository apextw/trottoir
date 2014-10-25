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
    
    private var label: SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
    
    var title: String {
        get {
            return label.text
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
            return CGSize(width: 100, height: 100)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        activateMarker()
        for touch: AnyObject in touches {
            let touchLocationInScene = touch.locationInNode(self.scene!)
            let touchprint = Touchprint.touchprintWithTouchLocation(touchLocationInScene)
            
            let touchLocation = touch.locationInNode(self)
            touchprint.position = touchLocation
            touchprint.colorBlendFactor = self.colorBlendFactor
            touchprint.color = self.color
            
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
        
        let filter = CIFilter(name: "CIBumpDistortion")
        filter.setDefaults()
        filter.setValue(50, forKey: "inputRadius")
        filter.setValue(1, forKey: "inputScale")
        effectNode.filter = filter

        let externalFilter = CIFilter(name: "CISharpenLuminance")
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
        println("Marker \(number) deinit")
    }
}

class Markers {
    private var markers : [Marker] = []
    var markerDelegate: MarkerActivationProtocol!
    
    private var labels: [SKNode] = []
    
    private let maxY: CGFloat!;
    private let minY: CGFloat!;
    
    private var screenSize = CGSize(width: 0, height: 0)
    
    var scrollSpeed: CGFloat = -1
    var scrollingEnabled = false
    
    private let border: CGFloat = 1
    private var counter = 0
    
    private var colorAttributes: NSArray!
    var color = SKColor.whiteColor()

    init(screenSize: CGSize, markersDelegate: MarkerActivationProtocol) {
        self.screenSize = screenSize
        println("Screen size for markers: width: \(screenSize.width) height: \(screenSize.height)")
        maxY = screenSize.height * 0.5 + Marker.size.height * 0.5
        minY = -maxY
        
        self.markerDelegate = markersDelegate
        
//        addInitialMarkers()
        addFirstMarker()
    }

    private func addInitialMarkers() {
        var position = CGPoint(x: 0, y: 0)
        while position.y < maxY {
            ++counter
            let marker = Marker.markerWithLabel("\(counter)", number: counter)
            marker.delegate = markerDelegate
            position.y += border + Marker.size.height
            marker.position = position
            markers.append(marker)
        }
    }
    
    private func addFirstMarker() {
        counter = 1
        let marker = Marker.markerWithLabel("\(counter)", number: counter)
        marker.delegate = markerDelegate
        marker.position = CGPoint(x: 0, y: maxY)
        markers.append(marker)
    }
    
    func addTo(node: SKNode) {
        for marker in markers {
            if marker.parent != nil {
                marker.removeFromParent()
            }
            node.addChild(marker)
        }
    }
    
    
    func update() {
        if scrollingEnabled {
            shift()
            addMarkerIfNeeded()
            removeMarkerIfNeeded()
            removeLabelIfNeeded()
        }
    }
    
    private func shift() {
        for marker in markers {
            if marker.parent != nil {
                marker.position = CGPoint(x: marker.position.x, y: marker.position.y + scrollSpeed)
            }
        }
        for label in labels {
            if label.parent != nil {
                label.position = CGPoint(x: label.position.x, y: label.position.y + scrollSpeed)
            }
        }
    }
    
    private func addMarkerIfNeeded() {
        if let lastMarker = markers.last {
            if lastMarker.position.y <= maxY {
                
                switch counter {
                case 0...50:
                    addEasyMarker(lastMarker: lastMarker)
                case 51...100:
                    addMediumMarker(lastMarker: lastMarker)
                case 101...250:
                    addHardMarker(lastMarker: lastMarker)
                default:
                    addInsaneMarker(lastMarker: lastMarker)
                }
            }
        }
    }
    
    private func removeMarkerIfNeeded() {
        if let firstMarker = markers.first {
            if firstMarker.position.y < minY {
                println("Remove marker at X: \(firstMarker.position.x) Y: \(firstMarker.position.y))")
                markers.removeAtIndex(0)
                firstMarker.removeFromParent()
                firstMarker.doubledMarker = nil
                if firstMarker.isActivated == false && markerDelegate != nil {
                    markerDelegate.markerWillHideUnactivated(firstMarker)
                }
            }
        }
    }
    
    private func removeLabelIfNeeded() {
        if let firstLabel = labels.first {
            if firstLabel.position.y < minY {
                println("Remove label at X: \(firstLabel.position.x) Y: \(firstLabel.position.y))")
                labels.removeAtIndex(0)
                firstLabel.removeFromParent()
            }
        }
    }
    
    deinit {
        for marker in markers {
            marker.removeFromParent()
            marker.delegate = nil
        }
        println("Markers deinit")
    }
}

// MARK: Complexities of adding markers
extension Markers {
    
    private func addEasyMarker(#lastMarker: Marker) {
        let layer = lastMarker.parent!
        
        let randomValue = arc4random() % 100
        switch randomValue {
        case 0...10:
            // Zigzag queue
            var initialPosition = lastMarker.position
            initialPosition.y += Marker.size.height + border
            addMarkersZigzagStyle(elementsCount: 5, toNode: layer, withInitialY: initialPosition.y, chanceOfDoubleMarker: 0.1)
        case 11...30:
            // Double marker
            addDoubleMarkerTo(layer, withLastMarkerPosition: lastMarker.position)
        case 31...35:
            // Random queue
            var initialPosition = lastMarker.position
            initialPosition.y += Marker.size.height + border
            addMarkersRandomStyle(elementsCount: 5, toNode: layer, withInitialY: initialPosition.y)
        default:
            // Plain single marker
            addSingleMarkerTo(layer, withLastMarkerPosition: lastMarker.position)
        }
    }
    
    private func addMediumMarker(#lastMarker: Marker) {
        let layer = lastMarker.parent!
        
        let randomValue = arc4random() % 100
        switch randomValue {
        case 0...20:
            // Zigzag queue
            var initialPosition = lastMarker.position
            initialPosition.y += Marker.size.height + border
            addMarkersZigzagStyle(elementsCount: 11, toNode: layer, withInitialY: initialPosition.y, chanceOfDoubleMarker: 0.25)
        case 21...50:
            // Double marker
            addDoubleMarkerTo(layer, withLastMarkerPosition: lastMarker.position)
        case 51...60:
            // Random queue
            var initialPosition = lastMarker.position
            initialPosition.y += Marker.size.height + border
            addMarkersRandomStyle(elementsCount: 5, toNode: layer, withInitialY: initialPosition.y)
        default:
            // Plain single marker
            addSingleMarkerTo(layer, withLastMarkerPosition: lastMarker.position)
        }
    }

    private func addHardMarker(#lastMarker: Marker) {
        let layer = lastMarker.parent!
        
        let randomValue = arc4random() % 100
        switch randomValue {
        case 0...25:
            // Zigzag queue
            var initialPosition = lastMarker.position
            initialPosition.y += Marker.size.height + border
            addMarkersZigzagStyle(elementsCount: 11, toNode: layer, withInitialY: initialPosition.y, chanceOfDoubleMarker: 0.3)
        case 26...50:
            // Double marker
            addDoubleMarkerTo(layer, withLastMarkerPosition: lastMarker.position)
        case 51...80:
            // Random queue
            var initialPosition = lastMarker.position
            initialPosition.y += Marker.size.height + border
            addMarkersRandomStyle(elementsCount: 10, toNode: layer, withInitialY: initialPosition.y)
        default:
            // Plain single marker
            addSingleMarkerTo(layer, withLastMarkerPosition: lastMarker.position)
        }
    }
    
    private func addInsaneMarker(#lastMarker: Marker) {
        let layer = lastMarker.parent!
        if arc4random() % 2 == 0 {
            addDoubleMarkerTo(layer, withLastMarkerPosition: lastMarker.position)
        } else {
            let initialY = lastMarker.position.y + Marker.size.height + border
            addMarkersRandomStyle(elementsCount: 5, toNode: layer, withInitialY: initialY)
        }
    }
}

// MARK: Styles of adding markers
extension Markers {

    private func addSingleMarkerTo(node: SKNode, withLastMarkerPosition lastPosition: CGPoint) -> Marker {
        var position = lastPosition
        position.y += border + Marker.size.height
        position.x = 0
        
        let marker = addSingleMarkerTo(node)
        marker.position = position
        
        showAchievementForMarkerIfNeeded(marker: marker)
        
        println("New marker \(counter) at at X: \(position.x) Y: \(position.y)")

        return marker
    }
    
    private func addSingleMarkerTo(node: SKNode) -> Marker {
        ++counter
        updateColor()
        let marker = Marker.markerWithLabel("\(counter)", number: counter)
        marker.delegate = markerDelegate
        marker.color = color
        marker.colorBlendFactor = 1
        markers.append(marker)
        node.addChild(marker)
        
        return marker
    }
    
    private func addDoubleMarkerTo(node: SKNode, withLastMarkerPosition lastPosition: CGPoint) {
        let yPosition = lastPosition.y + border + Marker.size.height
        addDoubleMarkerTo(node, toPosition: CGPoint(x: 0, y: yPosition))
    }
    
    private func addDoubleMarkerTo(node: SKNode, toPosition position: CGPoint) -> (leftMarker: Marker, rightMarker: Marker) {
        let xShift = (Marker.size.width + border) / 2
        
        let leftMarker = addSingleMarkerTo(node)
        leftMarker.position = CGPoint(x: position.x - xShift, y: position.y)
        
        let rightMarker = addSingleMarkerTo(node)
        rightMarker.position = CGPoint(x: position.x + xShift, y: position.y)
        
        leftMarker.doubledMarker = rightMarker
        rightMarker.doubledMarker = leftMarker
        
        showAchievementForMarkerIfNeeded(marker: leftMarker)
        showAchievementForMarkerIfNeeded(marker: rightMarker)
        
        println("New double marker \(counter - 1)-\(counter) at at Y: \(position.y)")
        return (leftMarker, rightMarker)
    }

    
    private func addMarkersZigzagStyle(elementsCount count: Int, toNode node: SKNode, withInitialY initialY: CGFloat, chanceOfDoubleMarker: CGFloat) {
        
        var xCoordinate: CGFloat = 0
        var yCoordinate: CGFloat = initialY;
        
        var xShift = Marker.size.width / 2
        if arc4random() % 2 == 0 {
            xShift *= -1
        }
        
        let maxX = (screenSize.width * 0.5) - (Marker.size.width * 0.5) - border

        for _ in 0 ..< count {
            
            xCoordinate += xShift
            if abs(xCoordinate) > maxX {
                xCoordinate -= 2 * xShift
                xShift *= -1;
            }

            let enoughSpaceForDoubleMarker = abs(xCoordinate) + Marker.size.width + (border / 2) <= maxX
            if enoughSpaceForDoubleMarker {
                let rndValue = CGFloat(arc4random() % 100) / 100.0
                if rndValue < chanceOfDoubleMarker {
                   // Insert double marker
                    println("Zigzag queue: ");
                    addDoubleMarkerTo(node, toPosition: CGPoint(x: xCoordinate, y: yCoordinate))
                    yCoordinate += Marker.size.height + border
                    continue
                }
            }
            
            let marker = addSingleMarkerTo(node)
            marker.position = CGPoint(x: xCoordinate, y: yCoordinate)
            yCoordinate += Marker.size.height + border
            
            showAchievementForMarkerIfNeeded(marker: marker)
            
            println("Zigzag queue: New marker \(counter) at at X: \(xCoordinate) Y: \(marker.position.y)")
        }
    }
    
    private func addMarkersRandomStyle(elementsCount count: Int, toNode node: SKNode, withInitialY initialY: CGFloat) {
        var xCoordinate: CGFloat = 0
        var yCoordinate: CGFloat = initialY;
        
        let maxX = (screenSize.width * 0.5) - (Marker.size.width * 0.5) - border
        
        for _ in 0 ..< count {
            xCoordinate = CGFloat(arc4random() % 1000) % maxX
            if arc4random() % 2 == 0 {
                xCoordinate *= -1
            }
            
            let marker = addSingleMarkerTo(node)
            marker.position = CGPoint(x: xCoordinate, y: yCoordinate)
            yCoordinate += Marker.size.height + border
            
            showAchievementForMarkerIfNeeded(marker: marker)

            println("Random queue: New marker \(counter) at at X: \(xCoordinate) Y: \(marker.position.y)")
        }
    }
}

// MARK: Achievements
extension Markers {
    private func showAchievementForMarkerIfNeeded(#marker: Marker) -> SKNode? {
        let number = marker.number
        if number == Results.localBestResult {
            let label = localBestLabel()
            return showAchievementLabel(label, nearMarker: marker)
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
}

// MARK: Markers color
extension Markers {
    private func updateColor() {
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
                
                color = SKColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
                println("New color with red: \(red), green: \(green), blue: \(blue)")
            }
        }
    }
}