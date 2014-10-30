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

// MARK: Scene Showing Ad Protocol
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