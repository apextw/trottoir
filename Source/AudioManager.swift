//
//  AudioManager.swift
//  Asphalt
//
//  Created by Alexander Bekert on 19/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import AVFoundation

class AudioManager: NSObject, AVAudioPlayerDelegate {
    
    class var sharedInstance: AudioManager {
        struct Singleton {
            static let instance = AudioManager()
        }
        
        return Singleton.instance
    }
    
    private let songName = "song"
    
    var musicEnabled: Bool {
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "Music Enabled")
            if newValue == true && player == nil {
                configureAudioSession()
                configureAudioPlayer()
            }
        }
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("Music Enabled")
        }
    }
    
    func switchMusicEnabled() {
        musicEnabled = musicEnabled ? false : true
    }
    
    var player: AVAudioPlayer!
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    override init() {
        super.init()
        if musicEnabled {
            configureAudioSession()
            configureAudioPlayer()
        }
    }
    
    private func configureAudioSession() {
        let category = audioSession.otherAudioPlaying ? AVAudioSessionCategorySoloAmbient : AVAudioSessionCategoryAmbient
        do {
            try audioSession.setCategory(category)
        } catch _ {
            print("Error setting category!")
        }
    }
    
    private func configureAudioPlayer() {
        if let filepath = NSBundle.mainBundle().pathForResource(songName, ofType: "caf") {
            let url = NSURL(fileURLWithPath: filepath)
            player = try? AVAudioPlayer(contentsOfURL: url)
            player.enableRate = false
            player.rate = 1
            player.delegate = self
            player.numberOfLoops = -1
            player.volume = 0.8
            player.prepareToPlay()
        }
    }
    
    func play() {
        if musicEnabled {
            player.play()
        }
    }
    
    func stop() {
        if player != nil {
            player.pause()
            player.rate = 1
            player.currentTime = 0
        }
    }
    
//    func setRate(newRate: Float) {
//        if musicEnabled {
//            player.rate = newRate
//        }
//    }
}
