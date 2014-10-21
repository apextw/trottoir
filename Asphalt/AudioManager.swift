//
//  AudioManager.swift
//  Asphalt
//
//  Created by Alexander Bekert on 19/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import AVFoundation

class AudioManager: NSObject, AVAudioPlayerDelegate {
    
    private let songName = "song"
    
    var player: AVAudioPlayer!
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    override init() {
        super.init()
        configureAudioSession()
        configureAudioPlayer()
    }
    
    private func configureAudioSession() {
        
        var success = false
        
        if audioSession.otherAudioPlaying {
            success = audioSession.setCategory(AVAudioSessionCategorySoloAmbient, error: nil)
        } else {
            success = audioSession.setCategory(AVAudioSessionCategoryAmbient, error: nil)
        }
        
        if !success {
            println("Error setting category!")
        }
    }
    
    private func configureAudioPlayer() {
        if let filepath = NSBundle.mainBundle().pathForResource(songName, ofType: "caf") {
            if let url = NSURL(fileURLWithPath: filepath) {
                player = AVAudioPlayer(contentsOfURL: url, error: nil)
                player.enableRate = true
                player.rate = 1
                player.delegate = self
                player.numberOfLoops = -1
                player.volume = 0.1
                player.prepareToPlay()
            }
        }
    }
    
    func play() {
        player.play()
    }
    
    func stop() {
        player.stop()
    }
    
    func setRate(newRate: Float) {
        player.rate = newRate
    }
}
