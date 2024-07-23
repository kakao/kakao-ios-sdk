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
    
    /// 서비스 약관의 동의 경로 \
    /// Path through which the service terms were agreed to.
    ///  ## SeeAlso
    ///  - ``Referer-swift.enum``
    public let referer: Referer?
    
    /// 서비스 약관의 동의 경로 \
    /// Path through which the service terms were agreed to.
    public enum Referer: String, Codable {
        /// 카카오싱크 간편가입 동의 화면 \
        /// Consent screen of Kakao Sync Simple Signup.
        case kauth = "KAUTH"
        
        /// 기타 \
        /// Other paths.
        case kapi = "KAPI"
        
        /// 알 수 없음 \
        /// Unknown
        case unknown
        
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
        public init(from decoder: any Decoder) throws {
            self = try Referer(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case tag, agreedAt, agreed, required, revocable
        case referer = "agreedBy"
    }
        
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        tag = try values.decode(String.self, forKey: .tag)
        agreedAt = try? values.decode(Date.self, forKey: .agreedAt)
        agreed = try values.decode(Bool.self, forKey: .agreed)
        required = try values.decode(Bool.self, forKey: .required)
        revocable = try values.decode(Bool.self, forKey: .revocable)
        referer = try? values.decode(Referer.self, forKey: .referer)
    }
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
