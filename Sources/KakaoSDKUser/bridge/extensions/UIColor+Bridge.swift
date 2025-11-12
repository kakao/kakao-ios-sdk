//
//  UIColor+Bridge.swift
//  KakaoOpenSDK
//
//  Created by kakao on 10/17/25.
//  Copyright © 2025 apiteam. All rights reserved.
//


import UIKit

extension UIColor {
    func resolvedColor(style: UIUserInterfaceStyle) -> UIColor {
        switch style {
        case .dark:
            return self.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
        default:
            return self.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        }
    }
    
    func blend(with color: UIColor, amount: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let newR = r1 * (1.0 - amount) + r2 * amount
        let newG = g1 * (1.0 - amount) + g2 * amount
        let newB = b1 * (1.0 - amount) + b2 * amount
        let newA = a1 * (1.0 - amount) + a2 * amount
        
        return UIColor(red: newR, green: newG, blue: newB, alpha: newA)
    }
}
