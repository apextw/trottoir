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
        self.name = name != nil ? name! : ""
    }
    
    init(score: GKScore) {
        self.score = Int(score.value)
        self.name = (score.player?.alias!)!
    }
    
    required init?(coder decoder: NSCoder) {
        if let decodedName = decoder.decodeObject(forKey: "Name") as! String? {
            name = decodedName
        } else {
            name = ""
        }
        
        score = decoder.decodeInteger(forKey: "Score")
    }
    
    func encode(with encoder: NSCoder) {
        encoder.encode(name, forKey: "Name")
        encoder.encode(score, forKey: "Score")
    }

    class func loadFromUserDefaultsForKey(_ key: String) -> Result {
        let score = UserDefaults.standard.integer(forKey: key + " Score")
        let name = UserDefaults.standard.string(forKey: key + " Name")
        
        return Result(score: score, name: name)
    }
    
    func saveToUserDefaultsWithKey(_ key: String) {
        UserDefaults.standard.set(score, forKey: key + " Score")
        UserDefaults.standard.set(name, forKey: key + " Name")
    }
    
    override var description: String {
        return "\(name) — \(score) score(s)"
    }
}
