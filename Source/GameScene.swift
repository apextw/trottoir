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
        
        print("Self.size: x = \(self.size.width), y = \(self.size.height)")
        print("Self.view?.frame.size: x = \(self.view?.frame.size.width), y = \(self.view?.frame.size.height)")
        print("Self.view!.bounds.size: x = \(self.view?.bounds.size.width), y = \(self.view?.bounds.size.width)")

        
        gameManager = GameManager(delegate: self)
        Results.attempt += 1
        
        fillScreenWithBackground()
        background.scrollSpeed = scrollSpeed
        background.scrollingEnabled = true
        
        addMarkers()
        markers.scrollSpeed = scrollSpeed
        markers.scrollingEnabled = true
        
        startSpeedIncreaser()
        AudioManager.sharedInstance.play()
        
        let dictionary: [NSObject: AnyObject] = ["Attempt" : Results.attempt, "Sound_is_on" : AudioManager.sharedInstance.musicEnabled]
        Flurry.logEvent("Game_started", withParameters: dictionary, timed: true)
    }
    
    func fillScreenWithBackground() {
        guard let backgroundLayer = self.childNodeWithName("BackgroundLayer") else {
            return
        }
        
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
    }
    
    func addMarkers() {
        let screenSize = CGSize(width: self.size.width / DisplayHelper.MarkerSizeMultiplier, height: self.size.height / DisplayHelper.MarkerSizeMultiplier)
        markers = Markers(screenSize: screenSize, markersDelegate: gameManager)
        
        guard let backgroundLayer = self.childNodeWithName("BackgroundLayer") else {
            return
        }
        
        let markersLayer = SKNode()
        markersLayer.setScale(DisplayHelper.MarkerSizeMultiplier)
        markers.addTo(markersLayer)
        backgroundLayer.addChild(markersLayer)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if GameManager.godMode {
            let enabled = !background.scrollingEnabled
            
            background.scrollingEnabled = enabled
            markers.scrollingEnabled = enabled
            if enabled {
                startSpeedIncreaser()
            } else {
                self.removeActionForKey("Speed increaser")
            }
            return
        }
        
        for touch: UITouch in touches {
            addTouchprint(touch)
            gameOver()
        }
    }
    
    private func addTouchprint (touch: UITouch) {
        let location = touch.locationInNode(self)
        let touchprint = Touchprint.touchprintWithTouchLocation(location)
        touchprint.setScale(DisplayHelper.MarkerSizeMultiplier)
        touchprint.position = location
        if let backgroundLayer = self.childNodeWithName("BackgroundLayer") {
            backgroundLayer.addChild(touchprint)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
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
        background.scrollSpeed = scrollSpeed * DisplayHelper.MarkerSizeMultiplier
    }
    
    func gameOver() {
        if GameManager.godMode {
            return
        }
        
        if isGameOver {
            return
        }
        
        removeAllActions()

        if AudioManager.sharedInstance.musicEnabled {
            let playSound = SKAction.playSoundFileNamed("end.caf", waitForCompletion: true)
            runAction(playSound)
            AudioManager.sharedInstance.stop()
        }

        Results.commitNewLocalBest(self.gameManager.score)

        var reachedNewDrawing = false
        if background.currentDrawing != nil {
            reachedNewDrawing = Drawings.submitMenuDrawingWithTileNumber(background.currentDrawingTileNumber)
        }

        let animationDuration = shake()
        let waitAction = SKAction.waitForDuration(animationDuration)
        self.runAction(waitAction, completion: { () -> Void in
            self.presentMainMenu(showNewLabel: reachedNewDrawing)
        })
        
        background.scrollingEnabled = false
        markers.scrollingEnabled = false
        
        isGameOver = true
        
        let dictionary: [NSObject: AnyObject] = ["score" : gameManager.score]
        Flurry.endTimedEvent("Game_started", withParameters: dictionary)
    }
    
    private func shake() -> NSTimeInterval {
        let iterationsCount = 4
        let iterationDuration = 0.1
        var range: CGFloat = 25
        var angleRange: CGFloat = 0.1

        var moves: [SKAction] = []
        for _ in 0...iterationsCount {
            let rndX = CGFloat(arc4random() % UInt32(range * 100) / 100) - range / 2
            let rndY = CGFloat(arc4random() % UInt32(range * 100) / 100) - range / 2
            let rndAngle = CGFloat(arc4random() % UInt32(angleRange * 100) / 100) - angleRange / 2

            let move1 = SKAction.moveByX(rndX, y: rndY, duration: iterationDuration)
            move1.timingMode = SKActionTimingMode.EaseOut
            let rotate1 = SKAction.rotateByAngle(rndAngle, duration: iterationDuration)
            rotate1.timingMode = SKActionTimingMode.EaseOut
            moves.append(SKAction.group([move1, rotate1]))
            
            let move2 = SKAction.moveByX(-rndX, y: -rndY, duration: iterationDuration)
            move2.timingMode = SKActionTimingMode.EaseIn
            let rotate2 = SKAction.rotateByAngle(-rndAngle, duration: iterationDuration)
            rotate2.timingMode = SKActionTimingMode.EaseIn
            moves.append(SKAction.group([move2, rotate2]))
            
            range = max(max(fabs(rndX), fabs(rndY)), 0.5 * range)
            angleRange /= 1.5
        }

        let moveSequence = SKAction.sequence(moves)
        
        let duration = iterationDuration * 2 * NSTimeInterval(iterationsCount)

        for child in self.children {
            child.runAction(moveSequence)
        }
        
        return duration
    }
    
    private func presentMainMenu(showNewLabel showNewLabel: Bool) {
        if let scene = MainMenuScene.unarchiveFromFile("MainMenu") as? MainMenuScene {
            scene.adDelegate = adDelegate
            
            scene.size = self.size
            scene.scaleMode = SKSceneScaleMode.ResizeFill
            if background.currentDrawing != nil {
                scene.drawing = background.currentDrawing.copy() as! SKSpriteNode
            }
            scene.score = gameManager.score
            scene.showNewLabel = showNewLabel
            let duration = 0.5
            let transition = SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: duration)
            self.view!.presentScene(scene, transition: transition)
            
            delay(duration, closure: { () -> () in
                self.freeObjects()
            })
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
        print("Game Scene deinit")
    }
}
