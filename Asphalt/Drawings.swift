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
            if Int(number) == intValue {
                let name = dictionary.objectForKey("Name") as String
                let anchorX = (dictionary.objectForKey("anchorX") as NSString).floatValue
                let texture = Drawings.drawingsAtlas.textureNamed(name)
                
                let red = dictionary.objectForKey("Red") as NSNumber?
                let green = dictionary.objectForKey("Green") as NSNumber?
                let blue = dictionary.objectForKey("Blue") as NSNumber?
                
                if red != nil && green != nil && blue != nil {
                    let redValue = CGFloat(red!.floatValue / 255)
                    let greenValue = CGFloat(green!.floatValue / 255)
                    let blueValue = CGFloat(blue!.floatValue / 255)
                    
                    let color = SKColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1)
                    
                    return Drawing(name: name, anchorX: anchorX, tileNumber: number, texture: texture, color: color)
                }

                return Drawing(name: name, anchorX: anchorX, tileNumber: number, texture: texture, color: nil)
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
    
    var color: SKColor?
}

