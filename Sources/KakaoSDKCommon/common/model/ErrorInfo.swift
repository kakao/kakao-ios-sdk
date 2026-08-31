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

/// 에러 정보 \
/// Error information
/// ## SeeAlso
/// - ``ApiFailureReason``
public struct ErrorInfo : Codable {
    
    /// 에러 코드 \
    /// Error code
    public let code: ApiFailureReason
    
    /// 에러 메시지 \
    /// Error message
    public let msg: String
    
    /// 사용자가 동의해야 하는 동의항목 \
    /// Scopes that the user must agree to
    public let requiredScopes: [String]?
    
    @_documentation(visibility: private)
    /// API 종류 \
    /// API type
    public let apiType: String?
    
    /// 사용자가 동의한 동의항목 \
    /// Scopes that the user agreed to
    public let allowedScopes: [String]?

    @_documentation(visibility: private)
    public let reason: RecoveryReason

    public init(code: ApiFailureReason, msg:String, requiredScopes:[String]?) {
        self.code = code
        self.msg = msg
        self.requiredScopes = requiredScopes
        self.apiType = nil
        self.allowedScopes = nil
        self.reason = .unknown
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decode(ApiFailureReason.self, forKey: .code)
        self.msg = try container.decode(String.self, forKey: .msg)
        self.requiredScopes = try container.decodeIfPresent([String].self, forKey: .requiredScopes)
        self.apiType = try container.decodeIfPresent(String.self, forKey: .apiType)
        self.allowedScopes = try container.decodeIfPresent([String].self, forKey: .allowedScopes)
        self.reason = try container.decodeIfPresent(ErrorInfo.RecoveryReason.self, forKey: .reason) ?? .unknown
    }
}

extension ErrorInfo {
    public enum RecoveryReason: String, Codable {
        case refresh = "ACCESS_TOKEN_EXPIRED"
        case unknown = "UNKNOWN"

        public init(from decoder: any Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = RecoveryReason(rawValue: raw) ?? .unknown
        }
    }
}
