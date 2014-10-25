//
//  Drawings.swift
//  Asphalt
//
//  Created by Alexander Bekert on 22/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import SpriteKit

struct Drawings {
    static private let attributes: NSArray = {
        if let path = NSBundle.mainBundle().pathForResource("DrawingsAttributes", ofType: "plist") {
            return NSArray(contentsOfFile: path)!
        }
        return []
        }()
    
    static private let drawingsAtlas = SKTextureAtlas(named: "Drawings")
    
    static func drawingForTileNumber(number: Int) -> Drawing? {
        for pictureAttributes in Drawings.attributes {
            let dictionary = pictureAttributes as NSDictionary
            let pictureTileNumber = dictionary.objectForKey("Tile number") as String
            
            let intValue = pictureTileNumber.toInt()
            if number == intValue {
                let name = dictionary.objectForKey("Name") as String
                let anchorX = (dictionary.objectForKey("anchorX") as NSString).floatValue
                let texture = Drawings.drawingsAtlas.textureNamed(name)
                return Drawing(name: name, anchorX: anchorX, tileNumber: number, texture: texture)
            }
        }
        return nil
    }
    
    static var mainMenuDrawing: SKSpriteNode {
        get {
            if let textureName = NSUserDefaults.standardUserDefaults().stringForKey("Current Menu Picture") {
                let texture = Drawings.drawingsAtlas.textureNamed(textureName)
                return SKSpriteNode(texture: texture)
            }

            println("Unable to get suitable Main Menu Drawing")
            return SKSpriteNode()
        }
    }
    
    static func submitMenuDrawingWithTileNumber(tileNumber: Int) -> Bool {
        let currentMenuDrawingNumber = NSUserDefaults.standardUserDefaults().integerForKey("Current Drawing Number")
        if tileNumber > currentMenuDrawingNumber {
            NSUserDefaults.standardUserDefaults().setInteger(tileNumber, forKey: "Current Drawing Number")
            let newDrawingName = Drawings.pictureNameForTileNumber(tileNumber)!
            NSUserDefaults.standardUserDefaults().setObject(newDrawingName, forKey: "Current Menu Picture")
            return true
        }
        return false
    }
    
    static private func pictureNameForTileNumber(tileNumber: Int) -> String? {
        for pictureAttributes in Drawings.attributes {
            let dictionary = pictureAttributes as NSDictionary
            let pictureTileNumber = dictionary.objectForKey("Tile number") as String
            
            let intValue = pictureTileNumber.toInt()
            if tileNumber == intValue {
                let name = dictionary.objectForKey("Name") as String
                return name
            }
        }
        return nil
    }
}

struct Drawing {
    var name = ""
    var anchorX: Float = 0
    var tileNumber = 0
    var texture: SKTexture
}

