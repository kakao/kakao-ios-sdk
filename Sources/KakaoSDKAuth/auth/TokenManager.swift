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
import KakaoSDKCommon

/// 토큰 저장소, 기기 고유값으로 암호화된 토큰을 ``UserDefaults``에 저장 \
/// A token manager that encrypts tokens with the device's unique value and saves in the ``UserDefaults``
///
/// ## SeeAlso
/// - ``TokenManagable``
final public class TokenManager : TokenManagable {
    
    // MARK: Fields
    
    /// 카카오 SDK 싱글톤 객체 \
    /// A singleton object for Kakao SDK
    static public let manager = TokenManager()
    
    let OAuthTokenKey = "com.kakao.sdk.oauth_token"
    
    var token : OAuthToken?
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    /// 토큰 관리자를 초기화합니다. UserDefaults에 저장되어 있는 토큰을 읽어옵니다.
    public init() {
        self.token = Properties.loadCodable(key:OAuthTokenKey)
    }
    
    
    // MARK: TokenManagable Methods
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    /// UserDefaults에 토큰을 저장합니다.
    public func setToken(_ token: OAuthToken?) {
        Properties.saveCodable(key:OAuthTokenKey, data:token)
        self.token = token
    }
    
    /// 저장된 토큰 반환 \
    /// Returns saved tokens
    public func getToken() -> OAuthToken? {
        return self.token
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    /// UserDefaults에 저장된 토큰을 삭제합니다.
    public func deleteToken() {
        Properties.delete(OAuthTokenKey)
        self.token = nil
    }
}
