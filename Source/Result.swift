//
//  Result.swift
//  Asphalt
//
//  Created by Alexander Bekert on 10/01/15.
//  Copyright (c) 2015 Alexander Bekert. All rights reserved.
//

import Foundation
import GameKit

class Result : NSObject, NSCoding {
    var score: Int
    var name: String
    
    init(score: Int, name: String? = "") {
        self.score = score
        self.name = name!
//        if name == nil {
//            self.name = "";
//        } else {
//            self.name = name!
//        }
    }
    
    init(score: GKScore) {
        self.score = Int(score.value)
        self.name = score.player.alias!
    }
    
    required init?(coder decoder: NSCoder) {
        if let decodedName = decoder.decodeObjectForKey("Name") as! String? {
            name = decodedName
        } else {
            name = ""
        }
        
        score = decoder.decodeIntegerForKey("Score")
    }
    
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(name, forKey: "Name")
        encoder.encodeInteger(score, forKey: "Score")
    }

    class func loadFromUserDefaultsForKey(key: String) -> Result {
        let score = NSUserDefaults.standardUserDefaults().integerForKey(key + " Score")
        let name = NSUserDefaults.standardUserDefaults().stringForKey(key + " Name")
        
        return Result(score: score, name: name)
    }
    
    func saveToUserDefaultsWithKey(key: String) {
        NSUserDefaults.standardUserDefaults().setInteger(score, forKey: key + " Score")
        NSUserDefaults.standardUserDefaults().setObject(name, forKey: key + " Name")
    }
    
    override var description: String {
        return "\(name) — \(score) score(s)"
    }
}