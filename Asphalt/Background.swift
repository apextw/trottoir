//
//  Background.swift
//  Asphalt
//
//  Created by Alexander Bekert on 11/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import SpriteKit

class Background {
    
    private var tileRows : [SKNode] = []
    private var originalTile : SKSpriteNode!
    private var originalTilerow : SKNode!
    
    private var screenSize: CGSize = CGSize(width: 0, height: 0)
    
    private var tileMaxY: CGFloat = 0;
    private var tileMinY: CGFloat = 0;
    
    var scrollSpeed: CGFloat = -1
    var scrollingEnabled = false
    
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
            let bgLeftCopy = background.copy() as SKSpriteNode
            leftPosition.x -= background.size.width;
            bgLeftCopy.position = leftPosition;
            node.addChild(bgLeftCopy)
            
            let bgRightCopy = background.copy() as SKSpriteNode
            rightPosition.x += background.size.width;
            bgRightCopy.position = rightPosition;
            node.addChild(bgRightCopy)
            
            --partsToAdd
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
            println("New tile row at Y: \(position.y)")
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
    
    
    func update() {
        if scrollingEnabled {
            shiftTileRows()
            addTileRowIfNeeded()
            removeTileRowIfNeeded()
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
        if let lastRow = tileRows.last {
            if lastRow.position.y <= tileMaxY {
                if let rowCopy = originalTilerow.copy() as? SKNode {
                    var position = lastRow.position
                    position.y += originalTile.size.height
                    rowCopy.position = position
                    if rowCopy.parent != nil {
                        rowCopy.removeFromParent()
                    }
                    
                    ++tilerowsCount
                    addDrawingToTileRawIfNeeded(tileRow: rowCopy, number: tilerowsCount)
                    
                    lastRow.parent!.addChild(rowCopy)
                    tileRows.append(rowCopy)
                    println("New tile row at X: \(position.x) Y: \(position.y)")
                }
            }
        }
    }
    
    private var picturesAttributes: NSArray!
    private var drawingsAtlas: SKTextureAtlas!
    
    private func addDrawingToTileRawIfNeeded(#tileRow: SKNode, number: Int) {
        if picturesAttributes == nil {
            if let path = NSBundle.mainBundle().pathForResource("DrawingsAttributes", ofType: "plist") {
                picturesAttributes = NSArray(contentsOfFile: path)
            }
        }
        
        if drawingsAtlas == nil {
            drawingsAtlas = SKTextureAtlas(named: "Drawings")
        }
        
        for pictureAttributes in picturesAttributes {
            let dictionary = pictureAttributes as NSDictionary
            let pictureTileNumber = dictionary.objectForKey("Tile number") as String
            
            let intValue = pictureTileNumber.toInt()
            if number == intValue {
                let name = dictionary.objectForKey("Name") as String
                let anchorX = (dictionary.objectForKey("anchorX") as NSString).floatValue
                let drawing = SKSpriteNode(texture: drawingsAtlas.textureNamed(name))
                insertDrawing(drawing, toNode: tileRow, anchorX: anchorX)
                println("Insert \(name) into tile number \(number) with anchorX \(anchorX)")
            }
        }
    }
    
    private func insertDrawing(drawing: SKSpriteNode, toNode node: SKNode, var anchorX: Float?) {
        if anchorX == nil {
            anchorX = -1
        }
        
        if anchorX < -1 {
            anchorX = -1
            println("Warning: Wrong drawing anchorX value. Expected a value in -1 ... 1")
        } else if anchorX > 1 {
            anchorX = 1
            println("Warning: Wrong drawing anchorX value. Expected a value in -1 ... 1")
        }
        
        let x = (screenSize.width * 0.5 - drawing.size.width / 2) * CGFloat(anchorX!)
        drawing.position = CGPoint(x: x, y: 0);
        drawing.zPosition = 1
        node.addChild(drawing)
    }
    
    private func removeTileRowIfNeeded() {
        if let firstRow = tileRows.first {
            if firstRow.position.y <= tileMinY {
                println("Remove first tile row")
                tileRows.removeAtIndex(0)
                firstRow.removeFromParent()
            }
        }
    }
}
