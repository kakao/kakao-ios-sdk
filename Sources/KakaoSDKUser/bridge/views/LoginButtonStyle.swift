//
//  LoginButtonStyle.swift
//  KakaoOpenSDK
//
//  Created by kakao on 10/17/25.
//  Copyright © 2025 apiteam. All rights reserved.
//

import Foundation
import UIKit

extension LoginButton {
    enum Style {
        case yellow
        case gray
        
        var backgroundColorName: String {
            switch self {
            case .yellow:
                return "yellow500s"
            case .gray:
                return "gray070a"
            }
        }
        
        var titleColorName: String {
            return "gray900s"
        }
        
        var titleColor: UIColor? {
            switch self {
            case .yellow:
                return ResourceHelper.color(name: Style.yellow.titleColorName, style: .light)
            case .gray:
                return ResourceHelper.color(name: Style.gray.titleColorName)
            }
        }
        
        var backgroundColor: UIColor? {
            switch self {
            case .yellow:
                return ResourceHelper.color(name: Style.yellow.backgroundColorName)
            case .gray:
                return ResourceHelper.color(name: Style.gray.backgroundColorName)
            }
        }
        
        var highlightedColor: UIColor? {
            switch self {
            case .yellow:
                if let tintColor = ResourceHelper.color(name: "gray900s", style: .light) {
                    return backgroundColor?.blend(with: tintColor, amount: 0.2)
                }
            case .gray:
                if let tintColor = ResourceHelper.color(name: "gray900s") {
                    return backgroundColor?.blend(with: tintColor, amount: 0.2)
                }
            }
            
            return nil
        }
    }
}
