//
//  Bundle+Bridge.swift
//  KakaoOpenSDK
//
//  Created by kakao on 10/16/25.
//  Copyright © 2025 apiteam. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
extension Bundle {
    static func getBridgeBundle() -> Bundle? {
#if SWIFT_PACKAGE
        if let mainPath = Bundle.main.path(forResource: "KakaoOpenSDK_KakaoSDKUser", ofType: "bundle") {
            return Bundle(path: mainPath)
        }
#endif
        
        return Bundle(for: BridgeBundleFinder.self)
    }
}

private class BridgeBundleFinder {}
