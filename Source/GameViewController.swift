//
//  GameViewController.swift
//  Asphalt
//
//  Created by Alexander Bekert on 10/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds

extension SKNode {
    class func unarchiveFromFile(_ file : NSString) -> SKNode? {
        if let path = Bundle.main.path(forResource: file as String, ofType: "sks") {
            let sceneData = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! SKScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

protocol adProtocol {
    func showAdBanner(scene: SceneShowingAdProtocol)
    func hideAd(scene: SceneShowingAdProtocol)
    func showAdFullscreenWithCompletion(_ completion: ((Void) -> Void)?)
}

class GameViewController: UIViewController {
    fileprivate var banner: GADBannerView!
    fileprivate var interstitial: GADInterstitial!
    fileprivate var interstitialDidClose: ((Void) -> Void)?
    
    var wantsToShowAd = false
    var readyToShowAd = false
    var sceneToShowAd: SceneShowingAdProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GameCenterManager.sharedInstance.gameViewController = self
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.isMultipleTouchEnabled = true
        Touchprint.screenSize = skView.frame.size

        // Enable Ad
        createAndLoadInterstitial()
        createAndLoadBanner()
        
        // Debug info
//        skView.showsFPS = true
//        skView.showsNodeCount = true
//        skView.showsDrawCount = true
//        skView.showsQuadCount = true
        
        if let menuScene = MainMenuScene.unarchiveFromFile("MainMenu") as? MainMenuScene {
            /* Set the scale mode to scale to fit the window */
            menuScene.size = skView.frame.size
            menuScene.scaleMode = SKSceneScaleMode.resizeFill
            menuScene.adDelegate = self
            
            skView.presentScene(menuScene)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    internal func createAndLoadInterstitial() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-7118034005818759/4865095025")
        interstitial.delegate = self
        interstitial.load(gadRequest())
    }
    
    internal func createAndLoadBanner() {
        
//        banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        let y = self.view.frame.size.height - CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height
        banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait, origin: CGPoint(x: 0, y: y))
        banner.adUnitID = "ca-app-pub-7118034005818759/2557430223"
        banner.rootViewController = self
        banner.delegate = self
        banner.isAutoloadEnabled = false

        banner.load(gadRequest())
    }
    
    internal func gadRequest() -> GADRequest {
        let request = GADRequest()
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made. GADInterstitial automatically returns test ads when running on a
        // simulator.
//        request.testDevices = [
//            "67def063eafa10c86d9461980e9bcc98"
//        ]
        return request
    }
}

extension GameViewController: adProtocol {
    func showAdBanner(scene: SceneShowingAdProtocol) {
        wantsToShowAd = true
        sceneToShowAd = scene
        
        if readyToShowAd {
            self.view.addSubview(banner)
            scene.prepareForShowingAdWithSize(banner.frame.size)
        }
    }
    
    func hideAd(scene: SceneShowingAdProtocol) {
        wantsToShowAd = false
        sceneToShowAd = nil
        
        if let banner = banner, banner.superview != nil {
            banner.load(gadRequest())
            banner.removeFromSuperview()
            scene.prepareForHidingAd()
        }
    }
    
    func showAdFullscreenWithCompletion(_ completion: ((Void) -> Void)?) {
        if interstitial.isReady {
            interstitialDidClose = completion
            interstitial.present(fromRootViewController: self)
        } else if let completion = completion {
            completion()
        }
    }
}

extension GameViewController: GADInterstitialDelegate {
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("AdMob: Failed to load interstitial ad")

        createAndLoadInterstitial()
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("AdMob: Interstitial ad disappeared")
        
        if let callback = interstitialDidClose {
            callback()
            interstitialDidClose = nil
        }
        
        createAndLoadInterstitial()
    }
}

extension GameViewController: GADBannerViewDelegate {
    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("AdMob: Banner View Did Fail To Receive Ad With Error")
        readyToShowAd = false
        if sceneToShowAd != nil {
            sceneToShowAd?.prepareForHidingAd()
        }
    }
    
    func adViewDidReceiveAd(_ view: GADBannerView) {
        print("AdMob: Banner View Did Receive Ad")
        self.readyToShowAd = true
        if wantsToShowAd && sceneToShowAd != nil {
            showAdBanner(scene: sceneToShowAd!)
        }
    }
}
