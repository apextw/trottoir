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
import GoogleMobileAds

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! SKScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

protocol adProtocol {
    func showAdBanner(scene scene: SceneShowingAdProtocol)
    func hideAd(scene scene: SceneShowingAdProtocol)
    func showAdFullscreenWithCompletion(completion: (Void -> Void)?)
}

class GameViewController: UIViewController {

    var adBannerView: ADBannerView!
    
    private var banner: GADBannerView!
    private var interstitial: GADInterstitial!
    private var interstitialDidClose: (Void -> Void)?
    
    var wantsToShowAd = false
    var readyToShowAd = false
    var sceneToShowAd: SceneShowingAdProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GameCenterManager.sharedInstance.gameViewController = self
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        Touchprint.screenSize = skView.frame.size

        // Enable Ad
//        loadAds()
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
            menuScene.scaleMode = SKSceneScaleMode.ResizeFill
            menuScene.adDelegate = self
            
            skView.presentScene(menuScene)
        }
    }
    
    func loadAds() {
        adBannerView = ADBannerView(frame: CGRect.zero)
        adBannerView.center = CGPoint(x: adBannerView.center.x, y: view.bounds.size.height - adBannerView.frame.size.height / 2)
        adBannerView.delegate = self
        adBannerView.hidden = true
        view.addSubview(adBannerView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    internal func createAndLoadInterstitial() {
        interstitial = GADInterstitial (adUnitID: "ca-app-pub-7118034005818759/4865095025")
        interstitial.delegate = self;
        
        let request = GADRequest();
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made. GADInterstitial automatically returns test ads when running on a
        // simulator.
//        request.testDevices = [
//        "67def063eafa10c86d9461980e9bcc98"
//        ]
        interstitial.loadRequest(request)
    }
    
    internal func createAndLoadBanner() {
        
//        banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        let y = self.view.frame.size.height - CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height
        banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait, origin: CGPoint(x: 0, y: y))
        banner.adUnitID = "ca-app-pub-7118034005818759/2557430223"
        banner.rootViewController = self;
        banner.delegate = self;
        
        let request = GADRequest();
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made. GADInterstitial automatically returns test ads when running on a
        // simulator.
//        request.testDevices = [
//            "67def063eafa10c86d9461980e9bcc98"
//        ]
        banner.loadRequest(request)
    }
}

extension GameViewController: ADBannerViewDelegate {
    
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        print("banner View Will Load Ad")
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        print("banner View Did Load Ad")
        readyToShowAd = true
        if wantsToShowAd && sceneToShowAd != nil {
            showAdBanner(scene: sceneToShowAd!)
        }
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        print("banner View Action Should Begin")
        let skView = self.view as! SKView
        skView.paused = true
        return true
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        print("banner View Action Did Finish")
        let skView = self.view as! SKView
        skView.paused = false
    }
    
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print("banner View did Fail To Receive Ad With Error")
        readyToShowAd = false
        if sceneToShowAd != nil && adBannerView != nil {
            adBannerView.hidden = true
            sceneToShowAd?.prepareForHidingAd()
        }
    }
}

extension GameViewController: adProtocol {
    func showAdBanner(scene scene: SceneShowingAdProtocol) {
        wantsToShowAd = true
        sceneToShowAd = scene
        
        if readyToShowAd {
            self.view.addSubview(banner)
            scene.prepareForShowingAdWithSize(banner.frame.size)
        }
    }
    
    func hideAd(scene scene: SceneShowingAdProtocol) {
        wantsToShowAd = false
        sceneToShowAd = nil
        
        if banner != nil && banner.superview != nil {
            banner.removeFromSuperview()
            scene.prepareForHidingAd()
        }
    }
    
    func showAdFullscreenWithCompletion(completion: (Void -> Void)?) {
        if interstitial.isReady {
            interstitialDidClose = completion
            interstitial.presentFromRootViewController(self)
        } else if completion != nil {
            completion!()
        }
    }
}

extension GameViewController: GADInterstitialDelegate {
    
    func interstitial(ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("AdMob: Failed to load interstitial ad")

        createAndLoadInterstitial()
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        print("AdMob: Interstitial ad disappeared")
        
        if interstitialDidClose != nil {
            interstitialDidClose!()
            interstitialDidClose = nil
        }
        
        createAndLoadInterstitial()
    }
}

extension GameViewController: GADBannerViewDelegate {
    func adView(view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("AdMob: Banner View Did Fail To Receive Ad With Error")
        readyToShowAd = false
        if sceneToShowAd != nil && adBannerView != nil {
            adBannerView.hidden = true
            sceneToShowAd?.prepareForHidingAd()
        }
    }
    
    func adViewDidReceiveAd(view: GADBannerView!) {
        print("AdMob: Banner View Did Receive Ad")
        self.readyToShowAd = true
        if wantsToShowAd && sceneToShowAd != nil {
            showAdBanner(scene: sceneToShowAd!)
        }
    }
}
