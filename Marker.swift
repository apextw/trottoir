//
//  Marker.swift
//  Asphalt
//
//  Created by Alexander Bekert on 12/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import SpriteKit

class Marker : SKSpriteNode {

    class internal func markerWith(label: String) -> Marker {
        let marker = Marker(color: SKColor.whiteColor(), size: CGSize(width: 100, height: 100))
        marker.userInteractionEnabled = true
        marker.name = "marker"
        marker.zPosition = 1
        marker.title = label
        
        return marker
    }
    
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
                label.fontColor = SKColor.blackColor()
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
    }

    var isActivated = false
    
    func activateMarker() {
        if !isActivated {
            self.color = SKColor.redColor()
            self.colorBlendFactor = 1
        }
    }
}

class Markers {
    private var markers : [Marker] = []
    
    private var maxY: CGFloat = 0;
    private var minY: CGFloat = 0;
    
    var scrollSpeed: CGFloat = -1
    var scrollingEnabled = false
    
    private let border: CGFloat = 10
    private var counter = 1

    init(screenSize: CGSize) {
        minY = -screenSize.height / 2 - Marker.size.height / 2
        maxY = screenSize.height / 2 + Marker.size.height / 2
        
        addInitialMarkers()
    }

    private func addInitialMarkers() {
        var position = CGPoint(x: 0, y: 0)
        while position.y < maxY {
            let marker = Marker.markerWith("\(counter)")
            ++counter
            
            position.y += border + Marker.size.height
            marker.position = position
            markers.append(marker)
        }
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
        }
    }
    
    private func shift() {
        for marker in markers {
            if marker.parent != nil {
                marker.position = CGPointMake(marker.position.x, marker.position.y + scrollSpeed)
            }
        }
    }
    
    private func addMarkerIfNeeded() {
        if let lastMarker = markers.last {
            if lastMarker.position.y <= maxY {
                
                let marker = Marker.markerWith("\(counter)")
                ++counter
                
                var position = lastMarker.position

                position.y += border + Marker.size.height
                marker.position = position
                markers.append(marker)
                
                lastMarker.parent!.addChild(marker)
                println("New marker at at X: \(position.x) Y: \(position.y)")
            }
        }
    }
    
    private func removeMarkerIfNeeded() {
        if let firstMarker = markers.first {
            if firstMarker.position.y <= minY {
                println("Remove marker")
                markers.removeAtIndex(0)
                firstMarker.removeFromParent()
            }
        }
    }
}
