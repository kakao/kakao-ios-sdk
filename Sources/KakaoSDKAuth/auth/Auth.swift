//  Copyright 2019 Kakao Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation
import UIKit
import KakaoSDKCommon

@_documentation(visibility: private)
public let AUTH = Auth.shared

@_documentation(visibility: private)
public class Auth {
    static public let retryTokenRefreshCount = 3
    static public let shared = Auth()
    
    public var tokenManager: TokenManagable
    
    init(tokenManager : TokenManagable = TokenManager.manager) {
        self.tokenManager = tokenManager
        
        if tokenManager is KakaoSDKAuth.TokenManager {
            MigrateManager.checkSdkVersionForMigration()
        }
    }
}

extension Auth {
    /// ## 커스텀 토큰 관리자
    /// TokenManagable 프로토콜을 구현하여 직접 토큰 관리자를 구현할 수 있습니다.
    public func setTokenManager(_ tokenManager: TokenManagable = TokenManager.manager) {
        self.tokenManager = tokenManager
    }
}

@_documentation(visibility: private)
extension Auth {    
    public func checkMigration() {
        //nop
    }
}
