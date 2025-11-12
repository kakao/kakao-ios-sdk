//
//  BridgeProperties.swift
//  KakaoOpenSDK
//
//  Created by kakao on 10/20/25.
//  Copyright © 2025 apiteam. All rights reserved.
//

import Foundation
import UIKit

import KakaoSDKCommon
import KakaoSDKAuth

/// BridgeConfiguration \
/// 로그인 선택 화면 설정
public struct BridgeConfiguration {
    let orientation: LoginOrientation
    let uiMode: LoginUiMode
    
    public init(orientation: LoginOrientation? = nil,
                uiMode: LoginUiMode? = nil) {
        self.orientation = orientation ?? .auto
        self.uiMode = uiMode ?? .auto
    }
}

/// 로그인 선택 화면 방향 \
/// Login selection screen orientation
public enum LoginOrientation: String {
    /// 세로 모드 \
    /// Portrait mode
    case portrait
    /// 가로 모드 \
    /// Landscape mode
    case landscape
    /// 디바이스 설정과 동일한 모드 자동 적용(기본값) \
    /// Automatically follows device setting (default)
    case auto
}

/// 로그인 선택 화면 모드 \
/// Login selection screen UI mode
public enum LoginUiMode: String {
    /// 라이트 모드 \
    /// Light mode
    case light
    /// 다크 모드 \
    /// Dark mode
    case dark
    /// 디바이스 설정과 동일한 모드 자동 적용(기본값) \
    /// Automatically follows device setting (default)
    case auto
    
    func toUIUserInterfaceStyle() -> UIUserInterfaceStyle {
        switch self {
        case .light:
            return UIUserInterfaceStyle.light
        case .dark:
            return UIUserInterfaceStyle.dark
        case .auto:
            return UIUserInterfaceStyle.unspecified
        }
    }
}

/// 카카오톡으로 로그인과 카카오계정으로 로그인에 사용되는 설정 \
/// Configuration used for Login with Kakao Talk and Login with Kakao Account.
public struct LoginConfiguration {
    /// 카카오톡으로 로그인 기능을 위한 설정 \
    /// Configuration for Login with Kakao Talk
    let talk: Talk
    /// 카카오계정으로 로그인 기능을 위한 설정 \
    /// Configuration for Login with Kakao Account
    let account: Account
    /// channelPublicIds \
    /// 카카오톡 채널 ID 목록
    let channelPublicIds: [String]?
    let serviceTerms: [String]?
    let nonce: String?
    
    public init(talk: Talk? = nil, account: Account? = nil, channelPublicIds: [String]? = nil, serviceTerms: [String]? = nil, nonce: String? = nil) {
        self.talk = talk ?? Talk()
        self.account = account ?? Account()
        self.channelPublicIds = channelPublicIds
        self.serviceTerms = serviceTerms
        self.nonce = nonce
    }
    
    /// 카카오톡으로 로그인 기능을 위한 설정 \
    /// Configuration for Login with Kakao Talk
    public struct Talk {
        let launchMethod: LaunchMethod?
        
        init(launchMethod: LaunchMethod? = .UniversalLink) {
            self.launchMethod = launchMethod
        }
    }
    
    /// 카카오계정으로 로그인 기능을 위한 설정 \
    /// Configuration for Login with Kakao Account
    public struct Account {
        let prompts : [Prompt]?
        let loginHint: String?
        
        init(prompts: [Prompt]? = nil, loginHint: String? = nil) {
            self.prompts = prompts
            self.loginHint = loginHint
        }
    }
}

