//
//  ResourceHelper.swift
//  KakaoOpenSDK
//
//  Created by kakao on 10/16/25.
//  Copyright © 2025 apiteam. All rights reserved.
//

import Foundation
import UIKit

final class ResourceHelper {
    static func image(name: String, renderingMode: UIImage.RenderingMode = .alwaysTemplate, style: LoginUiMode? = nil) -> UIImage? {
        
        if let image = UIImage(named: name, in: .getBridgeBundle(),
                               compatibleWith: .init(userInterfaceStyle: style?.toUIUserInterfaceStyle() ?? .unspecified)) {
            return image.withRenderingMode(renderingMode)
        }
        
        return UIImage(named: name)?.withRenderingMode(renderingMode)
    }
    
    static func color(name: String, style: LoginUiMode? = nil) -> UIColor? {
        if let colorInBundle = UIColor(named: name, in: .getBridgeBundle(), compatibleWith: nil) {
            if let style {
                return colorInBundle.resolvedColor(style: style.toUIUserInterfaceStyle())
            }
            
            return colorInBundle
        }
        
        return UIColor(named: name)
    }
    
    static func localizedString(key: String) -> String? {
        return NSLocalizedString(key, tableName: "KakaoSDKUserLocalizable", bundle: .getBridgeBundle() ?? .main, comment: "")
    }
}
