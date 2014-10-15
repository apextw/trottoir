//
//  Achievements.swift
//  Asphalt
//
//  Created by Alexander Bekert on 15/10/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import Foundation

var localBestResult: Int {
set {
    NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "localBestResult")
}
get {
    return NSUserDefaults.standardUserDefaults().integerForKey("localBestResult")
}
}