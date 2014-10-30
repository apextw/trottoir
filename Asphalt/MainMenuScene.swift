//
//  MainMenuScene.swift
//  Asphalt
//
//  Created by Alexander Bekert on 19/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import SpriteKit

protocol SceneShowingAdProtocol {
    func prepareForShowingAdWithSize(size: CGSize)
    func prepareForHidingAd()
    var scene: SKScene {
        get
    }
}

class MainMenuScene: SKScene {

    var adDelegate: adProtocol!
    
    internal var background: Background!
    internal var uiLayer: SKNode!
    
    private let drawing = Drawings.mainMenuDrawing;
    private let whiteStripe = SKSpriteNode(texture: SKTextureAtlas(named: "Asphalt").textureNamed("white-stripe"))
    private let musicSwitcher = Button(fontNamed: "Chalkduster")
    private let startButton = Button(fontNamed: "Chalkduster")
    private let gameCenterButton = Button(fontNamed: "Chalkduster")

//    private let performShiftDownSelector: Selector = "performShiftDown:"
//    private let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "performShiftDown:")
    internal var swipeUpRecognizer: UISwipeGestureRecognizer!
    internal var swipeDownRecognizer: UISwipeGestureRecognizer!

    private var isShowingResult = false
    var score: Int! = nil {
        didSet {
            isShowingResult = true
        }
    }
    var showNewLabel = false
    
    private var fingerprints: [SKSpriteNode] = []
    private let maxFingerprintsCount = 150
    private var tapsCounter = 0
    
    internal var adBannerSize = CGSize()
    
    override func didMoveToView(view: SKView) {
        uiLayer = self.childNodeWithName("UI Layer")
        fillScreenWithBackground()
        
        addWhiteStripe()
        initStartButton()
        initMusicSwitcher()
        initGameCenterButton()
        addDrawing()
        if isShowingResult {
            showScores()
            if showNewLabel {
                addNewLabel()
            }
            if adDelegate != nil {
                adDelegate.showAd(scene: self)
            }
        }
        
        addSwipeUpRecognizer()
    }
    
    private func fillScreenWithBackground() {
        if let backgroundLayer = self.childNodeWithName("BackgroundLayer") {
            if let backgroundPart = backgroundLayer.childNodeWithName("BackgroundPart") as? SKSpriteNode {
                background = Background(backgroundTileSprite: backgroundPart, screenSize: self.size)
                background.addTo(backgroundLayer)
            }
        }
    }
    
    private var labelLeftBorder: CGFloat {
        get {
            return self.size.width * 0.05
        }
    }

    private func initMusicSwitcher() {
        updateMusicSwitcherText()
        musicSwitcher.delegate = self
        uiLayer.addChild(musicSwitcher)
        musicSwitcher.zPosition = 1
    }
    
    private func updateMusicSwitcherText() {
        if AudioManager.sharedInstance.musicEnabled {
            musicSwitcher.text = "Music ON"
        } else {
            musicSwitcher.text = "Music OFF"
        }
        updateMusicSwitcherPosition()
    }
    
    internal func updateMusicSwitcherPosition() {
        var position = CGPoint(x: -self.size.width * 0.5, y: -self.size.height * 0.5)
        position.x += musicSwitcher.frame.size.width * 0.5 + labelLeftBorder
        position.y += musicSwitcher.frame.size.height * 0.5
        position.y += adBannerSize.height
        musicSwitcher.position = position
    }
    
    private func initGameCenterButton() {
        gameCenterButton.text = "Game Center"
//        gameCenterButton.fontSize = 72
        updateGameCenterButtonPosition()
        gameCenterButton.delegate = self
        uiLayer.addChild(gameCenterButton)
        gameCenterButton.zPosition = 1
    }
    
    internal func updateGameCenterButtonPosition() {
        var position = musicSwitcher.position
        position.y += musicSwitcher.frame.size.height / 2 + gameCenterButton.frame.size.height;
        position.x = -self.size.width * 0.5 + gameCenterButton.frame.size.width * 0.5 + labelLeftBorder;
        gameCenterButton.position = position
    }
    
    private func addWhiteStripe() {
//        let texture = SKTextureAtlas(named: "Asphalt").textureNamed("white-stripe")
//        whiteStripe = SKSpriteNode(texture: texture)
        let position = CGPoint(x: 0, y: self.size.height * 0.4)
        whiteStripe.position = position
        uiLayer.addChild(whiteStripe)
    }

    private func initStartButton() {
        if isShowingResult {
            startButton.text = "Run Again"
        } else {
            startButton.text = "StaRt"
        }
        startButton.fontSize = 72
        startButton.setScale(whiteStripe.size.width / startButton.frame.size.width)
        
        var position = whiteStripe.position
        position.y -= startButton.frame.size.height
        startButton.position = position
        startButton.delegate = self
        uiLayer.addChild(startButton)
        
        startButton.zPosition = 1
    }
    
    private func addDrawing() {
        if isShowingResult {
            drawing.position = CGPoint(x: self.size.width / 2 - drawing.size.width / 2, y: 0)
        } else {
            drawing.position = CGPoint(x: 0, y: 0)
        }
        uiLayer.addChild(drawing)
    }
    
    private func showScores() {
        let gameOver1 = SKLabelNode(fontNamed: "Chalkduster")
        gameOver1.text = "Game"
        gameOver1.fontSize = 36
        
        let gameOver2 = gameOver1.copy() as SKLabelNode
        gameOver2.text = "over"
        gameOver2.horizontalAlignmentMode = .Left
        
        gameOver1.zRotation = 0.2
        gameOver2.zRotation = 0.1
        
        var position = CGPoint(x: -gameOver1.frame.size.width * 0.15, y: gameOver1.frame.size.height * 0.8)
        gameOver1.position = position
        position.x += gameOver1.frame.size.width * 0.15
        position.y -= gameOver1.frame.size.height * 0.3
        gameOver2.position = position
        
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 65
        scoreLabel.position = CGPoint(x: 0, y: -scoreLabel.frame.size.height * 0.6)
        scoreLabel.zRotation = 0.1

        let node = SKNode()
        node.addChild(gameOver1)
        node.addChild(gameOver2)
        node.addChild(scoreLabel)
        node.position = CGPoint(x: -self.size.width * 0.2, y: 0)
        uiLayer.addChild(node)
    }
    
    private func addNewLabel() {
        let newLabel = SKLabelNode(fontNamed: "Chalkduster")
        newLabel.text = "NEW!"
        let x = drawing.size.width * 0.5 - newLabel.frame.size.width * 0.5 - 5
        let y = drawing.size.height * 0.5 - newLabel.frame.size.height * 0.5 - 5
        newLabel.position = CGPoint(x: x, y: y)
        newLabel.zRotation = -0.2
        drawing.addChild(newLabel)
    }
    
    private func presentGameScene() {
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            
            if adDelegate != nil {
                adDelegate.hideAd(scene: self)
                scene.adDelegate = adDelegate
            }
            
            scene.size = self.size
            scene.scaleMode = SKSceneScaleMode.ResizeFill

            disableButtons()
            disableRecognizers()
            
            uiLayer.removeFromParent()
            let backgroundRow = background.insertNodeToTheLastRow(uiLayer)
            uiLayer.position = CGPoint(x: 0, y: -backgroundRow.position.y)
            scene.background = self.background
            background.removeFromParent()
            background = nil
            uiLayer = nil
            
            self.view!.presentScene(scene)
        }
    }
    
    private func disableButtons() {
        startButton.enabled = false
        startButton.delegate = nil

        musicSwitcher.enabled = false
        musicSwitcher.delegate = nil
        
        gameCenterButton.enabled = false
        gameCenterButton.delegate = nil
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            ++tapsCounter
            
            let location = touch.locationInNode(uiLayer)
            addFingerprintToLocation(location)
            
            let dictionary: [NSObject: AnyObject] = ["Count" : tapsCounter]
            Flurry.logEvent("Left_a_fingerprint_in_menu", withParameters: dictionary)
        }
//        performShiftDown()
    }
    
    private func addFingerprintToLocation(location: CGPoint) {
        let touchprint = Touchprint.touchprintWithTouchLocation(location)
        touchprint.position = location
        touchprint.color = fingerprintColor()
        touchprint.colorBlendFactor = 1
        touchprint.zPosition = 1
        
        if fingerprints.count == maxFingerprintsCount {
            let firstTouch = fingerprints.first!
            firstTouch.removeFromParent()
            fingerprints.removeAtIndex(0)
        }
        
        uiLayer.addChild(touchprint)
        fingerprints.append(touchprint)
    }
    
    private func fingerprintColor() -> SKColor {
        let red = CGFloat(arc4random() % 100) * 0.003 + 0.7
        let green = CGFloat(arc4random() % 100) * 0.003 + 0.7
        let blue = CGFloat(arc4random() % 100) * 0.003 + 0.7

        return SKColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    override func didChangeSize(oldSize: CGSize) {
        println("New scene size. Width: \(size.width), height: \(size.height)")
        updateMusicSwitcherPosition()
        updateGameCenterButtonPosition()
    }
    
    deinit {
        println("Menu Scene deinit")
    }
}

// MARK: Button Protocol
extension MainMenuScene: ButtonProtocol {
    func didTouchDownButton(sender: Button, position: CGPoint) {
        let uiPosition = uiLayer.convertPoint(position, fromNode: sender)
        addFingerprintToLocation(uiPosition)
    }
    
    func didTouchUpInsideButton(sender: Button, position: CGPoint) {
        if sender === musicSwitcher {
            AudioManager.sharedInstance.switchMusicEnabled()
            updateMusicSwitcherText()
        } else if sender === startButton {
            presentGameScene()
        } else if sender === gameCenterButton {
            println("Open Game Center")
            GameCenterManager.sharedInstance.presentGameCenterViewController()
        } else if let senderName = sender.name {
            if senderName == "Push Out button" {
                Flurry.logEvent("Opened_Push_Out_link")
                let link = "itms-apps://itunes.apple.com/us/app/push-out-friends-competition/id899582393?ls=1&mt=8"
                if let url = NSURL(string: link) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }
    }
}