//
//  DisplayHelper.swift
//  Asphalt
//
//  Created by Alexander Bekert on 28/11/14.
//  Copyright (c) 2014 Alexander Bekert. All rights reserved.
//

import Foundation

public struct DisplayHelper {
    public static let MarkerSizeMultiplier: CGFloat = {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            return 1
        } else {
            return 1.5
        }
    }()
    
    public static let DrawingsSizeMultiplier: CGFloat = {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            return 1
        } else {
            return 1.5
        }
    }()
    
    public static let DrawingsBorderShift: CGFloat = {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            return 0
        } else {
            return 100
        }
    }()

    public static let MainMenuScale: CGFloat = {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            return 1
        } else {
            return 1.5
        }
    }()
    
    public static let FontScale: CGFloat = {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            return 1
        } else {
            return 1.5
        }
    }()



}