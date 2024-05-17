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

/// 토큰 저장소 프로토콜 \
/// Protocol for the token manager
///
/// ## SeeAlso
/// - ``TokenManager``
///
/// ## 커스텀 토큰 관리자
/// TokenManagable 프로토콜을 구현하여 직접 토큰 관리자를 구현할 수 있습니다.
///

public protocol TokenManagable {
    
    // MARK: Methods
    
    /// 토큰을 ``UserDefaults``에 저장 \
    /// Saves tokens in the ``UserDefaults``
    func setToken(_ token:OAuthToken?)
    
    /// 저장된 토큰 반환 \
    /// Returns saved tokens
    func getToken() -> OAuthToken?
    
    /// 저장된 토큰 삭제 \
    /// Deletes saved tokens
    func deleteToken()
}
