//
//  Bundle+Bridge.swift
//  KakaoOpenSDK
//
//  Created by kakao on 10/16/25.
//  Copyright © 2025 apiteam. All rights reserved.
//

import Foundation

extension Bundle {
    static func getBridgeBundle() -> Bundle? {
        let bridgeBundleName = "KakaoOpenSDK_KakaoSDKUser"
        
        if let mainPath = Bundle.main.path(forResource: bridgeBundleName, ofType: "bundle") {
            return Bundle(path: mainPath)
        }
        
        if let clsPath = Bundle(for: BridgeBundleFinder.self).path(forResource: bridgeBundleName, ofType: "bundle") {
            return Bundle(path: clsPath)
        }
        
        return Bundle(for: BridgeBundleFinder.self)
    }
}

private class BridgeBundleFinder {}
