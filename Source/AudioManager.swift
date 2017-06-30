//
//  AudioManager.swift
//  Asphalt
//
//  Created by Alexander Bekert on 19/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import AVFoundation

class AudioManager: NSObject, AVAudioPlayerDelegate {
    
    static var sharedInstance = AudioManager()
    
    fileprivate let songName = "song"
    
    var musicEnabled: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "Music Enabled")
            if newValue == true && player == nil {
                configureAudioSession()
                configureAudioPlayer()
            }
        }
        get {
            return UserDefaults.standard.bool(forKey: "Music Enabled")
        }
    }
    
    func switchMusicEnabled() {
        musicEnabled = musicEnabled ? false : true
    }
    
    var player: AVAudioPlayer!
    fileprivate var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    override init() {
        super.init()
        if musicEnabled {
            configureAudioSession()
            configureAudioPlayer()
        }
    }
    
    fileprivate func configureAudioSession() {
        let category = audioSession.isOtherAudioPlaying ? AVAudioSessionCategorySoloAmbient : AVAudioSessionCategoryAmbient
        do {
            try audioSession.setCategory(category)
        } catch _ {
            print("Error setting category!")
        }
    }
    
    fileprivate func configureAudioPlayer() {
        if let filepath = Bundle.main.path(forResource: songName, ofType: "caf") {
            let url = URL(fileURLWithPath: filepath)
            player = try? AVAudioPlayer(contentsOf: url)
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
