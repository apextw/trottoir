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

    var adBannerView: ADBannerView!
    
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
            menuScene.scaleMode = SKSceneScaleMode.resizeFill
            menuScene.adDelegate = self
            
            skView.presentScene(menuScene)
        }
    }
    
    func loadAds() {
        adBannerView = ADBannerView(frame: CGRect.zero)
        adBannerView.center = CGPoint(x: adBannerView.center.x, y: view.bounds.size.height - adBannerView.frame.size.height / 2)
        adBannerView.delegate = self
        adBannerView.isHidden = true
        view.addSubview(adBannerView)
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
        interstitial = GADInterstitial (adUnitID: "ca-app-pub-7118034005818759/4865095025")
        interstitial.delegate = self;
        
        let request = GADRequest();
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made. GADInterstitial automatically returns test ads when running on a
        // simulator.
//        request.testDevices = [
//        "67def063eafa10c86d9461980e9bcc98"
//        ]
        interstitial.load(request)
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
        banner.load(request)
    }
}

extension GameViewController: ADBannerViewDelegate {
    
    func bannerViewWillLoadAd(_ banner: ADBannerView!) {
        print("banner View Will Load Ad")
    }
    
    func bannerViewDidLoadAd(_ banner: ADBannerView!) {
        print("banner View Did Load Ad")
        readyToShowAd = true
        if wantsToShowAd, let scene = sceneToShowAd {
            showAdBanner(scene: scene)
        }
    }
    
    func bannerViewActionShouldBegin(_ banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        print("banner View Action Should Begin")
        if let skView = self.view as? SKView {
            skView.isPaused = true
        }
        return true
    }
    
    func bannerViewActionDidFinish(_ banner: ADBannerView!) {
        print("banner View Action Did Finish")
        if let skView = self.view as? SKView {
            skView.isPaused = false
        }
    }
    
    func bannerView(_ banner: ADBannerView!, didFailToReceiveAdWithError error: Error!) {
        print("banner View did Fail To Receive Ad With Error")
        readyToShowAd = false
        adBannerView?.isHidden = true
        sceneToShowAd?.prepareForHidingAd()
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
        
        if interstitialDidClose != nil {
            interstitialDidClose!()
            interstitialDidClose = nil
        }
        
        createAndLoadInterstitial()
    }
}

extension GameViewController: GADBannerViewDelegate {
    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("AdMob: Banner View Did Fail To Receive Ad With Error")
        readyToShowAd = false
        if sceneToShowAd != nil && adBannerView != nil {
            adBannerView.isHidden = true
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
