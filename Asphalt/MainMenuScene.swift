//
//  MainMenuScene.swift
//  Asphalt
//
//  Created by Alexander Bekert on 19/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {

    private var background: Background!
    private var uiLayer: SKNode!

    override func didMoveToView(view: SKView) {
        uiLayer = self.childNodeWithName("UI Layer")
        fillScreenWithBackground()
    }
    
    func fillScreenWithBackground() {
        
        if let backgroundLayer = self.childNodeWithName("BackgroundLayer") {
            if let backgroundPart = backgroundLayer.childNodeWithName("BackgroundPart") as? SKSpriteNode {
                background = Background(backgroundTileSprite: backgroundPart, screenSize: self.size)
                background.addTo(backgroundLayer)
            }
        }
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        presentGameScene()
    }
    
//    private func startPresentingGameScene() {
//        self.userInteractionEnabled = false
//        
//    }
    
    private func presentGameScene() {
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            scene.size = self.size
            scene.scaleMode = SKSceneScaleMode.ResizeFill

            uiLayer.removeFromParent()
            let backgroundRow = background.insertNodeToTheLastRow(uiLayer)
            uiLayer.position = CGPoint(x: 0, y: -backgroundRow.position.y)
            scene.background = self.background
            background.removeFromParent()
            
            self.view!.presentScene(scene)
        }
    }
}

