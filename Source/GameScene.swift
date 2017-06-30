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

    fileprivate let initialSpeed: CGFloat = -4
    
    fileprivate var scrollSpeed: CGFloat = 0
    fileprivate var speedMultiplier: CGFloat = 1
    
    var background: Background!
    fileprivate var markers: Markers!
    
    fileprivate var gameManager: GameManager!
    
    fileprivate var isGameOver = false
    
    override func didMove(to view: SKView) {
        resetSpeed()
        
        print("Self.size: x = \(self.size.width), y = \(self.size.height)")
        if let frameSize = self.view?.frame.size {
            print("Self.view?.frame.size: x = \(frameSize.width), y = \(frameSize.height)")
        }
        
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
        
        let dictionary: [AnyHashable: Any] = ["Attempt" : Results.attempt, "Sound_is_on" : AudioManager.sharedInstance.musicEnabled]
        Flurry.logEvent("Game_started", withParameters: dictionary, timed: true)
    }
    
    func fillScreenWithBackground() {
        guard let backgroundLayer = self.childNode(withName: "BackgroundLayer") else {
            return
        }
        
        if background != nil {
            background.addTo(backgroundLayer)
            return
        }
    
        if let backgroundPart = backgroundLayer.childNode(withName: "BackgroundPart") as? SKSpriteNode {
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
        
        guard let backgroundLayer = self.childNode(withName: "BackgroundLayer") else {
            return
        }
        
        let markersLayer = SKNode()
        markersLayer.setScale(DisplayHelper.MarkerSizeMultiplier)
        markers.addTo(markersLayer)
        backgroundLayer.addChild(markersLayer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if GameManager.godMode {
            let enabled = !background.scrollingEnabled
            
            background.scrollingEnabled = enabled
            markers.scrollingEnabled = enabled
            if enabled {
                startSpeedIncreaser()
            } else {
                self.removeAction(forKey: "Speed increaser")
            }
            return
        }
        
        for touch: UITouch in touches {
            addTouchprint(touch)
            gameOver()
        }
    }
    
    fileprivate func addTouchprint (_ touch: UITouch) {
        let location = touch.location(in: self)
        let touchprint = Touchprint.touchprintWithTouchLocation(location)
        touchprint.setScale(DisplayHelper.MarkerSizeMultiplier)
        touchprint.position = location
        if let backgroundLayer = self.childNode(withName: "BackgroundLayer") {
            backgroundLayer.addChild(touchprint)
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
        if !isGameOver {
            background.update()
            markers.update()
        }
    }
    
    fileprivate func resetSpeed() {
        scrollSpeed = initialSpeed
        speedMultiplier = 1
        self.removeAction(forKey: "Speed increaser")
    }
    
    fileprivate func startSpeedIncreaser() {
        let increaseSpeedAction = SKAction.run { () -> Void in
            self.increaseSpeed()
        }
        let waitAction = SKAction.wait(forDuration: 1)
        let increaseThenWait = SKAction.sequence([increaseSpeedAction, waitAction])
        let repeatAction = SKAction.repeatForever(increaseThenWait)
        run(repeatAction, withKey: "Speed increaser")
    }
    
    fileprivate func increaseSpeed() {
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
            run(playSound)
            AudioManager.sharedInstance.stop()
        }

        Results.commitNewLocalBest(self.gameManager.score)

        var reachedNewDrawing = false
        if background.currentDrawing != nil {
            reachedNewDrawing = Drawings.submitMenuDrawingWithTileNumber(background.currentDrawingTileNumber)
        }

        let animationDuration = shake()
        let waitAction = SKAction.wait(forDuration: animationDuration)
        self.run(waitAction, completion: { () -> Void in
            self.presentMainMenu(showNewLabel: reachedNewDrawing)
        })
        
        background.scrollingEnabled = false
        markers.scrollingEnabled = false
        
        isGameOver = true
        
        let dictionary: [AnyHashable: Any] = ["score" : gameManager.score]
        Flurry.endTimedEvent("Game_started", withParameters: dictionary)
    }
    
    fileprivate func shake() -> TimeInterval {
        let iterationsCount = 4
        let iterationDuration = 0.1
        var range: CGFloat = 25
        var angleRange: CGFloat = 0.1

        var moves: [SKAction] = []
        for _ in 0...iterationsCount {
            let rndX = CGFloat(arc4random() % UInt32(range * 100) / 100) - range / 2
            let rndY = CGFloat(arc4random() % UInt32(range * 100) / 100) - range / 2
            let rndAngle = CGFloat(arc4random() % UInt32(angleRange * 100) / 100) - angleRange / 2

            let move1 = SKAction.moveBy(x: rndX, y: rndY, duration: iterationDuration)
            move1.timingMode = SKActionTimingMode.easeOut
            let rotate1 = SKAction.rotate(byAngle: rndAngle, duration: iterationDuration)
            rotate1.timingMode = SKActionTimingMode.easeOut
            moves.append(SKAction.group([move1, rotate1]))
            
            let move2 = SKAction.moveBy(x: -rndX, y: -rndY, duration: iterationDuration)
            move2.timingMode = SKActionTimingMode.easeIn
            let rotate2 = SKAction.rotate(byAngle: -rndAngle, duration: iterationDuration)
            rotate2.timingMode = SKActionTimingMode.easeIn
            moves.append(SKAction.group([move2, rotate2]))
            
            range = max(max(fabs(rndX), fabs(rndY)), 0.5 * range)
            angleRange /= 1.5
        }

        let moveSequence = SKAction.sequence(moves)
        
        let duration = iterationDuration * 2 * TimeInterval(iterationsCount)

        for child in self.children {
            child.run(moveSequence)
        }
        
        return duration
    }
    
    fileprivate func presentMainMenu(showNewLabel: Bool) {
        guard let scene = MainMenuScene.unarchiveFromFile("MainMenu") as? MainMenuScene else {
            return
        }
        scene.adDelegate = adDelegate
        
        scene.size = self.size
        scene.scaleMode = SKSceneScaleMode.resizeFill
        if let drawing = background.currentDrawing, let copy = drawing.copy() as? SKSpriteNode {
            scene.drawing = copy
        }
        scene.score = gameManager.score
        scene.showNewLabel = showNewLabel
        let duration = 0.5
        let transition = SKTransition.push(with: SKTransitionDirection.left, duration: duration)
        self.view!.presentScene(scene, transition: transition)

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.freeObjects()
        }
    }
    
    fileprivate func freeObjects() {
        self.markers.markerDelegate = nil
        self.markers = nil
        
        self.background.removeFromParent()
        self.background = nil
        self.gameManager.delegate = nil
        self.gameManager = nil
    }
    
    func setScore(_ newScore: Int) {
//        scoresLabel.text = newScore.description
    }
    
    deinit {
        print("Game Scene deinit")
    }
}
