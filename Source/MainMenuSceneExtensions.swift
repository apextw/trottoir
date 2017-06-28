import SpriteKit

// MARK: Gesture Recognizers
extension MainMenuScene {
    
    internal func addSwipeUpRecognizer() {
        if self.swipeDownRecognizer != nil {
            self.view!.removeGestureRecognizer(swipeDownRecognizer)
        }
        
        if swipeUpRecognizer == nil {
            swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MainMenuScene.performShiftDown(_:)))
            swipeUpRecognizer.direction = UISwipeGestureRecognizerDirection.up
        }
        self.view!.addGestureRecognizer(swipeUpRecognizer)
    }
    
    internal func addSwipeDownRecognizer() {
        if swipeUpRecognizer != nil {
            self.view!.removeGestureRecognizer(swipeUpRecognizer)
        }
        
        if swipeDownRecognizer == nil {
            swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MainMenuScene.performShiftUp(_:)))
            swipeDownRecognizer.direction = UISwipeGestureRecognizerDirection.down
        }
        self.view!.addGestureRecognizer(swipeDownRecognizer)
    }
    
    internal func disableRecognizers () {
        if (swipeDownRecognizer != nil) {
            self.view!.removeGestureRecognizer(swipeDownRecognizer)
            swipeDownRecognizer = nil
        }
        if (swipeUpRecognizer != nil) {
            self.view!.removeGestureRecognizer(swipeUpRecognizer)
            swipeUpRecognizer = nil
        }
    }
    
    internal func performShiftDown(_ sender: AnyObject) {
        addSwipeDownRecognizer()
        
        background.prepareScreenBelow()
        addInformation()
        
        let shiftAction = SKAction.moveBy(x: 0, y: self.size.height, duration: 0.5)
        shiftAction.timingMode = SKActionTimingMode.easeOut
        uiLayer.run(shiftAction)
        let backgroundLayer = self.childNode(withName: "BackgroundLayer")!
        backgroundLayer.run(shiftAction)
        
        Flurry.logEvent("Shifted_to_information_screen")
    }
    
    fileprivate func addInformation() {
        let informationLayer = SKNode()
        informationLayer.name = "Information layer"
        
        // Push Out Checkout Button
        let checkOutGameButton = checkOutButton()
        checkOutGameButton.position = CGPoint(x: 0, y: -size.height * 0.26)
        informationLayer.addChild(checkOutGameButton)
        
        // Game By Info
        let gameByInfoLayer = gameByInfo()
        gameByInfoLayer.position = CGPoint(x: 0, y: size.height / 2.7)
        informationLayer.addChild(gameByInfoLayer)
        
        // Drawings By Info
        let drawingsByInfoLayer = drawingsByInfo()
        drawingsByInfoLayer.position = CGPoint(x: 0, y: size.height / 8)
        informationLayer.addChild(drawingsByInfoLayer)

        informationLayer.position = CGPoint(x: 0, y: -self.size.height)
        uiLayer.addChild(informationLayer)
    }
    
    fileprivate func checkOutButton() -> SKNode {
        let buttonLayer = SKNode()
        buttonLayer.name = "Check out layer"
        var position = CGPoint()
        let blueColor = SKColor(red: 0.8, green: 1, blue: 0.8, alpha: 1)
        let yellowColor = SKColor(red: 1, green: 1, blue: 0.4, alpha: 1)

        let basicSize: CGFloat = 20.0 * DisplayHelper.FontScale
        let marginScale: CGFloat = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone ? 1 : 1.2
        
        let row1 = Button(fontNamed: DisplayHelper.FontName)
        row1.text =  NSLocalizedString("Push Out 1'st row", comment: "Check out")
        row1.name = "Push Out button"
        row1.delegate = self
        row1.fontColor = blueColor
        row1.fontSize = 2.2 * basicSize
        position.y = 1.5 * row1.frame.size.height * marginScale
        row1.position = position
        row1.zRotation = 0.17
        
        let row2 = Button(fontNamed: DisplayHelper.FontName)
        row2.text = NSLocalizedString("Push Out 2'nd row", comment: "our competition")
        row2.name = "Push Out button"
        row2.delegate = self
        row2.fontColor = blueColor
        row2.fontSize = 1.2 * basicSize
        position.y = 0.4 * row1.position.y * marginScale
        position.x = -0.1 * row2.frame.size.width * marginScale
        row2.position = position
        row2.zRotation = 0.16
        
        let row3 = Button(fontNamed: DisplayHelper.FontName)
        row3.text = NSLocalizedString("Push Out 3'rd row", comment: "game")
        row3.name = "Push Out button"
        row3.delegate = self
        row3.fontColor = blueColor
        row3.fontSize = 2 * basicSize
        position.y = 0.2 * row3.frame.size.height * marginScale
        position.x = (row2.position.x + 0.5 * row2.frame.size.width) * marginScale
        row3.position = position
        row3.zRotation = 0.1
        
        let row4 = Button(fontNamed: DisplayHelper.FontName)
        row4.text = NSLocalizedString("Push Out title", comment: "Push Out")
        row4.name = "Push Out button"
        row4.delegate = self
        row4.fontColor = yellowColor
        row4.fontSize = 2.5 * basicSize
        position.x = -0.08 * row4.frame.size.width * marginScale
        position.y = -0.95 * row4.frame.size.height * marginScale
        row4.position = position
        row4.zRotation = 0.075
        
        let row5 = Button(fontNamed: DisplayHelper.FontName)
        row5.text = NSLocalizedString("Only on the App Store", comment: "Only on the App Store")
        row5.name = "Push Out button"
        row5.delegate = self
        row5.fontColor = SKColor.white
        row5.fontSize = basicSize
        position.y = (row4.position.y - (row4.frame.size.height * 0.4)) * marginScale
        position.x = 0
        row5.position = position
        row5.zRotation = 0.03
        
        buttonLayer.addChild(row1)
        buttonLayer.addChild(row2)
        buttonLayer.addChild(row3)
        buttonLayer.addChild(row4)
        buttonLayer.addChild(row5)
        
        return buttonLayer
    }
    
    fileprivate func gameByInfo() -> SKNode {
        let gameByLayer = SKNode()
        
//        if let giraffeTexture = SKTextureAtlas(named: "Drawings").textureNamed("giraffe-with-laptop") {
        let giraffeTexture = SKTexture(imageNamed: "giraffe-with-laptop")
        let giraffe = SKSpriteNode(texture: giraffeTexture)
        var x = -size.width * 0.3
        giraffe.position = CGPoint(x: x, y: 0)
        gameByLayer.addChild(giraffe)
        
        let fontName = DisplayHelper.FontName
        let basicSize: CGFloat = 17.0 * DisplayHelper.FontScale
        let angle: CGFloat = -0.1

        let gameByLabel = SKLabelNode(fontNamed: fontName)
        gameByLabel.text = NSLocalizedString("Game by label", comment: "Game by")
        gameByLabel.fontColor = SKColor.white
        gameByLabel.fontSize = 1.2 * basicSize
        gameByLabel.verticalAlignmentMode = .bottom
        gameByLabel.horizontalAlignmentMode = .left
        var y: CGFloat
        if Bundle.main.preferredLocalizations[0] as NSString == "ru" {
            x = size.width * 0.1
            y = gameByLabel.frame.size.height * 0.8
        } else {
            x = -size.width * 0.035
            y = gameByLabel.frame.size.height * 0.6
        }
        gameByLabel.position = CGPoint(x: x, y: y)
        gameByLabel.zRotation = angle

        let nameLabel = SKLabelNode(fontNamed: fontName)
        nameLabel.text = NSLocalizedString("Game by first name", comment: "Alexander")
        nameLabel.fontColor = SKColor(red: 0.8, green: 1, blue: 1, alpha: 1)
        nameLabel.verticalAlignmentMode = .bottom
        nameLabel.horizontalAlignmentMode = .left
        if Bundle.main.preferredLocalizations[0] as NSString == "ru" {
            nameLabel.fontSize = 1.7 * basicSize
        } else {
            nameLabel.fontSize = 1.9 * basicSize
        }
        x = -size.width * 0.12
        y = -nameLabel.frame.size.height * 0.01
        nameLabel.position = CGPoint(x: x, y: y)
        nameLabel.zRotation = angle
        
        let surnameLabel = SKLabelNode(fontNamed: fontName)
        surnameLabel.text = NSLocalizedString("Game by last name", comment: "Bekert")
        surnameLabel.fontColor = SKColor(red: 0.8, green: 1, blue: 1, alpha: 1)
        surnameLabel.fontSize = 2 * basicSize
        surnameLabel.verticalAlignmentMode = .bottom
        surnameLabel.horizontalAlignmentMode = .left
        x = -size.width * 0.07
        y = -surnameLabel.frame.size.height
        surnameLabel.position = CGPoint(x: x, y: y)
        surnameLabel.zRotation = angle

        gameByLayer.addChild(gameByLabel)
        gameByLayer.addChild(nameLabel)
        gameByLayer.addChild(surnameLabel)
        
        return gameByLayer
    }
    
    fileprivate func drawingsByInfo() -> SKNode {
        let drawingsByLayer = SKNode()
        
//        if let giraffeTexture = SKTextureAtlas(named: "Drawings").textureNamed("giraffe-painter") {
        let giraffeTexture = SKTexture(imageNamed: "giraffe-painter")
        let giraffe = SKSpriteNode(texture: giraffeTexture)
        var x = size.width * 0.3
        giraffe.position = CGPoint(x: x, y: 0)
        drawingsByLayer.addChild(giraffe)
        
        let fontName = DisplayHelper.FontName
        let basicSize: CGFloat = 17.0 * DisplayHelper.FontScale
        let marginScale: CGFloat = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone ? 1 : 0.5

        let angle: CGFloat = 0.19
        
        let shinyLabel = SKLabelNode(fontNamed: fontName)
        shinyLabel.text = NSLocalizedString("Drawings by label 1'st row", comment: "Shiny")
        shinyLabel.fontColor = SKColor.white
        shinyLabel.fontSize = 1.2 * basicSize
        shinyLabel.verticalAlignmentMode = .bottom
        shinyLabel.horizontalAlignmentMode = .left
        x = -size.width * 0.4 * marginScale
        var y = shinyLabel.frame.size.height * 0.17
        shinyLabel.position = CGPoint(x: x, y: y)
        shinyLabel.zRotation = angle
        
        let drawingsByLabel = SKLabelNode(fontNamed: fontName)
        drawingsByLabel.text = NSLocalizedString("Drawings by label 2'nd row", comment: "drawings by")
        drawingsByLabel.fontColor = SKColor.white
        drawingsByLabel.fontSize = 1.2 * basicSize
        drawingsByLabel.verticalAlignmentMode = .bottom
        drawingsByLabel.horizontalAlignmentMode = .left
        x = -size.width * 0.3 * marginScale
        y = -drawingsByLabel.frame.size.height * 0.5
        drawingsByLabel.position = CGPoint(x: x, y: y)
        drawingsByLabel.zRotation = angle
        
        let nameLabel = SKLabelNode(fontNamed: fontName)
        nameLabel.text = NSLocalizedString("Drawings by first name", comment: "Tatsiana")
        nameLabel.fontColor = SKColor(red: 1, green: 0.8, blue: 0.6, alpha: 1)
        nameLabel.fontSize = 1.9 * basicSize
        nameLabel.verticalAlignmentMode = .bottom
        nameLabel.horizontalAlignmentMode = .left
        x = -size.width * 0.46 * marginScale
        y = -nameLabel.frame.size.height * 1.7
        nameLabel.position = CGPoint(x: x, y: y)
        nameLabel.zRotation = angle
        
        let surnameLabel = SKLabelNode(fontNamed: fontName)
        surnameLabel.text = NSLocalizedString("Drawings by last name", comment: "Volkova")
        surnameLabel.fontColor = SKColor(red: 1, green: 0.8, blue: 0.6, alpha: 1)
        surnameLabel.fontSize = 2 * basicSize
        surnameLabel.verticalAlignmentMode = .bottom
        surnameLabel.horizontalAlignmentMode = .left
        x = -size.width * 0.35 * marginScale
        y = -surnameLabel.frame.size.height * 2.4
        surnameLabel.position = CGPoint(x: x, y: y)
        surnameLabel.zRotation = angle
        
        drawingsByLayer.addChild(shinyLabel)
        drawingsByLayer.addChild(drawingsByLabel)
        drawingsByLayer.addChild(nameLabel)
        drawingsByLayer.addChild(surnameLabel)
        
        return drawingsByLayer
    }

    
    internal func performShiftUp(_ sender: AnyObject) {
        self.view!.removeGestureRecognizer(swipeDownRecognizer)
        self.view!.addGestureRecognizer(swipeUpRecognizer)
        
        let shiftAction = SKAction.moveBy(x: 0, y: -self.size.height, duration: 0.5)
        shiftAction.timingMode = SKActionTimingMode.easeOut
        uiLayer.run(shiftAction)
        let backgroundLayer = self.childNode(withName: "BackgroundLayer")!
        backgroundLayer.run(shiftAction, completion: { () -> Void in
            self.background.removeInvisibleRows()
            self.removeInformation()
        })
        
        Flurry.logEvent("Shifted_back_to_menu")
    }
    
    fileprivate func removeInformation() {
        if let informationLayer = uiLayer.childNode(withName: "Information layer") {
            informationLayer.removeFromParent()
        }
    }
}

// MARK: Scene Showing Ad Protocol
extension MainMenuScene: SceneShowingAdProtocol {
    func prepareForHidingAd() {
        adBannerSize = CGSize(width: 0, height: 0)
        updateMusicSwitcherPosition()
        updateGameCenterButtonPosition()
        updateRateGameButtonPosition()
        
        rateGameButton.isHidden = false
        if rateGameStars != nil {
            rateGameStars.isHidden = false
        }
    }
    
    func prepareForShowingAdWithSize(_ size: CGSize) {
        adBannerSize = size
        updateMusicSwitcherPosition()
        updateGameCenterButtonPosition()
        updateRateGameButtonPosition()
        
        rateGameButton.isHidden = true
        if rateGameStars != nil {
            rateGameStars.isHidden = true
        }
    }
    
    override var scene: SKScene {
        get {
            return self
        }
    }
}
