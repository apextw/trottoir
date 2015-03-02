//
//  GameViewController.swift
//  Asphalt
//
//  Created by Alexander Bekert on 10/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import UIKit
import SpriteKit
import iAd

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as SKScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

protocol adProtocol {
    func showAd(#scene: SceneShowingAdProtocol)
    func hideAd(#scene: SceneShowingAdProtocol)
}

class GameViewController: UIViewController {

    var adBannerView: ADBannerView!
    
    var wantsToShowAd = false
    var readyToShowAd = false
    var sceneToShowAd: SceneShowingAdProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GameCenterManager.sharedInstance.gameViewController = self
        let skView = self.view as SKView
        skView.ignoresSiblingOrder = true
        Touchprint.screenSize = skView.frame.size

        // Enable iAd
        loadAds()
        
        // Debug info
//        skView.showsFPS = true
//        skView.showsNodeCount = true
//        skView.showsDrawCount = true
//        skView.showsQuadCount = true
        
        if let menuScene = MainMenuScene.unarchiveFromFile("MainMenu") as? MainMenuScene {
            /* Set the scale mode to scale to fit the window */
            menuScene.size = skView.frame.size
            menuScene.scaleMode = SKSceneScaleMode.ResizeFill
            menuScene.adDelegate = self
            
            skView.presentScene(menuScene)
        }
    }
    
    func loadAds() {
        adBannerView = ADBannerView(frame: CGRect.zeroRect)
        adBannerView.center = CGPoint(x: adBannerView.center.x, y: view.bounds.size.height - adBannerView.frame.size.height / 2)
        adBannerView.delegate = self
        adBannerView.hidden = true
        view.addSubview(adBannerView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

extension GameViewController: ADBannerViewDelegate {
    
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        println("banner View Will Load Ad")
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        println("banner View Did Load Ad")
        readyToShowAd = true
        if wantsToShowAd && sceneToShowAd != nil {
            showAd(scene: sceneToShowAd!)
        }
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        println("banner View Action Should Begin")
        let skView = self.view as SKView
        skView.paused = true
        return true
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        println("banner View Action Did Finish")
        let skView = self.view as SKView
        skView.paused = false
    }
    
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        println("banner View did Fail To Receive Ad With Error")
        readyToShowAd = false
        if sceneToShowAd != nil && adBannerView != nil {
            adBannerView.hidden = true
            sceneToShowAd?.prepareForHidingAd()
        }
    }
}

extension GameViewController: adProtocol {
    func showAd(#scene: SceneShowingAdProtocol) {
        wantsToShowAd = true
        sceneToShowAd = scene
        if readyToShowAd {
            scene.prepareForShowingAdWithSize(adBannerView.frame.size)
            adBannerView.hidden = false
        }
    }
    
    func hideAd(#scene: SceneShowingAdProtocol) {
        wantsToShowAd = false
        sceneToShowAd = nil

        if adBannerView != nil {
            adBannerView.hidden = true
            scene.prepareForHidingAd()
        }
    }
}
