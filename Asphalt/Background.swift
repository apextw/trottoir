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
    private var originalTile : SKSpriteNode! = nil;
    private var screenSize: CGSize = CGSize(width: 0, height: 0)
    
    private var tileMaxY: CGFloat = 0;
    private var tileMinY: CGFloat = 0;
    
    var scrollSpeed: CGFloat = -1
    var scrollingEnabled = false
    
    init(backgroundTileSprite tile: SKSpriteNode, screenSize: CGSize) {
        self.screenSize = screenSize
        originalTile = tile
        tileMinY = -screenSize.height / 2 - tile.size.height / 2
        tileMaxY = screenSize.height / 2 + tile.size.height / 2

        let tileRow = tileRowWith(tile, forScreenWidth: screenSize.width)
        buildTileMapWith(tileRow, forScreenHeight: screenSize.height)
    }
    
    private func tileRowWith(background: SKSpriteNode, forScreenWidth screenWidth: CGFloat) -> SKNode {
        
        var partsToAdd = Int(screenWidth) / Int(background.size.width);
        partsToAdd /= 2;
        
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
    
    private func addTileRowIfNeeded() {
        if let lastRow = tileRows.last {
            if lastRow.position.y <= tileMaxY {
                if let rowCopy = lastRow.copy() as? SKNode {
                    var position = lastRow.position
                    position.y += originalTile.size.height
                    rowCopy.position = position
                    if rowCopy.parent != nil {
                        rowCopy.removeFromParent()
                    }
                    lastRow.parent!.addChild(rowCopy)
                    tileRows.append(rowCopy)
                    println("New tile row at X: \(position.x) Y: \(position.y)")
                }
            }
        }
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
