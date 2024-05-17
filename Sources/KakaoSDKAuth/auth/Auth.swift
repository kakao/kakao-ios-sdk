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

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
public let AUTH = Auth.shared

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
public class Auth {
    static public let retryTokenRefreshCount = 3
    static public let shared = Auth()
    
    public var tokenManager: TokenManagable
    
    init(tokenManager : TokenManagable = TokenManager.manager) {
        self.tokenManager = tokenManager
        
        if tokenManager is KakaoSDKAuth.TokenManager {
            MigrateManager.checkSdkVersionForMigration()
        }        
        TokenRefresher.shared.registTokenRefresher()
    }
}

extension Auth {
    /// 토큰 저장소 직접 지정, `TokenManageable`을 구현한 사용자 정의 토큰 매니저 설정 가능 \
    /// Set the custom token manager that implements `TokenManageable`
    public func setTokenManager(_ tokenManager: TokenManagable = TokenManager.manager) {
        self.tokenManager = tokenManager
    }
}

extension Auth {    
    public func checkMigration() {
        //nop
    }
}
