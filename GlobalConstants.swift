//
//  GlobalConstants.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 18/11/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit
import Foundation


struct constants {
    
    struct globalColors {
        
        static let happyMainColor = UIColor(hex: "ff7153")
    
    }
    
    struct gestureConstants {
        static let gestureRemoveViewSpeed = CGFloat(1300)
        static let getureRemoveThreshold = CGFloat(0.33)
    }
    
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

