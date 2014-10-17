//
//  Achievements.swift
//  Asphalt
//
//  Created by Alexander Bekert on 15/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import Foundation

struct Results {
    
    static func commitNewLocalBest(result: Int) {
        let currentBest = localBestResult
        if result > currentBest {
            localBestResult = result
        }
    }
    
    static var localBestResult: Int {
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "localBestResult")
        }
        get {
//            return 5
            return NSUserDefaults.standardUserDefaults().integerForKey("localBestResult")
        }
    }
}