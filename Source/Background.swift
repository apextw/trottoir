//
//  Background.swift
//  Asphalt
//
//  Created by Alexander Bekert on 11/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import SpriteKit

public class Background {
    
    private var tileRows : [SKNode] = []
    private var originalTile : SKSpriteNode!
    private var originalTilerow : SKNode!
    
    private var screenSize: CGSize = CGSize(width: 0, height: 0)
    
    private var tileMaxY: CGFloat = 0;
    private var tileMinY: CGFloat = 0;
    
    var scrollSpeed: CGFloat = -1
    var scrollingEnabled = false
    
    var recentlyLoadedDrawingTileNumber = 0
    
    init(screenSize: CGSize) {
        self.screenSize = screenSize
        originalTile = SKSpriteNode(color: SKColor.grayColor(), size: CGSize(width: 100, height: 100))
        tileMinY = -screenSize.height / 2 + originalTile.size.height / 2
        tileMaxY = screenSize.height / 2 - originalTile.size.height / 2
        originalTilerow = tileRowWith(originalTile, forScreenWidth: screenSize.width)
        buildTileMapWith(originalTilerow, forScreenHeight: screenSize.height)
    }
    
    init(backgroundTileSprite tile: SKSpriteNode, screenSize: CGSize) {
        self.screenSize = screenSize
        originalTile = tile
        tileMinY = -screenSize.height / 2 - tile.size.height
        tileMaxY = screenSize.height / 2 + tile.size.height / 2

        originalTilerow = tileRowWith(tile, forScreenWidth: screenSize.width)
        buildTileMapWith(originalTilerow, forScreenHeight: screenSize.height)
    }
    
    private func tileRowWith(background: SKSpriteNode, forScreenWidth screenWidth: CGFloat) -> SKNode {
        
        var partsToAdd = Int(screenWidth) / Int(background.size.width);
        partsToAdd = (partsToAdd / 2) + 1;
        
        
        var leftPosition = background.position;
        var rightPosition = background.position;
        
        let node = SKNode()
        if background.parent != nil {
            background.removeFromParent();
        }
        
        while partsToAdd > 0 {
            let bgLeftCopy = background.copy() as! SKSpriteNode
            leftPosition.x -= background.size.width;
            bgLeftCopy.position = leftPosition;
            node.addChild(bgLeftCopy)
            
            let bgRightCopy = background.copy() as! SKSpriteNode
            rightPosition.x += background.size.width;
            bgRightCopy.position = rightPosition;
            node.addChild(bgRightCopy)
            
            partsToAdd -= 1
        }
        
        node.addChild(background)
        return node
    }
    
    private func buildTileMapWith(tileRow: SKNode, forScreenHeight screenHeight: CGFloat) {
        
        tileRows = [tileRow]
        
        var position = tileRow.position
        position.y = tileMinY
        tileRow.position = position;
        
        while position.y < tileMaxY {
            position.y += originalTile.size.height
            print("New tile row at Y: \(position.y)")
            if let rowCopy = tileRow.copy() as? SKNode {
                rowCopy.position = position
                tileRows.append(rowCopy)
            }
        }
    }
    
    func addTo(node: SKNode) {
        for tileRow in tileRows {
            if tileRow.parent != nil {
                tileRow.removeFromParent()
            }
            node.addChild(tileRow)
        }
    }
    
    func removeFromParent() {
        for tileRow in tileRows {
            if tileRow.parent != nil {
                tileRow.removeFromParent()
            }
        }
    }
    
    func update() {
        if scrollingEnabled {
            shiftTileRows()
            addTileRowIfNeeded()
            removeTileRowIfNeeded()
            updateCurrentDrawingIfNeeded()
        }
    }
    
    private func shiftTileRows() {
        for tileRow in tileRows {
            if tileRow.parent != nil {
                tileRow.position = CGPointMake(tileRow.position.x, tileRow.position.y + scrollSpeed)
            }
        }
    }
    
    private var tilerowsCount = 0
    
    private func addTileRowIfNeeded() {
        guard let lastRow = tileRows.last else {
            return
        }
        
        if lastRow.position.y > tileMaxY {
            return
        }
        
        guard let rowCopy = originalTilerow.copy() as? SKNode else {
            return
        }
        
        var position = lastRow.position
        position.y += originalTile.size.height
        rowCopy.position = position
        if rowCopy.parent != nil {
            rowCopy.removeFromParent()
        }
        
        tilerowsCount += 1
        addDrawingToTileRowIfNeeded(tileRow: rowCopy, number: tilerowsCount)
        
        lastRow.parent!.addChild(rowCopy)
        tileRows.append(rowCopy)
        print("New tile row at X: \(position.x) Y: \(position.y)")
    }
    
    private var picturesAttributes: NSArray!
    private var drawingsAtlas: SKTextureAtlas!
    
    public var currentDrawing: SKSpriteNode!
    public var currentDrawingTileNumber = 0
    private var recentlyLoadedDrawing: SKSpriteNode!
    
    private func addDrawingToTileRowIfNeeded(tileRow tileRow: SKNode, number: Int) {
        // Fix speed of new pictures appear for iPad
        var fixedNumber: Int = number
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            fixedNumber = Int(Float(number) / 1.3)
        }
        
        guard let drawing = Drawings.drawingForTileNumber(fixedNumber) else {
            return
        }

        if recentlyLoadedDrawing != nil && drawing.name == recentlyLoadedDrawing.name {
            return
        }
        
        recentlyLoadedDrawing = SKSpriteNode(texture: drawing.texture)
        recentlyLoadedDrawing.name = drawing.name
        insertDrawing(recentlyLoadedDrawing, toNode: tileRow, anchorX: drawing.anchorX)
        print("Insert \(drawing.name) into tile number \(number) with anchorX \(drawing.anchorX)")
        recentlyLoadedDrawingTileNumber = number
        if drawing.color != nil {
            MarkersColor.color = drawing.color!
        }
    }
    
    private func insertDrawing(drawing: SKSpriteNode, toNode node: SKNode, anchorX: Float?) {
        let anchor = anchorX == nil ? -1 : anchorX!
                
        drawing.setScale(DisplayHelper.DrawingsSizeMultiplier)
        
        let x = (screenSize.width * 0.5 - drawing.size.width / 2 - DisplayHelper.DrawingsBorderShift) * CGFloat(anchor)
        let y = -originalTile.size.height * 0.5// + drawing.size.height * 0.5
        drawing.position = CGPoint(x: x, y: y);
        drawing.zPosition = 1
        node.addChild(drawing)
    }
    
    private func removeTileRowIfNeeded() {
        
        guard let firstRow = tileRows.first else {
            return
        }
        
        if firstRow.position.y <= tileMinY {
            print("Background: remove first tile row")
            tileRows.removeFirst()
            firstRow.removeFromParent()
        }
    }
    
    private func updateCurrentDrawingIfNeeded() {
        if recentlyLoadedDrawing === currentDrawing {
            return
        }
        
        let scene = recentlyLoadedDrawing.scene!
        let positionInScene = scene.convertPoint(recentlyLoadedDrawing.position, fromNode: recentlyLoadedDrawing.parent!)
        let drawingBottomY = positionInScene.y - (recentlyLoadedDrawing.size.height * recentlyLoadedDrawing.anchorPoint.y)
        
        let sceneSize = scene.size
        let sceneAnchor = scene.anchorPoint
        let isOnScreen = drawingBottomY < sceneSize.height * (1 - sceneAnchor.y)
        
        if isOnScreen {
            currentDrawing = recentlyLoadedDrawing
            currentDrawingTileNumber = recentlyLoadedDrawingTileNumber
        }
    }
    
    func insertNodeToTheLastRow(node: SKNode) -> SKNode {
        if node.parent != nil {
            node.removeFromParent()
        }
        
        let lastRow = tileRows.last!
        lastRow.addChild(node)
        return lastRow
    }
    
    
    deinit {
        if originalTile.parent != nil {
            originalTile.removeFromParent()
        }
        originalTile = nil
        
        if originalTilerow.parent != nil {
            originalTilerow.removeFromParent()
        }
        originalTilerow = nil
        
        for backgorundRow in tileRows {
            for child in backgorundRow.children {
                child.removeFromParent()
            }
            if backgorundRow.parent != nil {
                backgorundRow.removeFromParent()
            }
        }
        print("Background deinit")
    }
}

// MARK: Screen below
extension Background {
    func prepareScreenBelow() {
        let minY = tileMinY - screenSize.height
        var position = CGPoint(x: 0, y: tileMinY)
        let parent = tileRows.last!.parent!
        
        repeat {
            let tilerow = originalTilerow.copy() as! SKNode
            tilerow.position = position
            parent.addChild(tilerow)
            tileRows.insert(tilerow, atIndex: 0)
            position.y -= originalTile.size.height
        } while position.y > minY
    }

    func removeInvisibleRows() {
        
        var removedCount = 0

        repeat {
            guard let firstRow = tileRows.first else {
                break
            }
            
            if firstRow.position.y <= tileMinY {
                print("Remove first tile row")
                tileRows.removeFirst()
                firstRow.removeFromParent()
                
                removedCount += 1
            } else {
                break
            }
        } while tileRows.count > 0
        
        print("Background: removed \(removedCount) first tilerows.")
    }
}