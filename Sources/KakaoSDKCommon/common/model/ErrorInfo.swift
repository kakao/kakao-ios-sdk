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
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    /// API 종류 \
    /// API type
    public let apiType: String?
    
    /// 사용자가 동의한 동의항목 \
    /// Scopes that the user agreed to
    public let allowedScopes: [String]?
    
    public init(code: ApiFailureReason, msg:String, requiredScopes:[String]?) {
        self.code = code
        self.msg = msg
        self.requiredScopes = requiredScopes
        self.apiType = nil
        self.allowedScopes = nil
    }
}
