//
//  GameScene.swift
//  Asphalt
//
//  Created by Alexander Bekert on 10/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

var scrollSpeed: CGFloat = -2
var speedMultiplier: CGFloat = 1

import SpriteKit

class GameScene: SKScene, GameManagerProtocol {
    
    let initialSpeed: CGFloat = -3
    var scoresLabel: SKLabelNode!
    
    var scrollSpeed: CGFloat = 0
    var speedMultiplier: CGFloat = 1
    
    var background: Background!
    var markers: Markers!
    
    var gameManager: GameManager!
    
    override func didMoveToView(view: SKView) {
        resetSpeed()
        
        scoresLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoresLabel.verticalAlignmentMode = .Bottom
        scoresLabel.horizontalAlignmentMode = .Left
        scoresLabel.text = "0"
        scoresLabel.position = CGPoint(x: -self.view!.bounds.size.width / 2, y: -self.view!.bounds.size.height / 2)
        self.addChild(scoresLabel)
        
        gameManager = GameManager(delegate: self)
        
        fillScreenWithBackground()
        background.scrollSpeed = scrollSpeed
        background.scrollingEnabled = true
        
        addMarkers()
        markers.scrollSpeed = scrollSpeed
        markers.scrollingEnabled = true
        
        startSpeedIncreaser()
    }
    
    func fillScreenWithBackground() {
        
        if let backgroundLayer = self.childNodeWithName("BackgroundLayer") {
            if let backgroundPart = backgroundLayer.childNodeWithName("BackgroundPart") as? SKSpriteNode {
                background = Background(backgroundTileSprite: backgroundPart, screenSize: self.size)
                background.addTo(backgroundLayer)
            }
        }
    }
    
    func addMarkers() {
        markers = Markers(screenSize: self.view!.bounds.size, markersDelegate: gameManager)
        if let backgroundLayer = self.childNodeWithName("BackgroundLayer") {
            markers.addTo(backgroundLayer)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            gameOver()
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        background.update()
        markers.update()
    }
    
    private func resetSpeed() {
        scrollSpeed = initialSpeed
        speedMultiplier = 1
        self.removeActionForKey("Speed increaser")
    }
    
    private func startSpeedIncreaser() {
        let increaseSpeedAction = SKAction.runBlock { () -> Void in
            self.increaseSpeed()
        }
        let waitAction = SKAction.waitForDuration(1)
        let increaseThenWait = SKAction.sequence([increaseSpeedAction, waitAction])
        let repeatAction = SKAction.repeatActionForever(increaseThenWait)
        runAction(repeatAction, withKey: "Speed increaser")
    }
    
    private func increaseSpeed() {
        speedMultiplier *= 1.05
        scrollSpeed = initialSpeed * speedMultiplier
        markers.scrollSpeed = scrollSpeed
        background.scrollSpeed = scrollSpeed
    }
    
    func gameOver() {
        background.scrollingEnabled = false
        markers.scrollingEnabled = false
    }
    
    func setScore(newScore: Int) {
        scoresLabel.text = newScore.description
    }

}
