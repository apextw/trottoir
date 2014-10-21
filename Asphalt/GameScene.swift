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
    
    private let initialSpeed: CGFloat = -4
    private var scoresLabel: SKLabelNode!
    
    private var scrollSpeed: CGFloat = 0
    private var speedMultiplier: CGFloat = 1
    
    var background: Background!
    private var markers: Markers!
    
    private var gameManager: GameManager!
    
    private var isGameOver = false
    private var audioManager = AudioManager()
    
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
        audioManager.play()
    }
    
    func fillScreenWithBackground() {
        
        if let backgroundLayer = self.childNodeWithName("BackgroundLayer") {

            if background != nil {
                background.addTo(backgroundLayer)
                return
            }
        
            if let backgroundPart = backgroundLayer.childNodeWithName("BackgroundPart") as? SKSpriteNode {
                background = Background(backgroundTileSprite: backgroundPart, screenSize: self.size)
                background.addTo(backgroundLayer)
                return
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
        
        if isGameOver {
            presentMainMenu()
        }

        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let touchprint = Touchprint.touchprintWithTouchLocation(location)
            touchprint.position = location
            
            self.addChild(touchprint)

            gameOver()
        }
    }
    
    private func presentMainMenu() {
        if let scene = MainMenuScene.unarchiveFromFile("MainMenu") as? MainMenuScene {
            scene.size = self.size
            scene.scaleMode = SKSceneScaleMode.ResizeFill
            let transition = SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 1)
            self.view!.presentScene(scene, transition: transition)
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
        
        let audioSpeed = min(2, Float(pow(speedMultiplier, 0.25)))
        if audioSpeed == 2 {
            println("Audio speed is at maximum — 2")
        }
        audioManager.setRate(audioSpeed)
    }
    
    func gameOver() {
        
        if isGameOver {
            presentMainMenu()
        }
        
        audioManager.stop()
        shake()
        
        let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Game Over"
        self.addChild(gameOverLabel)

        Results.commitNewLocalBest(gameManager.score)
        
        background.scrollingEnabled = false
        markers.scrollingEnabled = false
        
        isGameOver = true
    }
    
    private func shake() {
        
        let range: CGFloat = 25
        var moves: [SKAction] = []
        for _ in 0...4 {
            let rndX = CGFloat(arc4random() % UInt32(range * 100) / 100) - range / 2
            let rndY = CGFloat(arc4random() % UInt32(range * 100) / 100) - range / 2
            let move = SKAction.moveByX(rndX, y: rndY, duration: 0.1)
            move.timingMode = SKActionTimingMode.EaseOut
            moves.append(move)
            let move2 = SKAction.moveByX(-rndX, y: -rndY, duration: 0.1)
            move2.timingMode = SKActionTimingMode.EaseIn
            moves.append(move2)
        }
        let moveSequence = SKAction.sequence(moves)
        for child in self.children {
            child.runAction(moveSequence)
        }
    }
    
    func setScore(newScore: Int) {
        scoresLabel.text = newScore.description
    }

}
