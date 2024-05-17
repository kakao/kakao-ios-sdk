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

// MARK: Enumerations

/// 동의항목 타입 \
/// Scope type
public enum ScopeType: String, Codable {
    /// 개인정보 보호 동의항목 \
    /// Scope for personal information
    case Privacy = "PRIVACY"
    
    /// 접근권한 관리 동의항목 \
    /// Scope for permission
    case Service = "SERVICE"
}

/// 동의항목 정보 \
/// Scope information
public struct Scope : Codable {
    // MARK: Fields
    
    /// 동의항목 ID \
    /// Scope ID
    public let id: String
    
    /// 사용자 동의 화면에 출력되는 동의항목의 이름 또는 설명 \
    /// Name or description of the scope displayed on the Consent screen
    public let displayName: String

    /// 동의항목 타입 \
    /// Type of the scope
    public let type: ScopeType

    /// 동의항목 사용 여부 \
    /// Whether your app is using the scope
    public let using: Bool
    
    /// 카카오가 관리하지 않는 위임 동의항목인지 여부, 현재 사용 중인 동의항목만 응답에 포함 \
    /// Whether the scope is not managed by Kakao, and only the currently used consent is included in the response
    public let delegated: Bool?

    /// 동의 여부 \
    /// The consent status of the service terms
    public let agreed: Bool

    /// 동의 철회 가능 여부 \
    /// Whether the scope can be revoked
    public let revocable : Bool?

}


/// 사용자 동의 내역 \
/// User consent history
public struct ScopeInfo : Codable {
    
    // MARK: Fields
    
    /// 회원번호 \
    /// Service user ID
    public let id: Int64
    
    /// 앱의 동의항목 목록 \
    /// List of scopes in the app
    public let scopes: [Scope]?
}
