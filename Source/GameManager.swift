//
//  GameManager.swift
//  Asphalt
//
//  Created by Alexander Bekert on 15/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import Foundation

protocol GameManagerProtocol {
    func setScore(newScore: Int)
    func gameOver()
}

class GameManager: MarkerActivationProtocol {
    
    class var godMode: Bool {
        return false
    }
    
    init(delegate: GameManagerProtocol) {
        self.delegate = delegate
    }
    
    var score: Int = 0 {
        didSet {
            if delegate != nil {
                delegate.setScore(score)
            }
        }
    }
    var delegate: GameManagerProtocol!
    
    var awaitingForDoubleMarker = false
    
    func markerDidActivated(sender: Marker) {
        let number = sender.number
        
        if number - 1 == score && !awaitingForDoubleMarker {
            score += 1
            return
        }
        
        if number - 2 == score && sender.doubledMarker != nil && !awaitingForDoubleMarker {
            score += 1
            awaitingForDoubleMarker = true
            return
        }
        
        if awaitingForDoubleMarker && number == score {
            score += 1
            awaitingForDoubleMarker = false
            return
        }
        
        gameOver()
    }
    
    func markerWillHideUnactivated(sender: Marker) {
        gameOver()
    }
    
    func markedDidActivatedSecondTime(sender: Marker) {
        gameOver()
    }
    
    private func gameOver() {
        print("Game over")
        if delegate != nil {
            delegate.gameOver()
        }
    }
    
    deinit {
        print("Game Manager deinit")
    }

}