import SpriteKit

// MARK: Gesture Recognizers
extension MainMenuScene {
    
    internal func addSwipeUpRecognizer() {
        if self.swipeDownRecognizer != nil {
            self.view!.removeGestureRecognizer(swipeDownRecognizer)
        }
        
        if swipeUpRecognizer == nil {
            swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "performShiftDown:")
            swipeUpRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        }
        self.view!.addGestureRecognizer(swipeUpRecognizer)
    }
    
    internal func addSwipeDownRecognizer() {
        if swipeUpRecognizer != nil {
            self.view!.removeGestureRecognizer(swipeUpRecognizer)
        }
        
        if swipeDownRecognizer == nil {
            swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "performShiftUp:")
            swipeDownRecognizer.direction = UISwipeGestureRecognizerDirection.Down
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
    
    private func checkOutButton() -> SKNode {
        let buttonLayer = SKNode()
        buttonLayer.name = "Check out layer"
        var position = CGPoint()
        let blueColor = SKColor(red: 0.8, green: 1, blue: 0.8, alpha: 1)
        let yellowColor = SKColor(red: 1, green: 1, blue: 0.4, alpha: 1)

        let basicSize: CGFloat = 20.0 * DisplayHelper.FontScale
        let marginScale: CGFloat = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone ? 1 : 1.2
        
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
        row5.fontColor = SKColor.whiteColor()
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
    
    private func gameByInfo() -> SKNode {
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
        gameByLabel.fontColor = SKColor.whiteColor()
        gameByLabel.fontSize = 1.2 * basicSize
        gameByLabel.verticalAlignmentMode = .Bottom
        gameByLabel.horizontalAlignmentMode = .Left
        var y: CGFloat
        if NSBundle.mainBundle().preferredLocalizations[0] as NSString == "ru" {
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
        nameLabel.verticalAlignmentMode = .Bottom
        nameLabel.horizontalAlignmentMode = .Left
        if NSBundle.mainBundle().preferredLocalizations[0] as NSString == "ru" {
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
        surnameLabel.verticalAlignmentMode = .Bottom
        surnameLabel.horizontalAlignmentMode = .Left
        x = -size.width * 0.07
        y = -surnameLabel.frame.size.height
        surnameLabel.position = CGPoint(x: x, y: y)
        surnameLabel.zRotation = angle

        gameByLayer.addChild(gameByLabel)
        gameByLayer.addChild(nameLabel)
        gameByLayer.addChild(surnameLabel)
        
        return gameByLayer
    }
    
    private func drawingsByInfo() -> SKNode {
        let drawingsByLayer = SKNode()
        
//        if let giraffeTexture = SKTextureAtlas(named: "Drawings").textureNamed("giraffe-painter") {
        let giraffeTexture = SKTexture(imageNamed: "giraffe-painter")
        let giraffe = SKSpriteNode(texture: giraffeTexture)
        var x = size.width * 0.3
        giraffe.position = CGPoint(x: x, y: 0)
        drawingsByLayer.addChild(giraffe)
        
        let fontName = DisplayHelper.FontName
        let basicSize: CGFloat = 17.0 * DisplayHelper.FontScale
        let marginScale: CGFloat = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone ? 1 : 0.5

        let angle: CGFloat = 0.19
        
        let shinyLabel = SKLabelNode(fontNamed: fontName)
        shinyLabel.text = NSLocalizedString("Drawings by label 1'st row", comment: "Shiny")
        shinyLabel.fontColor = SKColor.whiteColor()
        shinyLabel.fontSize = 1.2 * basicSize
        shinyLabel.verticalAlignmentMode = .Bottom
        shinyLabel.horizontalAlignmentMode = .Left
        x = -size.width * 0.4 * marginScale
        var y = shinyLabel.frame.size.height * 0.17
        shinyLabel.position = CGPoint(x: x, y: y)
        shinyLabel.zRotation = angle
        
        let drawingsByLabel = SKLabelNode(fontNamed: fontName)
        drawingsByLabel.text = NSLocalizedString("Drawings by label 2'nd row", comment: "drawings by")
        drawingsByLabel.fontColor = SKColor.whiteColor()
        drawingsByLabel.fontSize = 1.2 * basicSize
        drawingsByLabel.verticalAlignmentMode = .Bottom
        drawingsByLabel.horizontalAlignmentMode = .Left
        x = -size.width * 0.3 * marginScale
        y = -drawingsByLabel.frame.size.height * 0.5
        drawingsByLabel.position = CGPoint(x: x, y: y)
        drawingsByLabel.zRotation = angle
        
        let nameLabel = SKLabelNode(fontNamed: fontName)
        nameLabel.text = NSLocalizedString("Drawings by first name", comment: "Tatsiana")
        nameLabel.fontColor = SKColor(red: 1, green: 0.8, blue: 0.6, alpha: 1)
        nameLabel.fontSize = 1.9 * basicSize
        nameLabel.verticalAlignmentMode = .Bottom
        nameLabel.horizontalAlignmentMode = .Left
        x = -size.width * 0.46 * marginScale
        y = -nameLabel.frame.size.height * 1.7
        nameLabel.position = CGPoint(x: x, y: y)
        nameLabel.zRotation = angle
        
        let surnameLabel = SKLabelNode(fontNamed: fontName)
        surnameLabel.text = NSLocalizedString("Drawings by last name", comment: "Volkova")
        surnameLabel.fontColor = SKColor(red: 1, green: 0.8, blue: 0.6, alpha: 1)
        surnameLabel.fontSize = 2 * basicSize
        surnameLabel.verticalAlignmentMode = .Bottom
        surnameLabel.horizontalAlignmentMode = .Left
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

// MARK: Scene Showing Ad Protocol
extension MainMenuScene: SceneShowingAdProtocol {
    func prepareForHidingAd() {
        adBannerSize = CGSize(width: 0, height: 0)
        updateMusicSwitcherPosition()
        updateGameCenterButtonPosition()
        updateRateGameButtonPosition()
        
        rateGameButton.hidden = false
        if rateGameStars != nil {
            rateGameStars.hidden = false
        }
    }
    
    func prepareForShowingAdWithSize(size: CGSize) {
        adBannerSize = size
        updateMusicSwitcherPosition()
        updateGameCenterButtonPosition()
        updateRateGameButtonPosition()
        
        rateGameButton.hidden = true
        if rateGameStars != nil {
            rateGameStars.hidden = true
        }
    }
    
    override var scene: SKScene {
        get {
            return self
        }
    }
}