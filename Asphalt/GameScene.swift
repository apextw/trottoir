//
//  GameScene.swift
//  Asphalt
//
//  Created by Alexander Bekert on 10/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, GameManagerProtocol {
    
    var adDelegate: adProtocol!

    private let initialSpeed: CGFloat = -4
    
    private var scrollSpeed: CGFloat = 0
    private var speedMultiplier: CGFloat = 1
    
    var background: Background!
    private var markers: Markers!
    
    private var gameManager: GameManager!
    
    private var isGameOver = false
    
    override func didMoveToView(view: SKView) {
        resetSpeed()
        
        println("Self.size: x = \(self.size.width), y = \(self.size.height)")
        println("Self.view?.frame.size: x = \(self.view?.frame.size.width), y = \(self.view?.frame.size.height)")
        println("Self.view!.bounds.size: x = \(self.view?.bounds.size.width), y = \(self.view?.bounds.size.width)")

        
        gameManager = GameManager(delegate: self)
        
        
        fillScreenWithBackground()
        background.scrollSpeed = scrollSpeed
        background.scrollingEnabled = true
        
        addMarkers()
        markers.scrollSpeed = scrollSpeed
        markers.scrollingEnabled = true
        
        startSpeedIncreaser()
        AudioManager.sharedInstance.play()
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
            
            background = Background(screenSize: self.size)
            background.addTo(backgroundLayer)
            return
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
        if !isGameOver {
            background.update()
            markers.update()
        }
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
        
//        let audioSpeed = min(2, Float(pow(speedMultiplier, 0.25)))
//        if audioSpeed == 2 {
//            println("Audio speed is at maximum — 2")
//        }
//        AudioManager.sharedInstance.setRate(audioSpeed)
    }
    
    func gameOver() {
        
        if isGameOver {
            return
        }
        
        removeAllActions()
        
        let reachedNewDrawing = Drawings.submitMenuDrawingWithTileNumber(background.currentDrawingTileNumber)

        AudioManager.sharedInstance.stop()
        let animationDuration = shake()
        let waitAction = SKAction.waitForDuration(animationDuration)
        self.runAction(waitAction, completion: { () -> Void in
            self.presentMainMenu(showNewLabel: reachedNewDrawing)
        })
        
//        let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
//        gameOverLabel.text = "Game Over"
//        self.addChild(gameOverLabel)

        Results.commitNewLocalBest(gameManager.score)
        background.scrollingEnabled = false
        markers.scrollingEnabled = false
        
        isGameOver = true
    }
    
    private func shake() -> NSTimeInterval {
        let iterationsCount = 7
        let duration = 0.1
        let range: CGFloat = 25
        var moves: [SKAction] = []
        for _ in 0...iterationsCount {
            let rndX = CGFloat(arc4random() % UInt32(range * 100) / 100) - range / 2
            let rndY = CGFloat(arc4random() % UInt32(range * 100) / 100) - range / 2
            let move = SKAction.moveByX(rndX, y: rndY, duration: duration)
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
        
        return duration * NSTimeInterval(iterationsCount)
    }
    
    private func presentMainMenu(#showNewLabel: Bool) {
        if let scene = MainMenuScene.unarchiveFromFile("MainMenu") as? MainMenuScene {
            scene.adDelegate = adDelegate
            
            scene.size = self.size
            scene.scaleMode = SKSceneScaleMode.ResizeFill
            scene.score = gameManager.score
            scene.showNewLabel = showNewLabel
            let duration = 0.5
            let transition = SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: duration)
            self.view!.presentScene(scene, transition: transition)
            
            delay(duration, closure: { () -> () in
                self.freeObjects()
            })
//            markers = nil
//            background = nil
//            gameManager = nil
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    private func freeObjects() {
        self.markers.markerDelegate = nil
        self.markers = nil
        
        self.background.removeFromParent()
        self.background = nil
        self.gameManager.delegate = nil
        self.gameManager = nil
    }
    
    func setScore(newScore: Int) {
//        scoresLabel.text = newScore.description
    }
    
    deinit {
        println("Game Scene deinit")
    }
}
