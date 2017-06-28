//
//  Drawings.swift
//  Asphalt
//
//  Created by Alexander Bekert on 22/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import SpriteKit

struct Drawings {
    static fileprivate let attributes: NSArray = {
        if let path = Bundle.main.path(forResource: "DrawingsAttributes", ofType: "plist") {
            return NSArray(contentsOfFile: path)!
        }
        return []
        }()
    
    static fileprivate let drawingsAtlas = SKTextureAtlas(named: "Drawings")
    
    static func drawingForTileNumber(_ number: Int) -> Drawing? {
        for pictureAttributes in Drawings.attributes {
            let dictionary = pictureAttributes as! NSDictionary
            let pictureTileNumber = dictionary.object(forKey: "Tile number") as! String
            
            let intValue = Int(pictureTileNumber)
            if Int(number) != intValue {
                continue
            }
            
            let name = dictionary.object(forKey: "Name") as! String
            let anchorX = (dictionary.object(forKey: "anchorX") as! NSString).floatValue
            let texture = Drawings.drawingsAtlas.textureNamed(name)
            
            let red = dictionary.object(forKey: "Red") as! NSNumber?
            let green = dictionary.object(forKey: "Green") as! NSNumber?
            let blue = dictionary.object(forKey: "Blue") as! NSNumber?
            
            if red != nil && green != nil && blue != nil {
                let redValue = CGFloat(red!.floatValue / 255)
                let greenValue = CGFloat(green!.floatValue / 255)
                let blueValue = CGFloat(blue!.floatValue / 255)
                
                let color = SKColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1)
                
                return Drawing(name: name, anchorX: anchorX, tileNumber: number, texture: texture, color: color)
            }

            return Drawing(name: name, anchorX: anchorX, tileNumber: number, texture: texture, color: nil)
        }
        return nil
    }
    
    static var mainMenuDrawing: SKSpriteNode {
        get {
            if let textureName = UserDefaults.standard.string(forKey: "Current Menu Picture") {
                let texture = Drawings.drawingsAtlas.textureNamed(textureName)
                return SKSpriteNode(texture: texture)
            }

            print("Unable to get suitable Main Menu Drawing")
            return SKSpriteNode()
        }
    }
    
    static func submitMenuDrawingWithTileNumber(_ tileNumber: Int) -> Bool {
        let currentMenuDrawingNumber = UserDefaults.standard.integer(forKey: "Current Drawing Number")
        if tileNumber > currentMenuDrawingNumber {
            UserDefaults.standard.set(tileNumber, forKey: "Current Drawing Number")
            guard let newDrawingName = Drawings.pictureNameForTileNumber(tileNumber) else {
                return false
            }
            UserDefaults.standard.set(newDrawingName, forKey: "Current Menu Picture")
            return true
        }
        return false
    }
    
    static fileprivate func pictureNameForTileNumber(_ tileNumber: Int) -> String? {
        for pictureAttributes in Drawings.attributes {
            let dictionary = pictureAttributes as! NSDictionary
            let pictureTileNumber = dictionary.object(forKey: "Tile number") as! String
            
            let intValue = Int(pictureTileNumber)
            if tileNumber == intValue {
                let name = dictionary.object(forKey: "Name") as! String
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

