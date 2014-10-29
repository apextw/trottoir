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
    
    private var background: Background!
    private var uiLayer: SKNode!
    
    private let drawing = Drawings.mainMenuDrawing;
    private let whiteStripe = SKSpriteNode(texture: SKTextureAtlas(named: "Asphalt").textureNamed("white-stripe"))
    private let musicSwitcher = Button(fontNamed: "Chalkduster")
    private let startButton = Button(fontNamed: "Chalkduster")
    private let gameCenterButton = Button(fontNamed: "Chalkduster")

//    private let performShiftDownSelector: Selector = "performShiftDown:"
//    private let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "performShiftDown:")
    private var swipeUpRecognizer: UISwipeGestureRecognizer!
    private var swipeDownRecognizer: UISwipeGestureRecognizer!

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
    
    private var adBannerSize = CGSize()
    
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
    }
    
    private func updateMusicSwitcherText() {
        if AudioManager.sharedInstance.musicEnabled {
            musicSwitcher.text = "Music ON"
        } else {
            musicSwitcher.text = "Music OFF"
        }
        updateMusicSwitcherPosition()
    }
    
    private func updateMusicSwitcherPosition() {
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
    }
    
    private func updateGameCenterButtonPosition() {
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
            
            let dictionary: [NSObject: AnyObject] = ["Count" : tapsCounter]
            Flurry.logEvent("Left_a_fingerprint_in_menu", withParameters: dictionary)
        }
//        performShiftDown()
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
    func didTouchDownButton(sender: Button) {
        
    }
    
    func didTouchUpInsideButton(sender: Button) {
        if sender === musicSwitcher {
            AudioManager.sharedInstance.switchMusicEnabled()
            updateMusicSwitcherText()
        } else if sender === startButton {
            presentGameScene()
        } else if sender === gameCenterButton {
            println("Open Game Center")
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

extension MainMenuScene {
    
    private func addSwipeUpRecognizer() {
        if swipeDownRecognizer != nil {
            self.view!.removeGestureRecognizer(swipeDownRecognizer)
        }
        
        if swipeUpRecognizer == nil {
            swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "performShiftDown:")
            swipeUpRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        }
        self.view!.addGestureRecognizer(swipeUpRecognizer)
    }
    
    private func addSwipeDownRecognizer() {
        if swipeUpRecognizer != nil {
            self.view!.removeGestureRecognizer(swipeUpRecognizer)
        }
        
        if swipeDownRecognizer == nil {
            swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "performShiftUp:")
            swipeDownRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        }
        self.view!.addGestureRecognizer(swipeDownRecognizer)
    }
    
    private func disableRecognizers () {
        if (swipeDownRecognizer != nil) {
            self.view!.removeGestureRecognizer(swipeDownRecognizer)
            swipeDownRecognizer = nil
        }
        if (swipeUpRecognizer != nil) {
            self.view!.removeGestureRecognizer(swipeUpRecognizer)
            swipeUpRecognizer = nil
        }
    }

    internal func performShiftDown(sender: AnyObject) {
        addSwipeDownRecognizer()
        
        background.prepareScreenBelow()
        addInformation()
        
        let shiftAction = SKAction.moveByX(0, y: self.size.height, duration: 0.5)
        shiftAction.timingMode = SKActionTimingMode.EaseOut
        uiLayer.runAction(shiftAction)
        let backgroundLayer = self.childNodeWithName("BackgroundLayer")!
        backgroundLayer.runAction(shiftAction)
        
        Flurry.logEvent("Shifted_to_information_screen")
    }
    
    private func addInformation() {
        let informationLayer = SKNode()
        informationLayer.name = "Information layer"
        
        let checkOutGameButton = checkOutButton()
        informationLayer.addChild(checkOutGameButton)

        
        informationLayer.position = CGPoint(x: 0, y: -self.size.height)
        uiLayer.addChild(informationLayer)
    }
    
    private func checkOutButton() -> SKNode {
        let buttonLayer = SKNode()
        buttonLayer.name = "Check out layer"
        var position = CGPoint()
        let blueColor = SKColor(red: 178 / 255.0, green: 247 / 255.0, blue: 251 / 255.0, alpha: 1)
        let yellowColor = SKColor(red: 251 / 255.0, green: 250 / 255.0, blue: 178 / 255.0, alpha: 1)
        let basicSize: CGFloat = 20.0
        
        let row1 = Button(fontNamed: "Chalkduster")
        row1.text = "Check out"
        row1.name = "Push Out button"
        row1.delegate = self
        row1.fontColor = blueColor
        row1.fontSize = 2.2 * basicSize
        position.y = 1.5 * row1.frame.size.height
        row1.position = position
        row1.zRotation = 0.2
        
        let row2 = Button(fontNamed: "Chalkduster")
        row2.text = "our competition"
        row2.name = "Push Out button"
        row2.delegate = self
        row2.fontColor = blueColor
        row2.fontSize = 1.2 * basicSize
        position.y = 0.4 * row1.position.y
        position.x = -0.1 * row2.frame.size.width
        row2.position = position
        row2.zRotation = 0.16

        let row3 = Button(fontNamed: "Chalkduster")
        row3.text = "game"
        row3.name = "Push Out button"
        row3.delegate = self
        row3.fontColor = blueColor
        row3.fontSize = 2 * basicSize
        position.y = 0.2 * row3.frame.size.height
        position.x = row2.position.x + 0.5 * row2.frame.size.width
        row3.position = position
        row3.zRotation = 0.08
        
        let row4 = Button(fontNamed: "Chalkduster")
        row4.text = "Push Out"
        row4.name = "Push Out button"
        row4.delegate = self
        row4.fontColor = yellowColor
        row4.fontSize = 2.5 * basicSize
        position.x = -0.1 * row4.frame.size.width
        position.y = -1 * row4.frame.size.height
        row4.position = position
        row4.zRotation = 0.1

        let row5 = Button(fontNamed: "Chalkduster")
        row5.text = "only on the App Store"
        row5.name = "Push Out button"
        row5.delegate = self
        row5.fontColor = SKColor.whiteColor()
        row5.fontSize = basicSize
        position.y = row4.position.y - (row4.frame.size.height * 0.4) //- row5.frame.size.height / 2
        position.x = 0
        row5.position = position
        row5.zRotation = 0.05
        
        buttonLayer.addChild(row1)
        buttonLayer.addChild(row2)
        buttonLayer.addChild(row3)
        buttonLayer.addChild(row4)
        buttonLayer.addChild(row5)
        
        return buttonLayer
    }
    
    internal func performShiftUp(sender: AnyObject) {
        self.view!.removeGestureRecognizer(swipeDownRecognizer)
        self.view!.addGestureRecognizer(swipeUpRecognizer)
        
        let shiftAction = SKAction.moveByX(0, y: -self.size.height, duration: 0.5)
        shiftAction.timingMode = SKActionTimingMode.EaseOut
        uiLayer.runAction(shiftAction)
        let backgroundLayer = self.childNodeWithName("BackgroundLayer")!
        backgroundLayer.runAction(shiftAction, completion: { () -> Void in
            self.background.removeInvisibleRows()
            self.removeInformation()
        })
        
        Flurry.logEvent("Shifted_back_to_menu")
    }

    private func removeInformation() {
        if let informationLayer = uiLayer.childNodeWithName("Information layer") {
            informationLayer.removeFromParent()
        }
    }
}

extension MainMenuScene: SceneShowingAdProtocol {
    func prepareForHidingAd() {
        adBannerSize = CGSize(width: 0, height: 0)
        updateMusicSwitcherPosition()
        updateGameCenterButtonPosition()
    }
    
    func prepareForShowingAdWithSize(size: CGSize) {
        adBannerSize = size
        updateMusicSwitcherPosition()
        updateGameCenterButtonPosition()
    }
    
    override var scene: SKScene {
        get {
            return self
        }
    }
}