//
//  Random.swift
//  Trottoir
//
//  Created by Alexander Bekert on 7/4/17.
//  Copyright © 2017 Alexander Bekert. All rights reserved.
//

public class Random {
    
    public static func value(to: Float) -> Float {
        return value() * to
    }
    
    public static func value(lower: Float, upper: Float) -> Float {
        if lower > upper {
            return value(lower: upper, upper: lower)
        }
        return (value() * (upper - lower)) + lower
    }

    public static func value() -> Float {
        return Float(arc4random() % UInt32.max) / Float(UInt32.max)
    }
    
    public static func value(precision: Int) -> Float {
        let d = UInt32(powf(10, Float(precision)))
        return Float(arc4random() % d) / Float(d)
    }
}

