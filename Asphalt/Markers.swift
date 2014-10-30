//
//  Markers.swift
//  Asphalt
//
//  Created by Alexander Bekert on 30/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import SpriteKit

class Markers {
    private var markers : [Marker] = []
    var markerDelegate: MarkerActivationProtocol!
    
    internal var labels: [SKNode] = []
    
    private let maxY: CGFloat!;
    private let minY: CGFloat!;
    
    internal var screenSize = CGSize(width: 0, height: 0)
    
    var scrollSpeed: CGFloat = -1
    var scrollingEnabled = false
    
    internal let border: CGFloat = 1
    internal var counter = 0
    
    internal var colorAttributes: NSArray!
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

