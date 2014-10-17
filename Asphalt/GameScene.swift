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
    
    let initialSpeed: CGFloat = -4
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
        
        println("Self.size: x = \(self.size.width), y = \(self.size.height)")
        println("Self.view?.frame.size: x = \(self.view?.frame.size.width), y = \(self.view?.frame.size.height)")
        println("Self.view!.bounds.size: x = \(self.view?.bounds.size.width), y = \(self.view?.bounds.size.width)")

        scoresLabel.position = CGPoint(x: -self.size.width / 2, y: -self.size.height / 2)
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
    
//    override func didApplyConstraints() {
//        println("Did apply constraints")
//    }
    
    func fillScreenWithBackground() {
        
        if let backgroundLayer = self.childNodeWithName("BackgroundLayer") {
            if let backgroundPart = backgroundLayer.childNodeWithName("BackgroundPart") as? SKSpriteNode {
                background = Background(backgroundTileSprite: backgroundPart, screenSize: self.size)
                background.addTo(backgroundLayer)
            }
        }
    }
    
    func addMarkers() {
        markers = Markers(screenSize: self.size, markersDelegate: gameManager)
        if let backgroundLayer = self.childNodeWithName("BackgroundLayer") {
            markers.addTo(backgroundLayer)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let touchprint = Touchprint.touchprintWithTouchLocation(location)
            touchprint.position = location
            
            self.addChild(touchprint)

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
        speedMultiplier *= 1.03
        scrollSpeed = initialSpeed * speedMultiplier
        markers.scrollSpeed = scrollSpeed
        background.scrollSpeed = scrollSpeed
    }
    
    func gameOver() {
        let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Game Over"
        self.addChild(gameOverLabel)

        Results.commitNewLocalBest(gameManager.score)
        
        background.scrollingEnabled = false
        markers.scrollingEnabled = false
    }
    
    func setScore(newScore: Int) {
        scoresLabel.text = newScore.description
    }

}
