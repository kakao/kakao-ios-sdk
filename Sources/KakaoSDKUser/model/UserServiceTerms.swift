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

/// 서비스 약관 동의 내역 확인하기 응답 \
/// Response for Retrieve consent details for service terms
/// ## SeeAlso
/// - ``UserApi/serviceTerms(result:tags:completion:)``
public struct UserServiceTerms : Codable {
    
    // MARK: Fields
    
    /// 회원번호 \
    /// Service user ID
    public let id: Int64
    
    /// 서비스 약관 목록 \
    /// List of service terms
    /// ## SeeAlso
    /// - ``ServiceTerms``
    public let serviceTerms: [ServiceTerms]?
}

/// 서비스 약관 정보 \
/// Service terms information
/// ## SeeAlso
/// - ``UserServiceTerms``
public struct ServiceTerms : Codable {
    
    // MARK: Fields
    
    /// 태그 \
    /// Tag
    public let tag: String
    
    /// 마지막으로 동의한 시간 \
    /// The last time the user agreed to the scope
    public let agreedAt: Date?
    
    /// 동의 여부 \
    /// The consent status of the service terms
    public let agreed: Bool
    
    /// 필수 동의 여부 \
    /// Whether consent is required
    public let required: Bool
    
    /// 철회 가능 여부 \
    /// Whether consent is revocable
    public let revocable: Bool
}

/// 서비스 약관 동의 철회하기 응답 \
/// Response for Revoke consent for service terms
/// ## SeeAlso
/// - ``RevokedServiceTerms``
public struct UserRevokedServiceTerms : Codable {
    
    // MARK: Fields
    
    /// 회원번호 \
    /// Service user ID
    public var id: Int64
    
    /// 동의 철회에 성공한 서비스 약관 목록 \
    /// List of revoked service terms
    public var revokedServiceTerms: [RevokedServiceTerms]?
}

/// 동의 철회된 서비스 약관 정보 \
/// Revoked service terms information
/// ## SeeAlso
/// - ``UserRevokedServiceTerms``
public struct RevokedServiceTerms : Codable {
    
    // MARK: Fields
    
    /// 태그 \
    /// Tag
    public let tag: String
    
    /// 동의 여부 \
    /// The consent status of the service terms
    public let agreed: Bool
}
